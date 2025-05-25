import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'base_service.dart';

class DatabaseService extends BaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final DatabaseEvent event = await _database.child('users/${user.uid}').once();
      return event.snapshot.value as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      await _database.child('users/${user.uid}').update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Stream user data
  Stream<DatabaseEvent> streamUserData() {
    final User? user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    return _database.child('users/${user.uid}').onValue;
  }

  // User Profile Operations
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;
    return getData('users/$currentUserId/profile');
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await updateData('users/$currentUserId/profile', {
      ...profileData,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Medical History Operations
  Future<void> addMedicalHistory(Map<String, dynamic> medicalData) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await pushData('users/$currentUserId/medical_history', {
      ...medicalData,
      'createdAt': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> getMedicalHistory() {
    if (!isAuthenticated) throw 'User not authenticated';
    return _database
        .child('users/$currentUserId/medical_history')
        .orderByChild('createdAt')
        .onValue;
  }

  Future<void> updateMedicalHistory(String historyId, Map<String, dynamic> data) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await updateData('users/$currentUserId/medical_history/$historyId', data);
  }

  Future<void> deleteMedicalHistory(String historyId) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await deleteData('users/$currentUserId/medical_history/$historyId');
  }

  // Appointment Operations
  Future<void> addAppointment(Map<String, dynamic> appointmentData) async {
    if (!isAuthenticated) throw 'User not authenticated';
    
    // Add to user's appointments
    await pushData('users/$currentUserId/appointments', {
      ...appointmentData,
      'createdAt': ServerValue.timestamp,
    });

    // Add to doctor's appointments
    final doctorId = appointmentData['doctorId'];
    await pushData('doctors/$doctorId/appointments', {
      ...appointmentData,
      'userId': currentUserId,
      'createdAt': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> getUserAppointments() {
    if (!isAuthenticated) throw 'User not authenticated';
    return _database
        .child('users/$currentUserId/appointments')
        .orderByChild('createdAt')
        .onValue;
  }

  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> data) async {
    if (!isAuthenticated) throw 'User not authenticated';
    
    // Update user's appointment
    await updateData('users/$currentUserId/appointments/$appointmentId', data);
    
    // Update doctor's appointment
    final appointment = await getData('users/$currentUserId/appointments/$appointmentId');
    if (appointment != null) {
      final doctorId = appointment['doctorId'];
      await updateData('doctors/$doctorId/appointments/$appointmentId', data);
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    if (!isAuthenticated) throw 'User not authenticated';
    
    // Get appointment data before deletion
    final appointment = await getData('users/$currentUserId/appointments/$appointmentId');
    
    // Delete from user's appointments
    await deleteData('users/$currentUserId/appointments/$appointmentId');
    
    // Delete from doctor's appointments
    if (appointment != null) {
      final doctorId = appointment['doctorId'];
      await deleteData('doctors/$doctorId/appointments/$appointmentId');
    }
  }

  // Notification Operations
  Future<void> addNotification(Map<String, dynamic> notificationData) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await pushData('users/$currentUserId/notifications', {
      ...notificationData,
      'read': false,
      'createdAt': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> getNotifications() {
    if (!isAuthenticated) throw 'User not authenticated';
    return _database
        .child('users/$currentUserId/notifications')
        .orderByChild('createdAt')
        .onValue;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await updateData('users/$currentUserId/notifications/$notificationId', {
      'read': true,
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await deleteData('users/$currentUserId/notifications/$notificationId');
  }
} 