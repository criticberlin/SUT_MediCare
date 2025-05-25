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
      final snapshot = await database.ref('users').orderByChild('role').equalTo('doctor').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _doctors = [];
        
        data.forEach((key, value) {
          final userData = value as Map<dynamic, dynamic>;
          _doctors.add(Doctor.fromFirebase(key, userData));
        });

        _error = null;
      } else {
        _doctors = [];
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
      final snapshot = await database.ref('users/$id').get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        return Doctor.fromFirebase(id, userData);
      }
      return null;
    } catch (e) {
      print('Error fetching doctor: $e');
      _error = e.toString();
      return null;
    }
  }
} 