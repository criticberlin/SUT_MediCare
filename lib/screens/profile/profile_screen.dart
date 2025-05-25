import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart' as app_user;
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  app_user.User? _user;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await app_user.User.getCurrentUser();
      if (user != null) {
        setState(() {
          _user = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
          _addressController.text = user.address ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Handle error appropriately
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        // TODO: Upload image to Firebase Storage and update user profile
      }
    } catch (e) {
      print('Error picking image: $e');
      // Handle error appropriately
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user data in Firebase
      await _database.ref('users/${_user!.id}').update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      });

      // Update email in Firebase Auth if changed
      if (_emailController.text != _user!.email) {
        await _auth.currentUser?.updateEmail(_emailController.text);
      }

      // Update local user object
      setState(() {
        _user = _user!.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        );
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(8),
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Failed to update profile'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(8),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } catch (e) {
      print('Error signing out: $e');
      // Handle error appropriately
    }
  }

  void _navigateToProfileForm() {
    if (_user == null) return;

    if (_user!.role == 'doctor') {
      Navigator.of(context).pushNamed(
        AppRoutes.doctorProfileForm,
        arguments: _user,
      );
    } else {
      Navigator.of(context).pushNamed(
        AppRoutes.patientProfileForm,
        arguments: _user,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_user == null) {
      return const Center(
        child: Text('Failed to load user data'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_user!.profileImage != null
                            ? NetworkImage(_user!.profileImage!)
                            : null) as ImageProvider?,
                    child: _profileImage == null && _user!.profileImage == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _user!.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _user!.email,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _user!.role.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_user!.role == 'doctor') ...[
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorDashboard),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Appointments'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorAppointments),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Patients'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorPatients),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Schedule'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorSchedule),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Earnings'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorEarnings),
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Appointment History'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.appointmentHistory),
              ),
              ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text('Medical History'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.medicalHistory),
              ),
            ],
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: _navigateToProfileForm,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupport),
            ),
          ],
        ),
      ),
    );
  }
} 