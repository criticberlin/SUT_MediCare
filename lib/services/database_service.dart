import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_user;
import '../models/doctor.dart';
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

  // Get user data by ID
  Future<app_user.User?> getUserById(String userId) async {
    try {
      final snapshot = await _database.child('users/$userId').get();
      if (!snapshot.exists) return null;
      
      final data = snapshot.value as Map<dynamic, dynamic>;
      return app_user.User.fromMap({
        'id': userId,
        ...Map<String, dynamic>.from(data),
      });
    } catch (e) {
      print('Error in getUserById: $e');
      return null;
    }
  }
  
  // Get doctor data by ID
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      final snapshot = await _database.child('doctors/$doctorId').get();
      if (!snapshot.exists) return null;
      
      final data = snapshot.value as Map<dynamic, dynamic>;
      return Doctor.fromMap({
        'id': doctorId,
        ...Map<String, dynamic>.from(data),
      });
    } catch (e) {
      print('Error in getDoctorById: $e');
      return null;
    }
  }
  
  // Get all doctors
  Future<List<Doctor>> getAllDoctors() async {
    try {
      final snapshot = await _database.child('doctors').get();
      if (!snapshot.exists) return [];
      
      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Doctor> doctors = [];
      
      data.forEach((key, value) {
        doctors.add(Doctor.fromMap({
          'id': key,
          ...Map<String, dynamic>.from(value),
        }));
      });
      
      return doctors;
    } catch (e) {
      print('Error in getAllDoctors: $e');
      return [];
    }
  }
  
  // Search doctors by name
  Future<List<Doctor>> searchDoctorsByName(String query) async {
    if (query.isEmpty) return getAllDoctors();
    
    query = query.toLowerCase();
    
    try {
      final doctors = await getAllDoctors();
      return doctors.where((doctor) => 
        doctor.name.toLowerCase().contains(query)
      ).toList();
    } catch (e) {
      print('Error in searchDoctorsByName: $e');
      return [];
    }
  }
  
  // Search doctors by specialty
  Future<List<Doctor>> searchDoctorsBySpecialty(String specialty) async {
    if (specialty.isEmpty) return getAllDoctors();
    
    specialty = specialty.toLowerCase();
    
    try {
      final doctors = await getAllDoctors();
      return doctors.where((doctor) => 
        doctor.specialty.toLowerCase().contains(specialty)
      ).toList();
    } catch (e) {
      print('Error in searchDoctorsBySpecialty: $e');
      return [];
    }
  }
  
  // Get all doctor specialties for categories
  Future<List<String>> getAllSpecialties() async {
    try {
      final doctors = await getAllDoctors();
      final Set<String> specialties = {};
      
      for (final doctor in doctors) {
        specialties.add(doctor.specialty);
      }
      
      return specialties.toList()..sort();
    } catch (e) {
      print('Error in getAllSpecialties: $e');
      return [];
    }
  }
  
  // Update user data by ID
  Future<void> updateUserById(String userId, Map<String, dynamic> data) async {
    try {
      final userRef = _database.child('users/$userId');
      await userRef.update(data);
      
      // If this is a doctor, also update in doctors collection
      final userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        if (userData['role'] == 'Doctor') {
          await _database.child('doctors/$userId').update(data);
        }
      }
    } catch (e) {
      print('Error in updateUserById: $e');
      rethrow;
    }
  }
  
  // Mark user as online
  Future<void> setUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _database.child('users/$userId').update({
        'isOnline': isOnline,
        'lastActive': ServerValue.timestamp,
      });
      
      // If this is a doctor, also update in doctors collection
      final userSnapshot = await _database.child('users/$userId').get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        if (userData['role'] == 'Doctor') {
          await _database.child('doctors/$userId').update({
            'isOnline': isOnline,
          });
        }
      }
    } catch (e) {
      print('Error in setUserOnlineStatus: $e');
    }
  }
  
  // Get recently active doctors
  Future<List<Doctor>> getRecentlyActiveDoctors({int limit = 10}) async {
    try {
      final snapshot = await _database.child('doctors')
          .orderByChild('lastActive')
          .limitToLast(limit)
          .get();
      
      if (!snapshot.exists) return [];
      
      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Doctor> doctors = [];
      
      data.forEach((key, value) {
        doctors.add(Doctor.fromMap({
          'id': key,
          ...Map<String, dynamic>.from(value),
        }));
      });
      
      // Sort by lastActive in descending order
      doctors.sort((a, b) => 0); // This will be replaced with proper sorting when we add lastActive to Doctor model
      
      return doctors;
    } catch (e) {
      print('Error in getRecentlyActiveDoctors: $e');
      return [];
    }
  }
  
  // Get doctors with highest ratings
  Future<List<Doctor>> getTopRatedDoctors({int limit = 10}) async {
    try {
      final snapshot = await _database.child('doctors')
          .orderByChild('rating')
          .limitToLast(limit)
          .get();
      
      if (!snapshot.exists) return [];
      
      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Doctor> doctors = [];
      
      data.forEach((key, value) {
        doctors.add(Doctor.fromMap({
          'id': key,
          ...Map<String, dynamic>.from(value),
        }));
      });
      
      // Sort by rating in descending order
      doctors.sort((a, b) => b.rating.compareTo(a.rating));
      
      return doctors;
    } catch (e) {
      print('Error in getTopRatedDoctors: $e');
      return [];
    }
  }
} 