// routes.dart
// Contains all the named routes for the telemedicine app

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String doctorList = '/doctor-list';
  static const String doctorDetail = '/doctor-detail';
  static const String appointmentBooking = '/appointment-booking';
  static const String appointmentHistory = '/appointment-history';
  static const String chat = '/chat';
  static const String chatList = '/chat-list';
  static const String videoCall = '/video-call';
  static const String prescriptionUpload = '/prescription-upload';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  
  // Profile-related routes
  static const String editProfile = '/edit-profile';
  static const String doctorProfileForm = '/doctor-profile-form';
  static const String patientProfileForm = '/patient-profile-form';
  static const String medicalHistory = '/medical-history';
  static const String paymentMethods = '/payment-methods';
  static const String helpSupport = '/help-support';

  // Doctor-specific routes
  static const String doctorDashboard = '/doctor-dashboard';
  static const String doctorAppointments = '/doctor-appointments';
  static const String doctorPatients = '/doctor-patients';
  static const String doctorSchedule = '/doctor-schedule';
  static const String doctorEarnings = '/doctor-earnings';
} 