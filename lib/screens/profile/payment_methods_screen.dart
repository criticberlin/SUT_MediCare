import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PaymentMethod {
  final String id;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cardType;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  });

  // Factory method to get dummy payment methods
  static List<PaymentMethod> getDummyPaymentMethods() {
    return [
      PaymentMethod(
        id: '1',
        cardHolderName: 'Mohamed Ahmed',
        cardNumber: '4111 1111 1111 1111',
        expiryDate: '05/24',
        cardType: 'visa',
        isDefault: true,
      ),
      PaymentMethod(
        id: '2',
        cardHolderName: 'Mohamed Ahmed',
        cardNumber: '5500 0000 0000 0004',
        expiryDate: '03/25',
        cardType: 'mastercard',
      ),
    ];
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late List<PaymentMethod> _paymentMethods;

  @override
  void initState() {
    super.initState();
    _paymentMethods = PaymentMethod.getDummyPaymentMethods();
  }

  void _addNewPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddPaymentMethodSheet(),
    ).then((newPaymentMethod) {
      if (newPaymentMethod != null && newPaymentMethod is PaymentMethod) {
        setState(() {
          // If this is the first card, make it default
          if (_paymentMethods.isEmpty) {
            newPaymentMethod = PaymentMethod(
              id: newPaymentMethod.id,
              cardHolderName: newPaymentMethod.cardHolderName,
              cardNumber: newPaymentMethod.cardNumber,
              expiryDate: newPaymentMethod.expiryDate,
              cardType: newPaymentMethod.cardType,
              isDefault: true,
            );
          }
          _paymentMethods.add(newPaymentMethod);
        });
      }
    });
  }

  void _deletePaymentMethod(String id) {
    setState(() {
      _paymentMethods.removeWhere((method) => method.id == id);
    });
  }

  void _setDefaultPaymentMethod(String id) {
    setState(() {
      _paymentMethods = _paymentMethods.map((method) {
        return PaymentMethod(
          id: method.id,
          cardHolderName: method.cardHolderName,
          cardNumber: method.cardNumber,
          expiryDate: method.expiryDate,
          cardType: method.cardType,
          isDefault: method.id == id,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: _paymentMethods.isEmpty
          ? _buildEmptyState()
          : _buildPaymentMethodsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPaymentMethod,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://img.freepik.com/free-vector/mobile-payment-abstract-concept-illustration_335657-3902.jpg',
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'No Payment Methods',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a payment method to make payments easier',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add Payment Method',
            onTap: _addNewPaymentMethod,
            prefixIcon: const Icon(Icons.add, color: Colors.white),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Your saved payment methods',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Securely manage your payment methods',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 24),
        ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    String cardTypeImage;
    
    // Determine card type icon (simplified for the example)
    if (method.cardType.toLowerCase() == 'visa') {
      cardTypeImage = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png';
    } else if (method.cardType.toLowerCase() == 'mastercard') {
      cardTypeImage = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/MasterCard_Logo.svg/2560px-MasterCard_Logo.svg.png';
    } else {
      cardTypeImage = 'https://cdn-icons-png.flaticon.com/512/6404/6404025.png';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: method.isDefault 
                    ? [AppTheme.primaryColor, AppTheme.secondaryColor] 
                    : [Colors.grey.shade700, Colors.grey.shade900],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Credit Card',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'xxxx xxxx xxxx ${method.cardNumber.substring(method.cardNumber.length - 4)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    cardTypeImage,
                    height: 30,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Card Holder Name',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.cardHolderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Expiry Date',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.expiryDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (method.isDefault)
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Default payment method',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  TextButton.icon(
                    onPressed: () => _setDefaultPaymentMethod(method.id),
                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 20,
                    ),
                    label: const Text('Set as default'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondaryColor,
                    ),
                  ),
                IconButton(
                  onPressed: () => _deletePaymentMethod(method.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddPaymentMethodSheet extends StatefulWidget {
  const AddPaymentMethodSheet({super.key});

  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _savePaymentMethod() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Determine card type based on first digits (simplified logic)
      String cardNumber = _cardNumberController.text.replaceAll(' ', '');
      String cardType = 'unknown';
      
      if (cardNumber.startsWith('4')) {
        cardType = 'visa';
      } else if (cardNumber.startsWith('5')) {
        cardType = 'mastercard';
      } else if (cardNumber.startsWith('3')) {
        cardType = 'amex';
      }
      
      // Create new payment method
      final newPaymentMethod = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardHolderName: _cardHolderNameController.text,
        cardNumber: _cardNumberController.text,
        expiryDate: _expiryDateController.text,
        cardType: cardType,
      );
      
      // In a real app, this would save to a database or API
      // For now, we'll just simulate a delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, newPaymentMethod);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 
        16, 
        16, 
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Card Holder Name',
                hint: 'Enter name on card',
                controller: _cardHolderNameController,
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppTheme.primaryColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the card holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Card Number',
                hint: '1234 5678 9012 3456',
                controller: _cardNumberController,
                prefixIcon: const Icon(
                  Icons.credit_card,
                  color: AppTheme.primaryColor,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the card number';
                  }
                  if (value.replaceAll(' ', '').length < 16) {
                    return 'Please enter a valid card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      controller: _expiryDateController,
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppTheme.primaryColor,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryDateFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        if (value.length < 5) {
                          return 'Invalid format';
                        }
                        // Add more validation for date if needed
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'CVV',
                      hint: '123',
                      controller: _cvvController,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.primaryColor,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVV';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Add Card',
                onTap: _savePaymentMethod,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom formatter for card number input
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) {
      return oldValue;
    }
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i % 4 == 3 && i != text.length - 1) {
        buffer.write(' ');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Custom formatter for expiry date input
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) {
      return oldValue;
    }
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && i != text.length - 1) {
        buffer.write('/');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
} 