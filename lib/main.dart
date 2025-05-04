import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme/app_theme.dart';
import 'utils/theme/theme_provider.dart';
import 'routes.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/doctor/doctor_detail_screen.dart';
import 'screens/doctor/appointment_booking_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/video/video_call_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/medical_history_screen.dart';
import 'screens/profile/payment_methods_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/notifications/notifications_screen.dart';

// Models
import 'models/doctor.dart';
import 'models/user.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'MediCare',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );
          case AppRoutes.onboarding:
            return MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            );
          case AppRoutes.login:
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );
          case AppRoutes.register:
            return MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
            );
          case AppRoutes.home:
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
          case AppRoutes.doctorList:
            return MaterialPageRoute(
              builder: (_) => const Placeholder(), // Will be implemented later
            );
          case AppRoutes.doctorDetail:
            return MaterialPageRoute(
              builder: (_) => DoctorDetailScreen(
                doctor: settings.arguments as Doctor,
              ),
            );
          case AppRoutes.appointmentBooking:
            return MaterialPageRoute(
              builder: (_) => AppointmentBookingScreen(
                doctor: settings.arguments as Doctor,
              ),
            );
          case AppRoutes.appointmentHistory:
            return MaterialPageRoute(
              builder: (_) => const Placeholder(), // Will be implemented later
            );
          case AppRoutes.chat:
            return MaterialPageRoute(
              builder: (_) => ChatScreen(
                doctorId: settings.arguments as String,
              ),
            );
          case AppRoutes.chatList:
            return MaterialPageRoute(
              builder: (_) => const ChatListScreen(),
            );
          case AppRoutes.videoCall:
            return MaterialPageRoute(
              builder: (_) => VideoCallScreen(
                doctor: settings.arguments as Doctor,
              ),
            );
          case AppRoutes.prescriptionUpload:
            return MaterialPageRoute(
              builder: (_) => const Placeholder(), // Will be implemented later
            );
          case AppRoutes.profile:
            return MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            );
          case AppRoutes.notifications:
            return MaterialPageRoute(
              builder: (_) => const NotificationsScreen(),
            );
          case AppRoutes.settings:
            return MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            );
          case AppRoutes.editProfile:
            return MaterialPageRoute(
              builder: (_) => EditProfileScreen(
                user: settings.arguments as User? ?? User.getCurrentUser(),
              ),
            );
          case AppRoutes.medicalHistory:
            return MaterialPageRoute(
              builder: (_) => const MedicalHistoryScreen(),
            );
          case AppRoutes.paymentMethods:
            return MaterialPageRoute(
              builder: (_) => const PaymentMethodsScreen(),
            );
          case AppRoutes.helpSupport:
            return MaterialPageRoute(
              builder: (_) => const HelpSupportScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text('Route not found!'),
                ),
              ),
            );
        }
      },
    );
  }
}
