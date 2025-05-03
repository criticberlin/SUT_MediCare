import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../utils/theme/app_theme.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
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
                      child: const Text('Skip'),
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            item.image,
            height: 280,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 280,
                color: AppTheme.accentColor.withOpacity(0.1),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
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
                : AppTheme.textSecondaryColor.withOpacity(0.3),
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