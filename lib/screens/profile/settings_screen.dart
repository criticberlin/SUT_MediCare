import 'package:flutter/material.dart';
import '../../utils/theme/app_theme.dart';
import '../../routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  
  final List<String> _availableLanguages = [
    'English',
    'Arabic',
    'French',
    'Spanish',
    'German',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Notification Preferences'),
          _buildSwitchTile(
            title: 'App Notifications',
            subtitle: 'Receive notifications in the app',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            icon: Icons.notifications,
          ),
          _buildSwitchTile(
            title: 'Email Notifications',
            subtitle: 'Receive notifications via email',
            value: _emailNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _emailNotificationsEnabled = value;
              });
            },
            icon: Icons.email_outlined,
          ),
          _buildSwitchTile(
            title: 'SMS Notifications',
            subtitle: 'Receive notifications via SMS',
            value: _smsNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _smsNotificationsEnabled = value;
              });
            },
            icon: Icons.sms_outlined,
          ),
          const SizedBox(height: 16),

          _buildSectionTitle('Privacy Settings'),
          _buildSwitchTile(
            title: 'Location Services',
            subtitle: 'Allow app to access your location',
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
            },
            icon: Icons.location_on_outlined,
          ),
          _buildNavigationTile(
            title: 'Data Usage & Privacy',
            subtitle: 'Manage how your data is used and shared',
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              // Navigate to data usage and privacy screen
            },
          ),
          _buildNavigationTile(
            title: 'Delete Account',
            subtitle: 'Delete your account and all associated data',
            icon: Icons.delete_outline,
            onTap: () {
              _showDeleteAccountDialog();
            },
            iconColor: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),

          _buildSectionTitle('Appearance'),
          _buildSwitchTile(
            title: 'Dark Mode',
            subtitle: 'Enable dark color theme',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // Apply theme change
            },
            icon: Icons.dark_mode_outlined,
          ),
          _buildDropdownTile(
            title: 'Language',
            subtitle: 'Select your preferred language',
            value: _selectedLanguage,
            items: _availableLanguages,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
                // Apply language change
              }
            },
            icon: Icons.language,
          ),
          const SizedBox(height: 16),

          _buildSectionTitle('Security'),
          _buildNavigationTile(
            title: 'Change Password',
            subtitle: 'Update your account password',
            icon: Icons.lock_outline,
            onTap: () {
              // Navigate to change password screen
            },
          ),
          _buildNavigationTile(
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            icon: Icons.security,
            onTap: () {
              // Navigate to 2FA screen
            },
          ),
          const SizedBox(height: 16),

          _buildSectionTitle('About'),
          _buildNavigationTile(
            title: 'About MediCare',
            subtitle: 'Learn more about our app',
            icon: Icons.info_outline,
            onTap: () {
              // Navigate to about screen
            },
          ),
          _buildNavigationTile(
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            icon: Icons.description_outlined,
            onTap: () {
              // Navigate to terms of service screen
            },
          ),
          _buildNavigationTile(
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            icon: Icons.policy_outlined,
            onTap: () {
              // Navigate to privacy policy screen
            },
          ),
          _buildVersionInfo(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: title == 'Delete Account' ? AppTheme.errorColor : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: title == 'Delete Account' ? AppTheme.errorColor.withOpacity(0.7) : null,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textSecondaryColor,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppTheme.textSecondaryColor,
        ),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimaryColor,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildVersionInfo() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'MediCare App',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: AppTheme.errorColor,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Show confirmation dialog
              _showConfirmDeleteDialog();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please type "DELETE" to confirm account deletion:',
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // In a real app, this would delete the account
              // For demo purposes, just navigate to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text(
              'Confirm Delete',
              style: TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 