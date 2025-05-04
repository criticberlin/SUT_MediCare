import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../widgets/custom_button.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  int _selectedFaqIndex = -1;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentSupportCategory = 0;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book an appointment?',
      'answer': 'You can book an appointment by going to the doctor\'s profile page and selecting your preferred date and time from the available slots. After confirming the details, you can proceed to payment to complete your booking.'
    },
    {
      'question': 'How do I cancel or reschedule an appointment?',
      'answer': 'To cancel or reschedule an appointment, go to the "Appointments" section in the app, select the appointment you want to modify, and choose either "Cancel" or "Reschedule". If you reschedule, you\'ll be able to select a new time slot. Please note that cancellations made less than 24 hours before the appointment may be subject to a cancellation fee.'
    },
    {
      'question': 'How do video consultations work?',
      'answer': 'Video consultations take place directly in the app. At the scheduled time, go to the "Appointments" section, find your appointment, and click "Join Call". Make sure you have a stable internet connection and your device\'s camera and microphone permissions are enabled for the app.'
    },
    {
      'question': 'How do I update my payment information?',
      'answer': 'You can update your payment information in the "Profile" section under "Payment Methods". Here you can add new payment methods, remove existing ones, or set a default payment method for your appointments.'
    },
    {
      'question': 'How do I update my medical history?',
      'answer': 'Your medical history can be updated in the "Profile" section under "Medical History". You can add allergies, medications, chronic conditions, and upload medical records. This information will be available to doctors during your consultations.'
    },
    {
      'question': 'Is my personal and medical information secure?',
      'answer': 'Yes, we take data security very seriously. All your personal and medical information is encrypted and stored securely in compliance with healthcare privacy laws. We never share your information with third parties without your explicit consent.'
    },
  ];

  final List<Map<String, dynamic>> _supportCategories = [
    {
      'title': 'FAQs',
      'icon': Icons.question_answer_outlined,
      'color': Colors.blueAccent,
    },
    {
      'title': 'Contact Us',
      'icon': Icons.support_agent_outlined,
      'color': Colors.greenAccent,
    },
    {
      'title': 'Help Center',
      'icon': Icons.help_outline_rounded,
      'color': Colors.purpleAccent,
    },
  ];

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'title': 'Live Chat',
      'subtitle': 'Chat with our support team',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.blue,
    },
    {
      'title': 'Call Us',
      'subtitle': '+1 (800) 123-4567',
      'icon': Icons.phone,
      'color': Colors.green,
    },
    {
      'title': 'Email Support',
      'subtitle': 'support@medicare.com',
      'icon': Icons.email_outlined,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _switchCategory(int index) {
    setState(() {
      _currentSupportCategory = index;
      _selectedFaqIndex = -1;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _submitSupportRequest() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // In a real app, this would send the support request to a backend
    // For demo purposes, just simulate a delay and show success message
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _messageController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Your message has been sent. We\'ll get back to you soon.'),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(8),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategorySelector(isDarkMode),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildSelectedCategory(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(bool isDarkMode) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2) 
                : Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _supportCategories.length,
        itemBuilder: (context, index) {
          final bool isSelected = _currentSupportCategory == index;
          final category = _supportCategories[index];
          
          return GestureDetector(
            onTap: () => _switchCategory(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? category['color'].withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1)
                    : isDarkMode 
                        ? Colors.grey.shade800.withValues(red: null, green: null, blue: null, alpha: 0.3)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? category['color'] 
                      : isDarkMode 
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected 
                        ? category['color']
                        : isDarkMode 
                            ? AppTheme.darkTextSecondaryColor
                            : AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category['title'],
                    style: TextStyle(
                      color: isSelected 
                          ? category['color']
                          : isDarkMode 
                              ? AppTheme.darkTextPrimaryColor
                              : AppTheme.textPrimaryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedCategory(bool isDarkMode) {
    switch (_currentSupportCategory) {
      case 0: // FAQs
        return _buildFaqSection(isDarkMode);
      case 1: // Contact Us
        return _buildContactSection(isDarkMode);
      case 2: // Help Center
        return _buildHelpCenterSection(isDarkMode);
      default:
        return _buildFaqSection(isDarkMode);
    }
  }

  Widget _buildFaqSection(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        return _buildAnimatedFaqItem(index, isDarkMode);
      },
    );
  }

  Widget _buildAnimatedFaqItem(int index, bool isDarkMode) {
    final isExpanded = _selectedFaqIndex == index;
    final question = _faqs[index]['question'] ?? '';
    final answer = _faqs[index]['answer'] ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(
        bottom: 12,
        top: index == 0 ? 4 : 0,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppTheme.primaryColor
              : isDarkMode 
                  ? Colors.grey.shade800 
                  : Colors.grey.shade200,
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1)
                : isDarkMode 
                    ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.1)
                    : Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.05),
            blurRadius: isExpanded ? 8 : 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _selectedFaqIndex = isExpanded ? -1 : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                          color: isExpanded
                              ? AppTheme.primaryColor
                              : isDarkMode 
                                  ? AppTheme.darkTextPrimaryColor 
                                  : AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.1)
                              : isDarkMode 
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: isExpanded
                              ? AppTheme.primaryColor
                              : isDarkMode 
                                  ? AppTheme.darkTextSecondaryColor 
                                  : AppTheme.textSecondaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                color: isExpanded
                    ? AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.05 : 0.03)
                    : Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: isExpanded
                          ? AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.2)
                          : isDarkMode 
                              ? Colors.grey.shade800 
                              : Colors.grey.shade200,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      answer,
                      style: TextStyle(
                        color: isDarkMode 
                            ? AppTheme.darkTextSecondaryColor 
                            : AppTheme.textSecondaryColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: isExpanded 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSupportCard(isDarkMode),
          const SizedBox(height: 24),
          _buildContactForm(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHelpCenterSection(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpCenterHeader(isDarkMode),
          const SizedBox(height: 24),
          _buildHelpOptions(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHelpCenterHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purpleAccent.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.7 : 0.9),
            Colors.blueAccent.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.7 : 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Help Center',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Find answers to common questions, learn how to use the app, and get help when you need it.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.8), size: 16),
              const SizedBox(width: 8),
              Text(
                'Tip: Browse our FAQs for quick answers',
                style: TextStyle(
                  color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOptions(bool isDarkMode) {
    final List<Map<String, dynamic>> helpOptions = [
      {
        'title': 'Video Tutorials',
        'description': 'Watch step-by-step guides on how to use the app',
        'icon': Icons.video_library_outlined,
        'color': Colors.red,
      },
      {
        'title': 'User Guides',
        'description': 'Read detailed documentation on app features',
        'icon': Icons.menu_book_outlined,
        'color': Colors.orange,
      },
      {
        'title': 'Troubleshooting',
        'description': 'Solve common problems and technical issues',
        'icon': Icons.build_outlined,
        'color': Colors.teal,
      },
      {
        'title': 'Account Help',
        'description': 'Get assistance with account-related issues',
        'icon': Icons.account_circle_outlined,
        'color': Colors.blue,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: helpOptions.length,
      itemBuilder: (context, index) {
        final option = helpOptions[index];
        return _buildHelpOptionCard(
          option['title'], 
          option['description'], 
          option['icon'], 
          option['color'],
          isDarkMode,
        );
      },
    );
  }

  Widget _buildHelpOptionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2)
                  : Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppTheme.darkTextPrimaryColor 
                    : AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode 
                    ? AppTheme.darkTextSecondaryColor 
                    : AppTheme.textSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.3) 
                : AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(width: 16),
              Text(
                '24/7 Support',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Need help? Our support team is available 24/7 to assist you with any issues or questions you might have.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _supportOptions.map((option) {
              return _buildSupportOptionButton(
                title: option['title'],
                subtitle: option['subtitle'],
                icon: option['icon'],
                color: option['color'],
                isDarkMode: isDarkMode,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
              shape: BoxShape.circle,
              border: isDarkMode
                  ? Border.all(color: Colors.grey.shade800, width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2)
                      : Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2)
                : Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Send us a message',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll get back to you as soon as possible',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800.withValues(red: null, green: null, blue: null, alpha: 0.3) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message here',
                hintStyle: TextStyle(
                  color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
              ),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Send Message',
            onTap: _submitSupportRequest,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
} 