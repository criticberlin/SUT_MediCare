import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error during sign in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String name, String role) async {
    try {
      print('Creating user with email: $email and role: $role');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      print('User created successfully: ${userCredential.user?.uid}');
      
      // Create user document in Realtime Database
      await setData('users/${userCredential.user!.uid}', {
        'id': userCredential.user!.uid,
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'isVerified': false,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      return userCredential;
    } catch (e) {
      print('Error in registerWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in aborted';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);

      // Create user document if it doesn't exist
      if (result.additionalUserInfo?.isNewUser ?? false) {
        await setData('users/${result.user!.uid}', {
          'id': result.user!.uid,
          'uid': result.user!.uid,
          'name': result.user?.displayName,
          'email': result.user?.email,
          'role': 'patient', // Default role for Google sign-in
          'isVerified': false,
          'createdAt': ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        });
      }

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out user');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('User signed out successfully');
    } catch (e) {
      print('Error in signOut: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      print('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');
    } catch (e) {
      print('Error in resetPassword: $e');
      rethrow;
    }
  }
} 