import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../utils/theme/theme_provider.dart';
import '../../utils/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Please sign in to view your profile',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileStats(context, user),
                const SizedBox(height: 20),
                _buildProfileMenu(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, User user) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          AppTheme.primaryColor.withOpacity(0.8),
                          AppTheme.darkBackgroundColor,
                        ]
                      : [
                          AppTheme.primaryColor.withOpacity(0.8),
                          AppTheme.primaryColor.withOpacity(0.4),
                        ],
                ),
              ),
            ),
            // Profile content
            Padding(
              padding: EdgeInsets.only(
                top: statusBarHeight + 30,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile picture
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        // Using a default profile image - in a real app, this would use the user's image
                        image: DecorationImage(
                          image: user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // User name
                  Text(
                    user.role == 'Doctor' ? 'Dr. ${user.name}' : user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // User email
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  // Add role-specific info
                  const SizedBox(height: 4),
                  if (user.role == 'Doctor')
                    Text(
                      user.specialization ?? 'Medical Specialist',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context, User user) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    // Different stats based on user role
    List<Map<String, dynamic>> stats = [];
    
    if (user.role == 'Doctor') {
      stats = [
        {
          'value': user.experience ?? '0',
          'label': 'Years Exp.',
          'icon': Icons.work_outline,
        },
        {
          'value': user.patients ?? '0',
          'label': 'Patients',
          'icon': Icons.people_outline,
        },
        {
          'value': user.rating != null ? '${user.rating}/5' : '4.5/5',
          'label': 'Rating',
          'icon': Icons.star_outline,
        },
      ];
    } else {
      // For patients
      stats = [
        {
          'value': user.appointments ?? '0',
          'label': 'Visits',
          'icon': Icons.calendar_today_outlined,
        },
        {
          'value': user.prescriptions ?? '0',
          'label': 'Prescriptions',
          'icon': Icons.medical_services_outlined,
        },
        {
          'value': user.reports ?? '0',
          'label': 'Reports',
          'icon': Icons.description_outlined,
        },
      ];
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats.map((stat) {
          return Expanded(
            child: Column(
              children: [
                Icon(
                  stat['icon'] as IconData,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'].toString(),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.user;
    
    if (user == null) {
      return const SizedBox.shrink();
    }
    
    // Common options for all users
    final List<Map<String, dynamic>> options = [
      {
        'icon': Icons.person_outline,
        'title': 'Personal Information',
        'subtitle': 'View and update your details',
        'route': user.role == 'Doctor' ? AppRoutes.doctorProfileForm : AppRoutes.patientProfileForm,
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Manage your notifications',
        'route': AppRoutes.notifications,
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Privacy & Security',
        'subtitle': 'Manage your account security',
        'route': AppRoutes.settings,
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'Get help and contact support',
        'route': AppRoutes.helpSupport,
      },
    ];
    
    // Add role-specific options
    if (user.role == 'Patient') {
      // Insert at index 1 for patient-specific options
      options.insert(1, {
        'icon': Icons.medical_services_outlined,
        'title': 'Medical History',
        'subtitle': 'View your medical records',
        'route': AppRoutes.medicalHistory,
      });
      
      options.insert(2, {
        'icon': Icons.payment_outlined,
        'title': 'Payment Methods',
        'subtitle': 'Manage your payment options',
        'route': AppRoutes.paymentMethods,
      });
    } else if (user.role == 'Doctor') {
      // Insert at index 1 for doctor-specific options
      options.insert(1, {
        'icon': Icons.people_outline,
        'title': 'My Patients',
        'subtitle': 'View and manage your patients',
        'route': AppRoutes.doctorPatients,
      });
      
      options.insert(2, {
        'icon': Icons.calendar_today_outlined,
        'title': 'Schedule',
        'subtitle': 'Manage your availability',
        'route': AppRoutes.doctorSchedule,
      });
    }
    
    // Add logout option at the end
    options.add({
      'icon': Icons.logout,
      'title': 'Logout',
      'subtitle': 'Sign out of your account',
      'isLogout': true,
    });

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Account Settings'),
          const SizedBox(height: 16),
          ...options.map((option) => _buildMenuOption(
                context,
                icon: option['icon'] as IconData,
                title: option['title'] as String,
                subtitle: option['subtitle'] as String,
                route: option['route'] as String?,
                isLogout: option['isLogout'] as bool,
              )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : AppTheme.textPrimaryColor,
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String? route,
    bool isLogout = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isLogout) {
            _showLogoutDialog(context);
          } else if (route != null) {
            Navigator.pushNamed(context, route, arguments: authProvider.user);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isLogout
                      ? Colors.red.withOpacity(0.1)
                      : isDarkMode
                          ? AppTheme.primaryColor.withOpacity(0.15)
                          : AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.red : AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isLogout
                            ? Colors.red
                            : isDarkMode
                                ? Colors.white
                                : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await authProvider.signOut();
              // Navigate to login screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 