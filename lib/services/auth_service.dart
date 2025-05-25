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
      print('Starting sign in with email: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign in successful for user: ${userCredential.user?.uid}');
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
      
      if (userCredential.user != null) {
        // Create user document in Realtime Database
        final userId = userCredential.user!.uid;
        
        // Create user data map
        final userData = {
          'id': userId,
          'uid': userId,
          'name': name,
          'email': email,
          'role': role,
          'isVerified': false,
          'createdAt': ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        };
        
        // Store user data in the appropriate path based on role
        await setData('users/${role}s/$userId', userData);
        
        // Also store in flat users structure for quick lookup
        await setData('users/$userId', userData);
        
        // Create empty collections for user data
        if (role == 'patient') {
          await setData('medical_history/$userId', {
            'allergies': [],
            'medications': [],
            'conditions': [],
            'updatedAt': ServerValue.timestamp,
          });
        }
        
        // Verify data is properly written
        final userRef = FirebaseDatabase.instance.ref('users/$userId');
        await userRef.get();
      }

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
        final userId = result.user!.uid;
        final role = 'patient'; // Default role for Google sign-in
        
        final userData = {
          'id': userId,
          'uid': userId,
          'name': result.user?.displayName,
          'email': result.user?.email,
          'role': role,
          'isVerified': false,
          'createdAt': ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        };
        
        // Store user data in the appropriate path based on role
        await setData('users/${role}s/$userId', userData);
        
        // Also store in flat users structure for quick lookup
        await setData('users/$userId', userData);
        
        // Create empty collections for user data
        await setData('medical_history/$userId', {
          'allergies': [],
          'medications': [],
          'conditions': [],
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