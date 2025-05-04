import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../utils/theme/theme_provider.dart';
import '../../utils/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User user = User.getCurrentUser();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

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
                          AppTheme.primaryColor.withValues(alpha: 0.8),
                          AppTheme.darkBackgroundColor,
                        ]
                      : [
                          AppTheme.primaryColor.withValues(alpha: 0.8),
                          AppTheme.primaryColor.withValues(alpha: 0.4),
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
                children: [
                  // Profile image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: user.profileImage != null && user.profileImage!.isNotEmpty
                              ? Image.network(
                                  user.profileImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey[200],
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Show image picker
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User name
                  Text(
                    user.name,
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
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: isDarkMode ? Colors.white : Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  Widget _buildProfileStats(BuildContext context, User user) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              context,
              icon: Icons.favorite,
              label: 'Blood Type',
              value: user.bloodType ?? 'N/A',
            ),
            _buildVerticalDivider(isDarkMode),
            _buildStatItem(
              context,
              icon: Icons.straighten,
              label: 'Height',
              value: user.height != null ? '${user.height} cm' : 'N/A',
            ),
            _buildVerticalDivider(isDarkMode),
            _buildStatItem(
              context,
              icon: Icons.monitor_weight_outlined,
              label: 'Weight',
              value: user.weight != null ? '${user.weight} kg' : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDarkMode) {
    return Container(
      height: 50,
      width: 1,
      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    final options = [
      {
        'icon': Icons.person_outline,
        'title': 'Personal Information',
        'subtitle': 'View and update your details',
        'route': '/edit-profile',
      },
      {
        'icon': Icons.medical_services_outlined,
        'title': 'Medical History',
        'subtitle': 'View your medical records',
        'route': '/medical-history',
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Payment Methods',
        'subtitle': 'Manage your payment options',
        'route': '/payment-methods',
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Manage your notifications',
        'route': '/notifications',
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Privacy & Security',
        'subtitle': 'Manage your account security',
        'route': '/privacy-security',
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'Get help and contact support',
        'route': '/help-support',
      },
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'subtitle': 'Sign out from your account',
        'route': null,
      },
    ];

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
                isLogout: option['title'] == 'Logout',
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            Navigator.pushNamed(context, route);
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
                      ? Colors.red.withValues(alpha: 0.1)
                      : isDarkMode
                          ? AppTheme.primaryColor.withValues(alpha: 0.15)
                          : AppTheme.primaryColor.withValues(alpha: 0.1),
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
            onPressed: () {
              // Handle logout
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
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