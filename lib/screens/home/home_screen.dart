import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../models/user.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../routes.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/appointment_card.dart';
import '../../utils/extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final User _currentUser = User.getCurrentUser();
  final List<Doctor> _doctors = Doctor.getDummyDoctors();
  final List<Appointment> _appointments = Appointment.getDummyAppointments();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 1 ? Icons.medical_services : Icons.medical_services_outlined),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 2 ? Icons.calendar_today : Icons.calendar_today_outlined),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 3 ? Icons.chat_bubble : Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 4 ? Icons.person : Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildDoctorsTab();
      case 2:
        return _buildAppointmentsTab();
      case 3:
        return _buildChatTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildUpcomingAppointmentsSection(),
              const SizedBox(height: 24),
              _buildTopDoctorsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Location',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Cairo, Egypt',
                  style: TextStyle(
                    color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.notifications);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withValues(alpha: 0.2) 
                      : Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                  size: 24,
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Search',
            style: TextStyle(
              color: (isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor).withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune,
              color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentsSection() {
    final upcomingAppointments = _appointments
        .where((appointment) => appointment.status == AppointmentStatus.upcoming)
        .toList();
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    if (upcomingAppointments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Appointments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? AppTheme.darkCardColor 
                  : AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppTheme.primaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Upcoming Appointments',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book your appointment now',
                    style: TextStyle(
                      color: isDarkMode 
                          ? AppTheme.darkTextSecondaryColor 
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Appointments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Switch to appointments tab
                });
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...upcomingAppointments.take(2).map((appointment) {
          return AppointmentCard(
            doctorName: appointment.doctorName,
            doctorSpecialty: appointment.doctorSpecialty,
            doctorImage: appointment.doctorImage,
            appointmentDate: appointment.date,
            appointmentTime: appointment.time,
            status: appointment.status,
            onTap: () {
              final doctor = _getDoctorFromAppointment(appointment);
              Navigator.pushNamed(
                context,
                AppRoutes.appointmentBooking,
                arguments: doctor,
              );
            },
          );
        }),
      ],
    );
  }

  Doctor _getDoctorFromAppointment(Appointment appointment) {
    return _doctors.firstWhere(
      (doctor) => doctor.id == appointment.doctorId,
      orElse: () => _doctors.first,
    );
  }

  Widget _buildCategorySection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    final categories = [
      {
        'icon': Icons.healing_rounded,
        'name': 'Dental',
        'color': const Color(0xFF42A5F5),
      },
      {
        'icon': Icons.favorite_rounded,
        'name': 'Cardiology',
        'color': const Color(0xFFEC407A),
      },
      {
        'icon': Icons.psychology_outlined,
        'name': 'Neurology',
        'color': const Color(0xFFAB47BC),
      },
      {
        'icon': Icons.visibility_outlined,
        'name': 'Ophthalmology',
        'color': const Color(0xFF66BB6A),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Navigate to categories screen
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((category) {
            return GestureDetector(
              onTap: () {
                // Navigate to category specific doctor list
              },
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode 
                              ? Colors.black.withValues(alpha: 0.2) 
                              : AppTheme.shadowColor,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode 
                          ? AppTheme.darkTextPrimaryColor 
                          : AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Specialist Doctor',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 1; // Switch to doctors tab
                });
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _doctors.length.clamp(0, 4),
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: DoctorCard(
                  name: doctor.name,
                  specialty: doctor.specialty,
                  imageUrl: doctor.imageUrl,
                  rating: doctor.rating,
                  experience: doctor.experience,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.doctorDetail,
                      arguments: doctor,
                    );
                  },
                  isFeatured: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Doctors',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _doctors[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DoctorCard(
                          name: doctor.name,
                          specialty: doctor.specialty,
                          imageUrl: doctor.imageUrl,
                          rating: doctor.rating,
                          experience: doctor.experience,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.doctorDetail,
                              arguments: doctor,
                            );
                          },
                          isFeatured: false,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? theme.colorScheme.surface 
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black12
                                : Colors.grey.shade200,
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                        labelPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.access_time_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Upcoming'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Completed'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Cancelled'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: TabBarView(
                        children: [
                          _buildAppointmentList(AppointmentStatus.upcoming),
                          _buildAppointmentList(AppointmentStatus.completed),
                          _buildAppointmentList(AppointmentStatus.cancelled),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(AppointmentStatus status) {
    final theme = Theme.of(context);
    
    final filteredAppointments = _appointments
        .where((appointment) => appointment.status == status)
        .toList();

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(status).withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${status.name.capitalize()} Appointments',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getEmptyStatusMessage(status),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            if (status == AppointmentStatus.upcoming)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.doctorList);
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Book Appointment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredAppointments.length,
      padding: const EdgeInsets.only(bottom: 40),
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        
        return AppointmentCard(
          doctorName: appointment.doctorName,
          doctorSpecialty: appointment.doctorSpecialty,
          doctorImage: appointment.doctorImage,
          appointmentDate: appointment.date,
          appointmentTime: appointment.time,
          status: appointment.status,
          onTap: () {
            final doctor = _getDoctorFromAppointment(appointment);
            Navigator.pushNamed(
              context,
              AppRoutes.appointmentBooking,
              arguments: doctor,
            );
          },
        );
      },
    );
  }

  String _getEmptyStatusMessage(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return 'You don\'t have any upcoming appointments.\nBook a consultation with a specialist now!';
      case AppointmentStatus.completed:
        return 'You haven\'t had any appointments yet.\nStart by booking your first consultation.';
      case AppointmentStatus.cancelled:
        return 'You don\'t have any cancelled appointments.\nThis is where your cancelled appointments will appear.';
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return Icons.access_time_rounded;
      case AppointmentStatus.completed:
        return Icons.check_circle_outline_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    final theme = Theme.of(context);
    
    switch (status) {
      case AppointmentStatus.upcoming:
        return theme.colorScheme.primary;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildChatTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.search,
                      color: AppTheme.textSecondaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Search for conversations...',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  final lastMessage = 'Hello, how can I help you today?';
                  final timeStamp = '10:30 AM';
                  
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(doctor.imageUrl),
                    ),
                    title: Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      timeStamp,
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chat,
                        arguments: doctor.id,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 60,
                backgroundImage: _currentUser.profileImage != null
                    ? NetworkImage(_currentUser.profileImage!)
                    : const AssetImage('assets/images/default_profile.png') as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(
                _currentUser.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                _currentUser.email,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.editProfile);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.history,
                title: 'Medical History',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.medicalHistory);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.payment,
                title: 'Payment Methods',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.paymentMethods);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.helpSupport);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.exit_to_app,
                title: 'Logout',
                onTap: () {
                  _showLogoutConfirmation(context);
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  if (title == 'Logout')
                    Icon(
                      Icons.logout,
                      size: 20,
                      color: AppTheme.errorColor,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform logout actions
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  AppRoutes.login,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
} 