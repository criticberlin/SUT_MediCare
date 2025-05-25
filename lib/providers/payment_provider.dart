import 'package:flutter/foundation.dart';
import '../services/payment_service.dart';
import 'auth_provider.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  final AuthProvider _authProvider;
  
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;
  
  PaymentProvider(this._authProvider) {
    if (_authProvider.isAuthenticated) {
      fetchPaymentMethods();
    }
    
    // Listen for auth changes
    _authProvider.addListener(_onAuthChanged);
  }
  
  void _onAuthChanged() {
    if (_authProvider.isAuthenticated) {
      fetchPaymentMethods();
    } else {
      _paymentMethods = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPaymentMethods() async {
    if (!_authProvider.isAuthenticated || _authProvider.user == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userId = _authProvider.user!.id;
      _paymentMethods = await _paymentService.getPaymentMethods(userId);
      _error = null;
    } catch (e) {
      print('Error fetching payment methods: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<String?> addPaymentMethod(Map<String, dynamic> paymentMethod) async {
    if (!_authProvider.isAuthenticated || _authProvider.user == null) return null;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userId = _authProvider.user!.id;
      final paymentId = await _paymentService.addPaymentMethod(userId, paymentMethod);
      await fetchPaymentMethods();
      return paymentId;
    } catch (e) {
      print('Error adding payment method: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<bool> updatePaymentMethod(String paymentId, Map<String, dynamic> updates) async {
    if (!_authProvider.isAuthenticated || _authProvider.user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userId = _authProvider.user!.id;
      await _paymentService.updatePaymentMethod(userId, paymentId, updates);
      await fetchPaymentMethods();
      return true;
    } catch (e) {
      print('Error updating payment method: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deletePaymentMethod(String paymentId) async {
    if (!_authProvider.isAuthenticated || _authProvider.user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userId = _authProvider.user!.id;
      await _paymentService.deletePaymentMethod(userId, paymentId);
      await fetchPaymentMethods();
      return true;
    } catch (e) {
      print('Error deleting payment method: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> setDefaultPaymentMethod(String paymentId) async {
    if (!_authProvider.isAuthenticated || _authProvider.user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userId = _authProvider.user!.id;
      await _paymentService.setDefaultPaymentMethod(userId, paymentId);
      await fetchPaymentMethods();
      return true;
    } catch (e) {
      print('Error setting default payment method: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 