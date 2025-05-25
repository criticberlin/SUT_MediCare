import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:firebase_database/firebase_database.dart';

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
          } else {
            _user = null;
            _isAuthenticated = false;
            _error = 'User data not found in database';
          }
        } catch (e) {
          print('Error fetching user data: $e');
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
      return true;
    } catch (e) {
      print('Error during sign in: $e');
      _error = e.toString();
      _user = null;
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Starting registration process...');
      await _authService.registerWithEmailAndPassword(email, password, name, role);
      print('Registration completed successfully');
      return true;
    } catch (e) {
      print('Error during registration: $e');
      _error = e.toString();
      _user = null;
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
} 