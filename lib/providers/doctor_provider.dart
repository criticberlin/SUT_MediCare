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
      print('Fetching doctors from database...');
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
            print('Loaded doctor: ${doctorData['name']}');
          } catch (e) {
            print('Error parsing doctor data: $e');
          }
        });
        
        print('Fetched ${_doctors.length} doctors from doctors collection');
      } else {
        // If no specialized doctor collection, try from users with role=Doctor
        print('No doctors collection found, trying users with Doctor role...');
        final usersSnapshot = await database.ref('users').orderByChild('role').equalTo('Doctor').get();
        
        if (usersSnapshot.exists) {
          final data = usersSnapshot.value as Map<dynamic, dynamic>;
          _doctors = [];
          
          data.forEach((key, value) {
            final userData = value as Map<dynamic, dynamic>;
            try {
              _doctors.add(Doctor.fromFirebase(key, userData));
              print('Loaded doctor from users: ${userData['name']}');
            } catch (e) {
              print('Error parsing doctor data from user: $e');
            }
          });
          
          print('Fetched ${_doctors.length} doctors from users collection');
        } else {
          print('No doctors found in either collection');
          _doctors = [];
          _error = 'No doctors found';
        }
      }
      
      // If still no doctors, try from users/Doctors path
      if (_doctors.isEmpty) {
        print('Trying users/Doctors path...');
        final doctorsInRolePath = await database.ref('users/Doctors').get();
        
        if (doctorsInRolePath.exists) {
          final data = doctorsInRolePath.value as Map<dynamic, dynamic>;
          
          data.forEach((key, value) {
            final doctorData = value as Map<dynamic, dynamic>;
            try {
              _doctors.add(Doctor.fromFirebase(key, doctorData));
              print('Loaded doctor from users/Doctors: ${doctorData['name']}');
            } catch (e) {
              print('Error parsing doctor data from users/Doctors: $e');
            }
          });
          
          print('Fetched ${_doctors.length} doctors from users/Doctors path');
        }
      }
      
      _error = null;
    } catch (e) {
      print('Error fetching doctors: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get a specific doctor by ID
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      final database = FirebaseDatabase.instance;
      
      // First try in the doctors collection
      final doctorSnapshot = await database.ref('doctors/$doctorId').get();
      
      if (doctorSnapshot.exists) {
        final doctorData = doctorSnapshot.value as Map<dynamic, dynamic>;
        return Doctor.fromMap({
          'id': doctorId,
          ...Map<String, dynamic>.from(doctorData),
        });
      }
      
      // If not found, try in users with role=Doctor
      final userSnapshot = await database.ref('users/$doctorId').get();
      
      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        if (userData['role'] == 'Doctor') {
          return Doctor.fromFirebase(doctorId, userData);
        }
      }
      
      // If still not found, try in users/Doctors path
      final doctorInRolePath = await database.ref('users/Doctors/$doctorId').get();
      
      if (doctorInRolePath.exists) {
        final doctorData = doctorInRolePath.value as Map<dynamic, dynamic>;
        return Doctor.fromFirebase(doctorId, doctorData);
      }
      
      return null;
    } catch (e) {
      print('Error getting doctor by ID: $e');
      return null;
    }
  }
} 