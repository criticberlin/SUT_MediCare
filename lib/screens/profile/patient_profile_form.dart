import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart' as app_user;
import '../../providers/auth_provider.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../routes.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class PatientProfileForm extends StatefulWidget {
  // Can be either a User object or registration data map
  final dynamic userData;
  
  const PatientProfileForm({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  _PatientProfileFormState createState() => _PatientProfileFormState();
}

class _PatientProfileFormState extends State<PatientProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  // Track if this is a new user registration or profile update
  bool _isNewRegistration = false;
  late Map<String, dynamic> _registrationData;
  app_user.User? _existingUser;
  
  DateTime? _dateOfBirth;
  String? _gender;
  String? _bloodType;
  
  List<String> _allergies = [];
  final _newAllergyController = TextEditingController();

  List<String> _medications = [];
  final _newMedicationController = TextEditingController();

  List<String> _chronicConditions = [];
  final _newConditionController = TextEditingController();
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Determine if this is a new registration or profile update
    if (widget.userData is app_user.User) {
      _isNewRegistration = false;
      _existingUser = widget.userData as app_user.User;
      _initExistingUserData();
    } else if (widget.userData is Map<String, dynamic>) {
      _isNewRegistration = true;
      _registrationData = widget.userData as Map<String, dynamic>;
      _nameController.text = _registrationData['name'] ?? '';
    }
  }
  
  void _initExistingUserData() {
    if (_existingUser == null) return;
    
    _nameController.text = _existingUser!.name;
    _phoneController.text = _existingUser!.phone ?? '';
    _addressController.text = _existingUser!.address ?? '';
    _heightController.text = _existingUser!.height?.toString() ?? '';
    _weightController.text = _existingUser!.weight?.toString() ?? '';
    _dateOfBirth = _existingUser!.dateOfBirth != null ? DateTime.parse(_existingUser!.dateOfBirth!) : null;
    _gender = _existingUser!.gender;
    _bloodType = _existingUser!.bloodType;
    _allergies = _existingUser!.allergies ?? [];
    _medications = _existingUser!.medications ?? [];
    _chronicConditions = _existingUser!.chronicConditions ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _newAllergyController.dispose();
    _newMedicationController.dispose();
    _newConditionController.dispose();
    super.dispose();
  }
  
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        String userId;
        
        // If this is a new registration, create the user first
        if (_isNewRegistration) {
          // Create user in Firebase Auth
          final userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _registrationData['email'],
            password: _registrationData['password'],
          );
          
          userId = userCredential.user!.uid;
          
          // Update display name
          await userCredential.user?.updateDisplayName(_nameController.text);
        } else {
          // Use existing user ID
          userId = _existingUser!.id;
        }
        
        // Prepare user data
        final database = FirebaseDatabase.instance;
        final userRef = database.ref('users/Patients/$userId');
        final flatUserRef = database.ref('users/$userId');
        
        // Prepare user data
        final userData = {
          'id': userId,
          'name': _nameController.text,
          'email': _isNewRegistration ? _registrationData['email'] : _existingUser!.email,
          'role': 'Patient',
          'phone': _phoneController.text,
          'address': _addressController.text,
          'dateOfBirth': _dateOfBirth?.toIso8601String(),
          'gender': _gender,
          'bloodType': _bloodType,
          'height': double.tryParse(_heightController.text),
          'weight': double.tryParse(_weightController.text),
          'allergies': _allergies,
          'medications': _medications,
          'chronicConditions': _chronicConditions,
          'isProfileComplete': true,
          'createdAt': _isNewRegistration ? ServerValue.timestamp : null,
          'updatedAt': ServerValue.timestamp,
        };
        
        // Remove null values to avoid overwriting existing data
        userData.removeWhere((key, value) => value == null);
        
        // Update user data in both locations
        await userRef.update(userData);
        await flatUserRef.update(userData);
        
        // If this is not a new registration, mark profile as complete using the AuthProvider
        if (!_isNewRegistration) {
          await authProvider.markProfileComplete();
        } else {
          // For new registration, sign in the user now
          await authProvider.signIn(
            _registrationData['email'],
            _registrationData['password'],
          );
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to home screen
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      } catch (e) {
        print('Error saving profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }
  
  void _addItem(TextEditingController controller, List<String> list) {
    final value = controller.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        list.add(value);
        controller.clear();
      });
    }
  }
  
  void _removeItem(int index, List<String> list) {
    setState(() {
      list.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dateOfBirth == null
                              ? 'Select Date'
                              : DateFormat('MM/dd/yyyy').format(_dateOfBirth!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _bloodType,
                      decoration: const InputDecoration(
                        labelText: 'Blood Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bloodtype),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'A+', child: Text('A+')),
                        DropdownMenuItem(value: 'A-', child: Text('A-')),
                        DropdownMenuItem(value: 'B+', child: Text('B+')),
                        DropdownMenuItem(value: 'B-', child: Text('B-')),
                        DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                        DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                        DropdownMenuItem(value: 'O+', child: Text('O+')),
                        DropdownMenuItem(value: 'O-', child: Text('O-')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _bloodType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'Height (cm)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.height),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.line_weight),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Medical Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildListInput(
                      'Allergies',
                      _allergies,
                      _newAllergyController,
                      Icons.warning_amber_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildListInput(
                      'Current Medications',
                      _medications,
                      _newMedicationController,
                      Icons.medication,
                    ),
                    const SizedBox(height: 16),
                    _buildListInput(
                      'Chronic Conditions',
                      _chronicConditions,
                      _newConditionController,
                      Icons.health_and_safety,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildListInput(
    String title,
    List<String> items,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add $title',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(icon),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addItem(controller, items),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: items
                  .asMap()
                  .entries
                  .map(
                    (entry) => ListTile(
                      title: Text(entry.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(entry.key, items),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
} 