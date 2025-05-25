import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/appointment_service.dart';
import '../models/appointment.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/notification.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  String? _error;
  List<Appointment>? _appointments;
  List<Chat>? _chats;
  List<AppNotification>? _notifications;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Appointment>? get appointments => _appointments;
  List<Chat>? get chats => _chats;
  List<AppNotification>? get notifications => _notifications;
  
  // Get the current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Check if the user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
  
  // Create a new appointment
  Future<void> createAppointment({
    required String doctorId,
    required DateTime dateTime,
    required String reason,
    required int duration,
    String? notes,
    double? fee,
  }) async {
    if (!isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final patientId = currentUserId!;
      
      await _appointmentService.createAppointment(
        patientId: patientId,
        doctorId: doctorId,
        dateTime: dateTime,
        reason: reason,
        duration: duration,
        notes: notes,
        fee: fee,
        status: 'pending',
      );
      
      // Refresh appointments
      await fetchAppointments();
    } catch (e) {
      _error = e.toString();
      print('Error creating appointment: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch user appointments
  Future<void> fetchAppointments() async {
    if (!isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userId = currentUserId!;
      final appointmentsData = await _appointmentService.getUserAppointments(userId);
      
      _appointments = appointmentsData.map((data) => Appointment.fromMap(data)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error fetching appointments: $_error');
      _appointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    if (!isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _appointmentService.updateAppointmentStatus(appointmentId, status);
      
      // Refresh appointments
      await fetchAppointments();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error updating appointment status: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch user chats
  Future<void> fetchChats() async {
    if (!isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userId = currentUserId!;
      final chatsData = await _appointmentService.getUserChats(userId);
      
      _chats = chatsData.map((data) => Chat.fromMap(data)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error fetching chats: $_error');
      _chats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Send a message
  Future<void> sendMessage({
    required String chatId, 
    required String content, 
    String type = 'text'
  }) async {
    if (!isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final senderId = currentUserId!;
      
      await Message.createMessage(
        chatId: chatId,
        senderId: senderId,
        content: content,
        type: type,
      );
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error sending message: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch messages for a chat
  Future<List<Message>> fetchMessages(String chatId) async {
    if (!isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return [];
    }
    
    try {
      final messagesSnapshot = await FirebaseDatabase.instance
          .ref('messages/$chatId')
          .orderByChild('timestamp')
          .get();
          
      if (!messagesSnapshot.exists) {
        return [];
      }
      
      final messagesData = messagesSnapshot.value as Map<dynamic, dynamic>;
      List<Message> messages = [];
      
      messagesData.forEach((key, value) {
        messages.add(Message.fromMap({
          'id': key,
          ...Map<String, dynamic>.from(value as Map),
        }));
      });
      
      // Sort by creation time
      messages.sort((a, b) => 
        a.timestamp.compareTo(b.timestamp)
      );
      
      return messages;
    } catch (e) {
      _error = e.toString();
      print('Error fetching messages: $_error');
      return [];
    }
  }
  
  // Stream messages for a chat
  Stream<List<Message>> streamMessages(String chatId) {
    return Message.streamMessagesForChat(chatId);
  }
  
  // Fetch user notifications
  Future<void> fetchNotifications() async {
    if (!isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userId = currentUserId!;
      final notificationsData = await _appointmentService.getUserNotifications(userId);
      
      _notifications = notificationsData.map((data) => AppNotification.fromMap(data)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error fetching notifications: $_error');
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (!isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    try {
      final userId = currentUserId!;
      await _appointmentService.markNotificationAsRead(userId, notificationId);
      
      // Update local notification
      if (_notifications != null) {
        final index = _notifications!.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications![index] = _notifications![index].copyWith(isRead: true);
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      print('Error marking notification as read: $_error');
    }
  }
  
  // Stream appointments, chats and notifications
  void setupStreams() {
    // Check authentication first
    if (!isAuthenticated) return;
    
    final userId = currentUserId!;
    final database = FirebaseDatabase.instance;
    
    // Stream appointments
    database.ref('appointments')
      .orderByChild(getUserRole() == 'doctor' ? 'doctorId' : 'patientId')
      .equalTo(userId)
      .onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _appointments = data.entries.map((entry) => 
            Appointment.fromMap({
              'id': entry.key,
              ...Map<String, dynamic>.from(entry.value as Map),
            })
          ).toList();
          
          _appointments!.sort((a, b) => a.date.compareTo(b.date));
          notifyListeners();
        } else {
          _appointments = [];
          notifyListeners();
        }
      }, onError: (error) {
        print('Error streaming appointments: $error');
      });
      
    // Stream chats
    database.ref('chats')
      .onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _chats = data.entries
            .where((entry) {
              final chatData = entry.value as Map<dynamic, dynamic>;
              final participants = List<String>.from(chatData['participants'] ?? []);
              return participants.contains(userId);
            })
            .map((entry) => 
              Chat.fromMap({
                'id': entry.key,
                ...Map<String, dynamic>.from(entry.value as Map),
              })
            ).toList();
          
          notifyListeners();
        } else {
          _chats = [];
          notifyListeners();
        }
      }, onError: (error) {
        print('Error streaming chats: $error');
      });
      
    // Stream notifications
    database.ref('notifications/$userId')
      .onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _notifications = data.entries.map((entry) => 
            AppNotification.fromMap({
              'id': entry.key,
              ...Map<String, dynamic>.from(entry.value as Map),
            })
          ).toList();
          
          if (_notifications != null && _notifications!.isNotEmpty) {
            _notifications!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }
          notifyListeners();
        } else {
          _notifications = [];
          notifyListeners();
        }
      }, onError: (error) {
        print('Error streaming notifications: $error');
      });
  }
  
  // Get user role
  String getUserRole() {
    if (!isAuthenticated) return '';
    
    final database = FirebaseDatabase.instance;
    final userId = currentUserId!;
    
    // We'll cache this for better performance
    return _cachedUserRole ?? 'patient';
  }
  
  String? _cachedUserRole;
  
  // Set cached user role
  void setCachedUserRole(String role) {
    _cachedUserRole = role;
  }
} 