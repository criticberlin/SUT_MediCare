import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:firebase_database/firebase_database.dart';
import '../routes.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  app_user.User? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _userSubscription;
  bool _isAuthenticated = false;

  app_user.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _init();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _init() {
    _userSubscription = _authService.authStateChanges.listen(
      (firebaseUser) async {
        print('Auth state changed: ${firebaseUser?.uid}');
        if (firebaseUser == null) {
          _user = null;
          _isAuthenticated = false;
          _error = null;
          notifyListeners();
          return;
        }

        try {
          // Limit retries on fetching user data
          int retries = 0;
          const maxRetries = 3;
          bool success = false;

          while (retries < maxRetries && !success) {
            try {
              // Only fetch user data if we have a valid Firebase user
              final database = FirebaseDatabase.instance;
              final userSnapshot = await database.ref('users/${firebaseUser.uid}').get();
              
              if (userSnapshot.exists) {
                final userData = userSnapshot.value as Map<dynamic, dynamic>;
                _user = app_user.User.fromMap({
                  'id': firebaseUser.uid,
                  ...userData,
                });
                _isAuthenticated = true;
                _error = null;
                success = true;
              } else {
                // Handle case where user auth exists but not in database yet
                // This can happen during registration before DB write completes
                await Future.delayed(Duration(seconds: 1));
                retries++;
                
                if (retries >= maxRetries) {
                  _user = null;
                  _isAuthenticated = false;
                  _error = 'User data not found in database';
                }
              }
            } catch (e) {
              print('Error fetching user data (attempt ${retries+1}): $e');
              retries++;
              await Future.delayed(Duration(seconds: 1));
              
              if (retries >= maxRetries) {
                _user = null;
                _isAuthenticated = false;
                _error = e.toString();
              }
            }
          }
        } catch (e) {
          print('Error in auth state handler: $e');
          _user = null;
          _isAuthenticated = false;
          _error = e.toString();
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error in auth state stream: $error');
        _error = error.toString();
        _user = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    );
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Starting sign in process...');
      await _authService.signInWithEmailAndPassword(email, password);
      // The auth state listener will handle the database check and user data loading
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error during sign in: $e');
      _error = e.toString();
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Starting registration process...');
      final userCredential = await _authService.registerWithEmailAndPassword(email, password, name, role);
      
      // Make sure user data is properly written to database before proceeding
      if (userCredential != null && userCredential.user != null) {
        // Wait for database write to complete
        final userId = userCredential.user!.uid;
        await Future.delayed(Duration(milliseconds: 500));
        
        // Verify user data was written
        final database = FirebaseDatabase.instance;
        final userSnapshot = await database.ref('users/$userId').get();
        
        if (!userSnapshot.exists) {
          // If data doesn't exist, it might still be writing - wait a bit more
          await Future.delayed(Duration(seconds: 1));
        }
      }
      
      print('Registration completed successfully');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error during registration: $e');
      _error = e.toString();
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firebaseUser = await _authService.signInWithGoogle();
      _user = await app_user.User.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Starting sign out process...');
      await _authService.signOut();
      _user = null;
      _isAuthenticated = false;
      _error = null;
      print('Sign out completed successfully');
    } catch (e) {
      print('Error during sign out: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Starting password reset process...');
      await _authService.resetPassword(email);
      _error = null;
      print('Password reset email sent successfully');
    } catch (e) {
      print('Error during password reset: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? gender,
    String? profileImage,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        name: name,
        phone: phone,
        gender: gender,
        profileImage: profileImage,
      );
      
      // Update user in Firebase Database
      final database = FirebaseDatabase.instance;
      await database.ref('users/${_user!.id}').update(updatedUser.toMap());
      
      _user = updatedUser;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getInitialRoute() {
    if (!_isAuthenticated || _user == null) {
      return AppRoutes.login;
    }

    // If the user is a doctor and hasn't completed their profile
    if (_user!.role == 'doctor' && 
        (_user!.specialization == null || 
         _user!.yearsOfExperience == null || 
         _user!.qualifications == null || 
         _user!.licenseNumber == null)) {
      return AppRoutes.doctorProfileForm;
    }

    // If the user is a patient and hasn't completed their profile
    if (_user!.role == 'patient' && 
        (_user!.phone == null || 
         _user!.address == null || 
         _user!.dateOfBirth == null || 
         _user!.gender == null)) {
      return AppRoutes.patientProfileForm;
    }

    // If the user has completed their profile
    return AppRoutes.home;
  }
} 