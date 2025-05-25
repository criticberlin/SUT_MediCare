import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'base_service.dart';

class AppointmentService extends BaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new appointment
  Future<String> createAppointment({
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
    required String reason,
    required int duration,
    String? notes,
    double? fee,
    String status = 'pending',
  }) async {
    try {
      // Verify that both patient and doctor exist
      final patientSnapshot = await _database.child('users/Patients/$patientId').get();
      final doctorSnapshot = await _database.child('users/Doctors/$doctorId').get();
      
      if (!patientSnapshot.exists) {
        throw 'Patient does not exist';
      }
      
      if (!doctorSnapshot.exists) {
        throw 'Doctor does not exist';
      }
      
      // Create appointment data
      final appointmentData = {
        'patientId': patientId,
        'doctorId': doctorId,
        'dateTime': dateTime.toIso8601String(),
        'reason': reason,
        'duration': duration,
        'notes': notes,
        'fee': fee,
        'status': status,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };
      
      // Add to appointments collection
      final newAppointmentRef = _database.child('appointments').push();
      final appointmentId = newAppointmentRef.key!;
      await newAppointmentRef.set({
        'id': appointmentId,
        ...appointmentData
      });
      
      // Check if there's already a chat between these users
      String chatId = await _findOrCreateChat(patientId, doctorId);
      
      // Create notifications for both users
      await _createNotification(
        userId: patientId, 
        title: 'New Appointment', 
        body: 'You have a new appointment scheduled with Dr. ${(doctorSnapshot.value as Map)['name']}',
        type: 'appointment',
        referenceId: appointmentId,
      );
      
      await _createNotification(
        userId: doctorId, 
        title: 'New Appointment Request', 
        body: 'You have a new appointment request from ${(patientSnapshot.value as Map)['name']}',
        type: 'appointment',
        referenceId: appointmentId,
      );
      
      return appointmentId;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }
  
  // Find an existing chat or create a new one
  Future<String> _findOrCreateChat(String patientId, String doctorId) async {
    try {
      // Check if a chat already exists between these users
      final snapshot = await _database.child('chats')
          .orderByChild('participants')
          .equalTo('$patientId,$doctorId')
          .limitToFirst(1)
          .get();
      
      if (snapshot.exists) {
        // Return the existing chatId
        final chatData = (snapshot.value as Map).entries.first;
        return chatData.key;
      } else {
        // Create a new chat
        final newChatRef = _database.child('chats').push();
        final chatId = newChatRef.key!;
        
        await newChatRef.set({
          'id': chatId,
          'participants': [patientId, doctorId],
          'participantsString': '$patientId,$doctorId',  // Used for querying
          'lastMessage': null,
          'lastMessageTime': null,
          'createdAt': ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        });
        
        return chatId;
      }
    } catch (e) {
      print('Error finding or creating chat: $e');
      rethrow;
    }
  }
  
  // Create a notification
  Future<void> _createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
  }) async {
    try {
      final notificationRef = _database.child('notifications/$userId').push();
      
      await notificationRef.set({
        'id': notificationRef.key,
        'title': title,
        'body': body,
        'type': type,
        'referenceId': referenceId,
        'read': false,
        'createdAt': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error creating notification: $e');
      // Don't rethrow - we don't want notification failures to break the main flow
    }
  }
  
  // Send a message
  Future<String> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? attachment,
  }) async {
    try {
      // Get chat to validate it exists
      final chatSnapshot = await _database.child('chats/$chatId').get();
      if (!chatSnapshot.exists) {
        throw 'Chat does not exist';
      }
      
      final chatData = chatSnapshot.value as Map<dynamic, dynamic>;
      final participants = List<String>.from(chatData['participants']);
      
      // Validate sender is a participant
      if (!participants.contains(senderId)) {
        throw 'Sender is not a participant of this chat';
      }
      
      // Create message
      final newMessageRef = _database.child('messages/$chatId').push();
      final messageId = newMessageRef.key!;
      
      final messageData = {
        'id': messageId,
        'senderId': senderId,
        'text': text,
        'attachment': attachment,
        'read': false,
        'createdAt': ServerValue.timestamp,
      };
      
      await newMessageRef.set(messageData);
      
      // Update chat's last message
      await _database.child('chats/$chatId').update({
        'lastMessage': text,
        'lastMessageSender': senderId,
        'lastMessageTime': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      
      // Create notification for other participants
      for (String participantId in participants) {
        if (participantId != senderId) {
          // Look up sender name
          final senderSnapshot = await _database.child('users/$senderId').get();
          String senderName = 'Someone';
          if (senderSnapshot.exists) {
            senderName = (senderSnapshot.value as Map)['name'] ?? 'Someone';
          }
          
          await _createNotification(
            userId: participantId,
            title: 'New Message',
            body: '$senderName: $text',
            type: 'message',
            referenceId: chatId,
          );
        }
      }
      
      return messageId;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
  
  // Get user appointments
  Future<List<Map<String, dynamic>>> getUserAppointments(String userId) async {
    try {
      // First determine if the user is a patient or doctor
      final patientSnapshot = await _database.child('users/Patients/$userId').get();
      final doctorSnapshot = await _database.child('users/Doctors/$userId').get();
      
      String queryField;
      if (patientSnapshot.exists) {
        queryField = 'patientId';
      } else if (doctorSnapshot.exists) {
        queryField = 'doctorId';
      } else {
        throw 'User not found as either patient or doctor';
      }
      
      // Query appointments based on user role
      final appointmentsSnapshot = await _database.child('appointments')
          .orderByChild(queryField)
          .equalTo(userId)
          .get();
          
      if (!appointmentsSnapshot.exists) {
        return [];
      }
      
      final appointmentsData = appointmentsSnapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> appointments = [];
      
      appointmentsData.forEach((key, value) {
        appointments.add({
          'id': key,
          ...Map<String, dynamic>.from(value as Map),
        });
      });
      
      // Sort by date
      appointments.sort((a, b) => 
        DateTime.parse(a['dateTime']).compareTo(DateTime.parse(b['dateTime']))
      );
      
      return appointments;
    } catch (e) {
      print('Error getting user appointments: $e');
      rethrow;
    }
  }
  
  // Get user chats
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    try {
      final chatsSnapshot = await _database.child('chats')
          .orderByChild('participantsString')
          .startAt(userId)
          .endAt('$userId\uf8ff')
          .get();
          
      if (!chatsSnapshot.exists) {
        return [];
      }
      
      final chatsData = chatsSnapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> chats = [];
      
      await Future.forEach(chatsData.entries, (entry) async {
        final chatData = entry.value as Map<dynamic, dynamic>;
        final participants = List<String>.from(chatData['participants']);
        
        if (participants.contains(userId)) {
          // Get other participant details
          String otherParticipantId = participants.firstWhere((id) => id != userId);
          final otherUserSnapshot = await _database.child('users/$otherParticipantId').get();
          
          Map<String, dynamic> otherUserData = {};
          if (otherUserSnapshot.exists) {
            otherUserData = Map<String, dynamic>.from(otherUserSnapshot.value as Map);
          }
          
          chats.add({
            'id': entry.key,
            ...Map<String, dynamic>.from(chatData),
            'otherUser': otherUserData,
          });
        }
      });
      
      // Sort by last message time
      chats.sort((a, b) {
        final aTime = a['lastMessageTime'] ?? a['createdAt'];
        final bTime = b['lastMessageTime'] ?? b['createdAt'];
        return bTime.compareTo(aTime);
      });
      
      return chats;
    } catch (e) {
      print('Error getting user chats: $e');
      rethrow;
    }
  }
  
  // Get chat messages
  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    try {
      final messagesSnapshot = await _database.child('messages/$chatId')
          .orderByChild('createdAt')
          .get();
          
      if (!messagesSnapshot.exists) {
        return [];
      }
      
      final messagesData = messagesSnapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> messages = [];
      
      messagesData.forEach((key, value) {
        messages.add({
          'id': key,
          ...Map<String, dynamic>.from(value as Map),
        });
      });
      
      // Sort by creation time
      messages.sort((a, b) => 
        (a['createdAt'] as int).compareTo(b['createdAt'] as int)
      );
      
      return messages;
    } catch (e) {
      print('Error getting chat messages: $e');
      rethrow;
    }
  }
  
  // Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final notificationsSnapshot = await _database.child('notifications/$userId')
          .orderByChild('createdAt')
          .get();
          
      if (!notificationsSnapshot.exists) {
        return [];
      }
      
      final notificationsData = notificationsSnapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> notifications = [];
      
      notificationsData.forEach((key, value) {
        notifications.add({
          'id': key,
          ...Map<String, dynamic>.from(value as Map),
        });
      });
      
      // Sort by creation time (newest first)
      notifications.sort((a, b) => 
        (b['createdAt'] as int).compareTo(a['createdAt'] as int)
      );
      
      return notifications;
    } catch (e) {
      print('Error getting user notifications: $e');
      rethrow;
    }
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _database.child('notifications/$userId/$notificationId').update({
        'read': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }
  
  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final appointmentRef = _database.child('appointments/$appointmentId');
      final appointmentSnapshot = await appointmentRef.get();
      
      if (!appointmentSnapshot.exists) {
        throw 'Appointment not found';
      }
      
      final appointmentData = appointmentSnapshot.value as Map<dynamic, dynamic>;
      final patientId = appointmentData['patientId'];
      final doctorId = appointmentData['doctorId'];
      
      await appointmentRef.update({
        'status': status,
        'updatedAt': ServerValue.timestamp,
      });
      
      // Create notifications for both users
      // Get patient and doctor names
      final patientSnapshot = await _database.child('users/Patients/$patientId').get();
      final doctorSnapshot = await _database.child('users/Doctors/$doctorId').get();
      
      final patientName = patientSnapshot.exists ? (patientSnapshot.value as Map)['name'] : 'Patient';
      final doctorName = doctorSnapshot.exists ? (doctorSnapshot.value as Map)['name'] : 'Doctor';
      
      String notificationTitle, patientNotificationBody, doctorNotificationBody;
      
      switch (status) {
        case 'confirmed':
          notificationTitle = 'Appointment Confirmed';
          patientNotificationBody = 'Your appointment with Dr. $doctorName has been confirmed';
          doctorNotificationBody = 'You confirmed an appointment with $patientName';
          break;
        case 'cancelled':
          notificationTitle = 'Appointment Cancelled';
          patientNotificationBody = 'Your appointment with Dr. $doctorName has been cancelled';
          doctorNotificationBody = 'The appointment with $patientName has been cancelled';
          break;
        case 'completed':
          notificationTitle = 'Appointment Completed';
          patientNotificationBody = 'Your appointment with Dr. $doctorName has been marked as completed';
          doctorNotificationBody = 'The appointment with $patientName has been marked as completed';
          break;
        default:
          notificationTitle = 'Appointment Update';
          patientNotificationBody = 'Your appointment with Dr. $doctorName has been updated';
          doctorNotificationBody = 'The appointment with $patientName has been updated';
      }
      
      await _createNotification(
        userId: patientId,
        title: notificationTitle,
        body: patientNotificationBody,
        type: 'appointment',
        referenceId: appointmentId,
      );
      
      await _createNotification(
        userId: doctorId,
        title: notificationTitle,
        body: doctorNotificationBody,
        type: 'appointment',
        referenceId: appointmentId,
      );
      
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }
} 