import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../models/user.dart';
import '../../utils/theme/app_theme.dart';
import '../../routes.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/appointment_card.dart';

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
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
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
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.textPrimaryColor,
                ),
                SizedBox(width: 4),
                Text(
                  'Cairo, Egypt',
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.textPrimaryColor,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppTheme.textSecondaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Search',
            style: TextStyle(
              color: AppTheme.textSecondaryColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tune,
              color: AppTheme.textSecondaryColor,
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
              color: AppTheme.accentColor.withOpacity(0.1),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
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
              Navigator.pushNamed(
                context,
                AppRoutes.appointmentBooking,
                arguments: appointment,
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildCategorySection() {
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowColor,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimaryColor,
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
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppTheme.primaryColor,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.textSecondaryColor,
                        tabs: const [
                          Tab(text: 'Upcoming'),
                          Tab(text: 'Completed'),
                          Tab(text: 'Cancelled'),
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
    final filteredAppointments = _appointments
        .where((appointment) => appointment.status == status)
        .toList();

    if (filteredAppointments.isEmpty) {
      return Center(
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
              'No ${status.name} Appointments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (status == AppointmentStatus.upcoming)
              Text(
                'Book your appointment now',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredAppointments.length,
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
            Navigator.pushNamed(
              context,
              AppRoutes.appointmentBooking,
              arguments: appointment,
            );
          },
        );
      },
    );
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
                  // Navigate to edit profile
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.history,
                title: 'Medical History',
                onTap: () {
                  // Navigate to medical history
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
                  // Navigate to payment methods
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
                  // Navigate to help and support
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.exit_to_app,
                title: 'Logout',
                onTap: () {
                  // Handle logout
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
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
          title: Text(title),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
} 