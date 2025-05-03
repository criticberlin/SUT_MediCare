import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = User.getCurrentUser();
  }

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.pushNamed(
      context, 
      AppRoutes.editProfile,
      arguments: _user,
    );
    
    if (updatedUser != null && updatedUser is User) {
      setState(() {
        _user = updatedUser;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
  
  void _navigateToMedicalHistory() {
    Navigator.pushNamed(context, AppRoutes.medicalHistory);
  }
  
  void _navigateToPaymentMethods() {
    Navigator.pushNamed(context, AppRoutes.paymentMethods);
  }
  
  void _navigateToSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }
  
  void _navigateToHelpSupport() {
    Navigator.pushNamed(context, AppRoutes.helpSupport);
  }
  
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // In a real app, this would clear user session and token
              // For now, just navigate to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
              _buildProfileCard(),
              _buildOptionsList(),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Badge(
                  isLabelVisible: true,
                  child: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimaryColor),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimaryColor),
                onPressed: _navigateToSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'profile_image',
                child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    _user.profileImage ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 40,
                        color: AppTheme.primaryColor,
                      );
                    },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _user.phone ?? 'Not provided',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Edit Profile',
            onTap: _navigateToEditProfile,
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    final options = [
      {
        'title': 'Medical History',
        'icon': Icons.medical_information_outlined,
        'onTap': _navigateToMedicalHistory,
        'color': const Color(0xFF34A853), // Google Green
            },
            {
        'title': 'Payment Methods',
        'icon': Icons.payment_outlined,
        'onTap': _navigateToPaymentMethods,
        'color': const Color(0xFFFBBC05), // Google Yellow
      },
      {
        'title': 'Settings',
        'icon': Icons.settings_outlined,
        'onTap': _navigateToSettings,
        'color': const Color(0xFF9E9E9E), // Google Grey
      },
      {
        'title': 'Help & Support',
        'icon': Icons.support_agent_outlined,
        'onTap': _navigateToHelpSupport,
        'color': const Color(0xFF9C27B0), // Purple
      },
      {
        'title': 'Logout',
        'icon': Icons.logout,
        'onTap': _logout,
        'color': const Color(0xFFEA4335), // Google Red
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 70,
          endIndent: 0,
        ),
        itemBuilder: (context, index) {
          final option = options[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                color: (option['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                option['icon'] as IconData,
                color: option['color'] as Color,
                size: 24,
                            ),
                          ),
            title: Text(
              option['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: option['title'] == 'Logout' ? AppTheme.errorColor : AppTheme.textPrimaryColor,
                  ),
            ),
                  trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
            onTap: option['onTap'] as VoidCallback,
                );
              },
            ),
    );
  }
} 