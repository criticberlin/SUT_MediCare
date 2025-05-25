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
              // First check in the flat user collection for quick lookup
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
                // If not found in flat structure, try to find in role-specific path
                // Try both paths since we don't know the role yet
                final patientSnapshot = await database.ref('users/Patients/${firebaseUser.uid}').get();
                final doctorSnapshot = await database.ref('users/Doctors/${firebaseUser.uid}').get();
                
                if (patientSnapshot.exists) {
                  final userData = patientSnapshot.value as Map<dynamic, dynamic>;
                  _user = app_user.User.fromMap({
                    'id': firebaseUser.uid,
                    ...userData,
                  });
                  _isAuthenticated = true;
                  _error = null;
                  success = true;
                } else if (doctorSnapshot.exists) {
                  final userData = doctorSnapshot.value as Map<dynamic, dynamic>;
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
      
      // The auth state listener will handle loading the user data
      // No need to manually fetch the user here
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

  Future<String> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Create user in Firebase Authentication using the AuthService
      final UserCredential userCredential = await _authService.registerWithEmailAndPassword(
        email, 
        password,
        name,
        role
      );
      
      // Get the user ID
      final String uid = userCredential.user!.uid;
      
      // The data is already stored by registerWithEmailAndPassword in AuthService
      // Just fetch the current user data to update the local state
      final database = FirebaseDatabase.instance;
      final snapshot = await database.ref('users/$uid').get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _user = app_user.User.fromMap({
          'id': uid,
          ...Map<String, dynamic>.from(data),
        });
      }
      
      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      
      return uid;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      print('Error signing up: ${e.message}');
      throw e.message ?? 'Error signing up';
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error signing up: $e');
      throw 'Error signing up';
    }
  }

  bool shouldShowProfileForm() {
    if (_user == null) return false;
    return _user!.isProfileComplete != true;
  }
  
  String? getUserRole() {
    return _user?.role;
  }

  String getInitialRoute() {
    if (!isAuthenticated) {
      return AppRoutes.login;
    }
    
    if (shouldShowProfileForm()) {
      final role = getUserRole();
      if (role == 'Doctor') {
        return AppRoutes.doctorProfileForm;
      } else if (role == 'Patient') {
        return AppRoutes.patientProfileForm;
      }
    }
    
    return AppRoutes.home;
  }

  // Add a method to mark a user's profile as complete
  Future<void> markProfileComplete() async {
    if (_user == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Update the profile complete flag in both database locations
      final database = FirebaseDatabase.instance;
      final updates = {'isProfileComplete': true, 'updatedAt': ServerValue.timestamp};
      
      // Update in flat structure
      await database.ref('users/${_user!.id}').update(updates);
      
      // Update in role-specific path
      final role = _user!.role;
      await database.ref('users/${role}s/${_user!.id}').update(updates);
      
      // Update local user object
      _user = _user!.copyWith(isProfileComplete: true);
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error marking profile complete: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 