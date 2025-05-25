import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Generic method to get data once
  Future<Map<String, dynamic>?> getData(String path) async {
    try {
      final DatabaseEvent event = await _database.child(path).once();
      return event.snapshot.value as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to stream data
  Stream<DatabaseEvent> streamData(String path) {
    return _database.child(path).onValue;
  }

  // Generic method to set data
  Future<void> setData(String path, Map<String, dynamic> data) async {
    try {
      await _database.child(path).set(data);
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to update data
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    try {
      await _database.child(path).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to delete data
  Future<void> deleteData(String path) async {
    try {
      await _database.child(path).remove();
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to push new data
  Future<DatabaseReference> pushData(String path, Map<String, dynamic> data) async {
    try {
      final DatabaseReference ref = _database.child(path).push();
      await ref.set(data);
      return ref;
    } catch (e) {
      rethrow;
    }
  }
} 