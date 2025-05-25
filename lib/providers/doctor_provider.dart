import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/doctor.dart';

class DoctorProvider with ChangeNotifier {
  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String? _error;

  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDoctors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final database = FirebaseDatabase.instance;
      
      // First try to get from the doctors collection
      final doctorsSnapshot = await database.ref('doctors').get();
      
      if (doctorsSnapshot.exists) {
        final data = doctorsSnapshot.value as Map<dynamic, dynamic>;
        _doctors = [];
        
        data.forEach((key, value) {
          final doctorData = value as Map<dynamic, dynamic>;
          try {
            _doctors.add(Doctor.fromMap({
              'id': key,
              ...Map<String, dynamic>.from(doctorData),
            }));
          } catch (e) {
            print('Error parsing doctor data: $e');
          }
        });
      } else {
        // If no specialized doctor collection, try from users with role=Doctor
        final usersSnapshot = await database.ref('users').orderByChild('role').equalTo('Doctor').get();
        
        if (usersSnapshot.exists) {
          final data = usersSnapshot.value as Map<dynamic, dynamic>;
          _doctors = [];
          
          data.forEach((key, value) {
            final userData = value as Map<dynamic, dynamic>;
            try {
              _doctors.add(Doctor.fromFirebase(key, userData));
            } catch (e) {
              print('Error parsing doctor data from user: $e');
            }
          });
        } else {
          _doctors = [];
          _error = 'No doctors found';
        }
      }
      
      // If there are still no doctors found in either location
      if (_doctors.isEmpty && _error == null) {
        _error = 'No doctors found';
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Doctor?> getDoctorById(String id) async {
    try {
      final database = FirebaseDatabase.instance;
      
      // First try to get from doctors collection
      final doctorSnapshot = await database.ref('doctors/$id').get();
      
      if (doctorSnapshot.exists) {
        final doctorData = doctorSnapshot.value as Map<dynamic, dynamic>;
        return Doctor.fromMap({
          'id': id,
          ...Map<String, dynamic>.from(doctorData),
        });
      }
      
      // If not found, try from users collection
      final userSnapshot = await database.ref('users/$id').get();
      
      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        if (userData['role'] == 'Doctor') {
          return Doctor.fromFirebase(id, userData);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching doctor: $e');
      _error = e.toString();
      return null;
    }
  }
} 