import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart' as app_user;
import '../../providers/auth_provider.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../routes.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class DoctorProfileForm extends StatefulWidget {
  // Can be either a User object or registration data map
  final dynamic userData;
  
  const DoctorProfileForm({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  _DoctorProfileFormState createState() => _DoctorProfileFormState();
}

class _DoctorProfileFormState extends State<DoctorProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _aboutController = TextEditingController();
  
  // Track if this is a new user registration or profile update
  bool _isNewRegistration = false;
  late Map<String, dynamic> _registrationData;
  app_user.User? _existingUser;
  
  List<String> _languages = [];
  final _newLanguageController = TextEditingController();
  
  List<String> _services = [];
  final _newServiceController = TextEditingController();
  
  List<String> _acceptedInsurance = [];
  final _newInsuranceController = TextEditingController();
  
  Map<String, bool> _workingDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  
  String _startTime = '09:00';
  String _endTime = '17:00';
  
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
    _specializationController.text = _existingUser!.specialization ?? '';
    _qualificationsController.text = _existingUser!.qualifications ?? '';
    _licenseNumberController.text = _existingUser!.licenseNumber ?? '';
    _hospitalController.text = _existingUser!.hospital ?? '';
    _addressController.text = _existingUser!.address ?? '';
    _experienceController.text = _existingUser!.yearsOfExperience?.toString() ?? '';
    _consultationFeeController.text = _existingUser!.consultationFee?.toString() ?? '';
    _languages = _existingUser!.languages ?? [];
    _acceptedInsurance = _existingUser!.acceptedInsurance ?? [];
    
    // Initialize availability if exists
    if (_existingUser!.availability != null) {
      final availability = _existingUser!.availability!;
      if (availability.containsKey('days')) {
        final days = availability['days'] as Map<dynamic, dynamic>;
        days.forEach((key, value) {
          if (_workingDays.containsKey(key)) {
            _workingDays[key] = value as bool;
          }
        });
      }
      
      _startTime = availability['startTime'] as String? ?? '09:00';
      _endTime = availability['endTime'] as String? ?? '17:00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _qualificationsController.dispose();
    _licenseNumberController.dispose();
    _hospitalController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _consultationFeeController.dispose();
    _aboutController.dispose();
    _newLanguageController.dispose();
    _newServiceController.dispose();
    _newInsuranceController.dispose();
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
          try {
            // Create user using the auth provider instead of directly
            final success = await authProvider.register(
              _registrationData['email'],
              _registrationData['password'],
              _nameController.text,
              'Doctor',
            );
            
            if (!success) {
              throw Exception('Failed to register user');
            }
            
            // Get the current user ID from Firebase Auth
            final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
            if (currentUser == null) {
              throw Exception('Failed to get current user after registration');
            }
            
            userId = currentUser.uid;
          } catch (e) {
            throw Exception('Failed to register: ${e.toString()}');
          }
        } else {
          // Use existing user ID
          userId = _existingUser!.id;
        }
        
        // Prepare user data
        final database = FirebaseDatabase.instance;
        final userRef = database.ref('users/Doctors/$userId');
        final flatUserRef = database.ref('users/$userId');
        final doctorRef = database.ref('doctors/$userId');
        
        // Prepare user data
        final userData = {
          'id': userId,
          'name': _nameController.text,
          'email': _isNewRegistration ? _registrationData['email'] : _existingUser!.email,
          'role': 'Doctor',
          'phone': _phoneController.text,
          'specialization': _specializationController.text,
          'qualifications': _qualificationsController.text,
          'licenseNumber': _licenseNumberController.text,
          'hospital': _hospitalController.text,
          'address': _addressController.text,
          'yearsOfExperience': _experienceController.text.isNotEmpty ? int.parse(_experienceController.text) : 0,
          'consultationFee': _consultationFeeController.text.isNotEmpty ? double.parse(_consultationFeeController.text) : 0,
          'about': _aboutController.text,
          'languages': _languages,
          'services': _services,
          'acceptedInsurance': _acceptedInsurance,
          'availability': {
            'days': _workingDays,
            'startTime': _startTime,
            'endTime': _endTime,
          },
          'isVerified': false, // Set to false, admin will verify
          'isProfileComplete': true,
          'updatedAt': ServerValue.timestamp,
        };
        
        // Also create a doctor entry in the doctors collection
        final doctorData = {
          'id': userId,
          'name': 'Dr. ${_nameController.text}',
          'specialty': _specializationController.text,
          'imageUrl': 'assets/images/doctor_placeholder.png', // Default image
          'rating': 4.0, // Default rating
          'experience': _experienceController.text.isNotEmpty ? int.parse(_experienceController.text) : 0,
          'hospital': _hospitalController.text,
          'patients': 0, // New doctor has no patients yet
          'about': _aboutController.text.isEmpty ? 'No information available.' : _aboutController.text,
          'address': _addressController.text,
          'workingHours': ['${_startTime} - ${_endTime}'],
          'services': _services,
          'reviews': [],
          'isOnline': false,
        };
        
        // Update user data in both locations - use set instead of update for complete replacement
        await userRef.set(userData);
        await flatUserRef.set(userData);
        await doctorRef.set(doctorData);
        
        // If this is a new registration, sign in the user
        if (_isNewRegistration) {
          await authProvider.signIn(
            _registrationData['email'],
            _registrationData['password'],
          );
        } else {
          // Mark profile as complete for existing users
          await authProvider.markProfileComplete();
        }
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
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
        // Handle errors properly
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
        title: const Text('Complete Doctor Profile'),
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
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Professional Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _specializationController,
                      decoration: const InputDecoration(
                        labelText: 'Specialization',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your specialization';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _qualificationsController,
                      decoration: const InputDecoration(
                        labelText: 'Qualifications',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                        hintText: 'e.g., MBBS, MD, MS, DNB',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your qualifications';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your license number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hospitalController,
                      decoration: const InputDecoration(
                        labelText: 'Hospital/Clinic',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your hospital or clinic name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _experienceController,
                            decoration: const InputDecoration(
                              labelText: 'Years of Experience',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timeline),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _consultationFeeController,
                            decoration: const InputDecoration(
                              labelText: 'Consultation Fee',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _aboutController,
                      decoration: const InputDecoration(
                        labelText: 'About Yourself',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                        hintText: 'Brief description of your practice and expertise',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Languages Spoken',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildListInput(
                      'Languages',
                      _languages,
                      _newLanguageController,
                      Icons.language,
                    ),
                    const SizedBox(height: 16),
                    _buildListInput(
                      'Services Offered',
                      _services,
                      _newServiceController,
                      Icons.medical_services,
                    ),
                    const SizedBox(height: 16),
                    _buildListInput(
                      'Accepted Insurance',
                      _acceptedInsurance,
                      _newInsuranceController,
                      Icons.health_and_safety,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Working Hours',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildWorkingHours(),
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
            child: Wrap(
              spacing: 8,
              children: items
                  .asMap()
                  .entries
                  .map(
                    (entry) => Chip(
                      label: Text(entry.value),
                      deleteIcon: const Icon(Icons.cancel, size: 16),
                      onDeleted: () => _removeItem(entry.key, items),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildWorkingHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Working Days',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _workingDays.entries.map((entry) {
                  return FilterChip(
                    label: Text(entry.key.substring(0, 3)),
                    selected: entry.value,
                    onSelected: (value) {
                      setState(() {
                        _workingDays[entry.key] = value;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Working Hours',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _startTime,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                      ),
                      items: _generateTimeDropdownItems(),
                      onChanged: (value) {
                        setState(() {
                          _startTime = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _endTime,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                      ),
                      items: _generateTimeDropdownItems(),
                      onChanged: (value) {
                        setState(() {
                          _endTime = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  List<DropdownMenuItem<String>> _generateTimeDropdownItems() {
    List<DropdownMenuItem<String>> items = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        items.add(DropdownMenuItem(
          value: timeString,
          child: Text(timeString),
        ));
      }
    }
    return items;
  }
} 