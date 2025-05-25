import 'package:firebase_database/firebase_database.dart';

class PaymentService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Get payment methods for a user
  Future<List<Map<String, dynamic>>> getPaymentMethods(String userId) async {
    try {
      final ref = _database.ref('payment_methods/$userId');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> paymentMethods = [];
        
        data.forEach((key, value) {
          final method = value as Map<dynamic, dynamic>;
          paymentMethods.add({
            'id': key,
            'cardNumber': method['cardNumber'],
            'cardholderName': method['cardholderName'],
            'expiryDate': method['expiryDate'],
            'cardType': method['cardType'],
            'isDefault': method['isDefault'] ?? false,
          });
        });
        
        // Sort by default card first
        paymentMethods.sort((a, b) {
          if (a['isDefault'] && !b['isDefault']) return -1;
          if (!a['isDefault'] && b['isDefault']) return 1;
          return 0;
        });
        
        return paymentMethods;
      }
      return [];
    } catch (e) {
      print('Error getting payment methods: $e');
      rethrow;
    }
  }

  // Add a new payment method
  Future<String> addPaymentMethod(String userId, Map<String, dynamic> paymentMethod) async {
    try {
      final ref = _database.ref('payment_methods/$userId');
      
      // Check if this is the first card (make it default)
      final snapshot = await ref.get();
      if (!snapshot.exists) {
        paymentMethod['isDefault'] = true;
      }
      
      // Add timestamp
      paymentMethod['createdAt'] = ServerValue.timestamp;
      
      // Push new payment method
      final newRef = ref.push();
      await newRef.set(paymentMethod);
      
      // Return the new ID
      return newRef.key ?? '';
    } catch (e) {
      print('Error adding payment method: $e');
      rethrow;
    }
  }

  // Update a payment method
  Future<void> updatePaymentMethod(String userId, String paymentId, Map<String, dynamic> updates) async {
    try {
      final ref = _database.ref('payment_methods/$userId/$paymentId');
      await ref.update(updates);
    } catch (e) {
      print('Error updating payment method: $e');
      rethrow;
    }
  }

  // Delete a payment method
  Future<void> deletePaymentMethod(String userId, String paymentId) async {
    try {
      final ref = _database.ref('payment_methods/$userId/$paymentId');
      await ref.remove();
      
      // If the deleted card was the default card, make another one default if available
      final methodsRef = _database.ref('payment_methods/$userId');
      final snapshot = await methodsRef.get();
      
      if (snapshot.exists) {
        final methods = snapshot.value as Map<dynamic, dynamic>;
        if (methods.isNotEmpty) {
          // Check if any card is already default
          bool hasDefault = false;
          String firstCardId = '';
          
          methods.forEach((key, value) {
            if (firstCardId.isEmpty) {
              firstCardId = key;
            }
            if (value['isDefault'] == true) {
              hasDefault = true;
            }
          });
          
          // If no default card is found, set the first card as default
          if (!hasDefault && firstCardId.isNotEmpty) {
            await methodsRef.child(firstCardId).update({'isDefault': true});
          }
        }
      }
    } catch (e) {
      print('Error deleting payment method: $e');
      rethrow;
    }
  }

  // Set a payment method as default
  Future<void> setDefaultPaymentMethod(String userId, String paymentId) async {
    try {
      final methodsRef = _database.ref('payment_methods/$userId');
      final snapshot = await methodsRef.get();
      
      if (snapshot.exists) {
        final methods = snapshot.value as Map<dynamic, dynamic>;
        
        // Update all payment methods
        for (var key in methods.keys) {
          final isDefault = key == paymentId;
          await methodsRef.child(key).update({'isDefault': isDefault});
        }
      }
    } catch (e) {
      print('Error setting default payment method: $e');
      rethrow;
    }
  }
} 