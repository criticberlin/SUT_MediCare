import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late String _selectedGender;
  late String _selectedBloodType;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _dobController = TextEditingController(text: widget.user.dateOfBirth ?? '');
    _heightController = TextEditingController(text: widget.user.height?.toString() ?? '');
    _weightController = TextEditingController(text: widget.user.weight?.toString() ?? '');
    _selectedGender = widget.user.gender ?? _genders.first;
    _selectedBloodType = widget.user.bloodType ?? _bloodTypes.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Get height and weight values if available
      double? height;
      double? weight;

      if (_heightController.text.isNotEmpty) {
        height = double.tryParse(_heightController.text);
      }

      if (_weightController.text.isNotEmpty) {
        weight = double.tryParse(_weightController.text);
      }

      // Create updated user
      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        dateOfBirth: _dobController.text.isEmpty ? null : _dobController.text,
        gender: _selectedGender,
        bloodType: _selectedBloodType,
        height: height,
        weight: weight,
      );

      // In a real app, this would save to a database or API
      // For now, we'll just simulate a delay and return
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
        
        // Return to previous screen with updated user data
        if (mounted) {
          Navigator.pop(context, updatedUser);
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    final initialDate = widget.user.dateOfBirth != null
        ? DateTime.tryParse(widget.user.dateOfBirth!)
        : DateTime.now().subtract(const Duration(days: 365 * 18)); // Default to 18 years ago
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? ColorScheme.dark(
                    primary: AppTheme.primaryColor,
                    surface: AppTheme.darkCardColor,
                  )
                : const ColorScheme.light(
                    primary: AppTheme.primaryColor,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: isDarkMode ? 0 : 1,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileImage(isDarkMode),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppTheme.primaryColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Date of Birth',
                  hint: 'YYYY-MM-DD',
                  controller: _dobController,
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: AppTheme.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: _selectDate,
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Gender', 
                  value: _selectedGender, 
                  items: _genders,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGender = value;
                      });
                    }
                  },
                  icon: Icons.person_outlined,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Blood Type', 
                  value: _selectedBloodType, 
                  items: _bloodTypes,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedBloodType = value;
                      });
                    }
                  },
                  icon: Icons.bloodtype,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Height (cm)',
                        hint: 'Enter height',
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(
                          Icons.height,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Weight (kg)',
                        hint: 'Enter weight',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(
                          Icons.monitor_weight,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode 
                              ? Colors.grey.shade800 
                              : Colors.grey.shade200,
                          foregroundColor: isDarkMode 
                              ? AppTheme.darkTextPrimaryColor 
                              : AppTheme.textPrimaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Save Changes',
                        onTap: _saveProfile,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(bool isDarkMode) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 77)
                        : Colors.grey.withValues(alpha: 77),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  widget.user.profileImage ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDarkMode ? AppTheme.darkCardColor : const Color(0xFFF7F8F9),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 77)
                          : Colors.grey.withValues(alpha: 77),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: isDarkMode ? Colors.white : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Implement image picker functionality
          },
          child: Text(
            'Change Photo',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkCardColor : const Color(0xFFF7F8F9),
            borderRadius: BorderRadius.circular(24),
            border: isDarkMode
                ? Border.all(color: Colors.grey.shade800, width: 1)
                : null,
            boxShadow: isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 26),
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                  ),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                    fontSize: 16,
                  ),
                  dropdownColor: isDarkMode ? AppTheme.darkCardColor : Colors.white,
                  items: items.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 