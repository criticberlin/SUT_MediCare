import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart'; // ✅ Added

import 'utils/theme/app_theme.dart';
import 'utils/theme/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/doctor_provider.dart';
import 'routes.dart';
import 'models/user.dart' as app_user;

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/doctor/doctor_list_screen.dart';
import 'screens/doctor/doctor_detail_screen.dart';
import 'screens/doctor/appointment_booking_screen.dart';
import 'screens/doctor/appointment_history_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/video/video_call_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/doctor_profile_form.dart';
import 'screens/profile/medical_history_screen.dart';
import 'screens/profile/payment_methods_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/doctor/dashboard_screen.dart';
import 'screens/doctor/appointments_screen.dart';
import 'screens/doctor/patients_screen.dart';
import 'screens/doctor/schedule_screen.dart';
import 'screens/doctor/earnings_screen.dart';

// Models
import 'models/doctor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Test Firebase connection
  try {
    final database = FirebaseDatabase.instance;
    // Set the database URL explicitly to the correct URL
    database.databaseURL = 'https://medicare-app-final-default-rtdb.firebaseio.com';
    // Test with a simple write operation
    await database.ref('test').set({'timestamp': ServerValue.timestamp});
    print('Firebase connection successful!');
    // Clean up test data
    await database.ref('test').remove();
  } catch (e) {
    print('Firebase connection error: $e');
    if (e.toString().contains('permission-denied')) {
      print('Database rules may be too restrictive. Please check your Firebase Console database rules.');
    } else if (e.toString().contains('invalid-token')) {
      print('Authentication token is invalid. Please check your Firebase configuration.');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SUT MediCare',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.splash:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case AppRoutes.onboarding:
                  return MaterialPageRoute(builder: (_) => const OnboardingScreen());
                case AppRoutes.login:
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case AppRoutes.register:
                  return MaterialPageRoute(builder: (_) => const RegisterScreen());
                case AppRoutes.home:
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case AppRoutes.doctorList:
                  return MaterialPageRoute(builder: (_) => const DoctorListScreen());
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
                  return MaterialPageRoute(builder: (_) => const AppointmentHistoryScreen());
                case AppRoutes.chat:
                  final doctorId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      doctorId: doctorId,
                    ),
                  );
                case AppRoutes.chatList:
                  return MaterialPageRoute(builder: (_) => const ChatListScreen());
                case AppRoutes.videoCall:
                  return MaterialPageRoute(
                    builder: (_) => VideoCallScreen(
                      doctor: settings.arguments as Doctor,
                    ),
                  );
                case AppRoutes.prescriptionUpload:
                  return MaterialPageRoute(builder: (_) => const Placeholder());
                case AppRoutes.profile:
                  return MaterialPageRoute(builder: (_) => const ProfileScreen());
                case AppRoutes.notifications:
                  return MaterialPageRoute(builder: (_) => const NotificationsScreen());
                case AppRoutes.settings:
                  return MaterialPageRoute(builder: (_) => const SettingsScreen());
                case AppRoutes.editProfile:
                  final user = settings.arguments as app_user.User?;
                  if (user == null) {
                    return MaterialPageRoute(builder: (_) => const ProfileScreen());
                  }
                  return MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user),
                  );
                case AppRoutes.doctorProfileForm:
                  final user = settings.arguments as app_user.User?;
                  if (user == null) {
                    return MaterialPageRoute(builder: (_) => const ProfileScreen());
                  }
                  return MaterialPageRoute(
                    builder: (_) => DoctorProfileForm(user: user),
                  );
                case AppRoutes.patientProfileForm:
                  final user = settings.arguments as app_user.User?;
                  if (user == null) {
                    return MaterialPageRoute(builder: (_) => const ProfileScreen());
                  }
                  return MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user),
                  );
                case AppRoutes.medicalHistory:
                  return MaterialPageRoute(builder: (_) => const MedicalHistoryScreen());
                case AppRoutes.paymentMethods:
                  return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());
                case AppRoutes.helpSupport:
                  return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
                case AppRoutes.doctorDashboard:
                  return MaterialPageRoute(builder: (_) => const DoctorDashboardScreen());
                case AppRoutes.doctorAppointments:
                  return MaterialPageRoute(builder: (_) => const DoctorAppointmentsScreen());
                case AppRoutes.doctorPatients:
                  return MaterialPageRoute(builder: (_) => const DoctorPatientsScreen());
                case AppRoutes.doctorSchedule:
                  return MaterialPageRoute(builder: (_) => const DoctorScheduleScreen());
                case AppRoutes.doctorEarnings:
                  return MaterialPageRoute(builder: (_) => const DoctorEarningsScreen());
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
        },
      ),
    );
  }
}
