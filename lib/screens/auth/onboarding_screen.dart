import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      image: 'https://img.freepik.com/free-vector/telemedicine-abstract-concept-illustration_335657-3891.jpg',
      title: 'Find Top Doctors',
      description: 'Connect with thousands of experienced doctors for consultations and treatments.',
    ),
    OnboardingItem(
      image: 'https://img.freepik.com/free-vector/telemedicine-abstract-concept-illustration_335657-3876.jpg',
      title: 'Book Appointments',
      description: 'Schedule in-person or virtual appointments with your preferred doctors in seconds.',
    ),
    OnboardingItem(
      image: 'https://img.freepik.com/free-vector/telemedicine-abstract-concept-illustration_335657-3875.jpg',
      title: 'Virtual Consultations',
      description: 'Connect with doctors through secure video calls from the comfort of your home.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingItems.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _buildPage(_onboardingItems[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _currentPage == _onboardingItems.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onTap: () {
                      if (_currentPage < _onboardingItems.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      }
                    },
                  ),
                  if (_currentPage < _onboardingItems.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: isDarkMode 
                  ? Border.all(color: Colors.grey.shade800, width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                item.image,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    color: isDarkMode 
                      ? AppTheme.primaryColor.withValues(alpha: 0.2) 
                      : AppTheme.accentColor.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    List<Widget> indicators = [];
    for (int i = 0; i < _onboardingItems.length; i++) {
      indicators.add(
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage
                ? AppTheme.primaryColor
                : (isDarkMode 
                    ? AppTheme.darkTextSecondaryColor.withValues(alpha: 0.3)
                    : AppTheme.textSecondaryColor.withValues(alpha: 0.3)),
          ),
        ),
      );
    }
    return indicators;
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
} 