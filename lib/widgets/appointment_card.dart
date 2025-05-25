import 'package:flutter/material.dart';
import '../models/appointment.dart' as app_models;
import '../utils/theme/app_theme.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImage;
  final DateTime appointmentDate;
  final String appointmentTime;
  final app_models.AppointmentStatus status;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImage,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2) 
                  : Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: _getStatusColor(context).withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.05 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'doctor-image-${doctorName.hashCode}',
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: isDarkMode ? 0.2 : 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          doctorImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDarkMode 
                                  ? Colors.grey.shade800 
                                  : Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.3),
                              child: Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.7),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                doctorName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusChip(context),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 14,
                              color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctorSpecialty,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildAppointmentDetails(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (status) {
      case app_models.AppointmentStatus.upcoming:
        return theme.colorScheme.primary;
      case app_models.AppointmentStatus.completed:
        return Colors.green;
      case app_models.AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildAppointmentDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? theme.colorScheme.primary.withValues(red: null, green: null, blue: null, alpha: 0.1) 
            : theme.colorScheme.primary.withValues(red: null, green: null, blue: null, alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.05 : 0.03),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(red: null, green: null, blue: null, alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_formatDate(appointmentDate)} · $appointmentTime',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    Color chipColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case app_models.AppointmentStatus.upcoming:
        chipColor = theme.colorScheme.primary;
        statusText = 'Upcoming';
        statusIcon = Icons.access_time_rounded;
        break;
      case app_models.AppointmentStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case app_models.AppointmentStatus.cancelled:
        chipColor = Colors.red;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: chipColor.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.05 : 0.03),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    if (status != app_models.AppointmentStatus.upcoming) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? theme.colorScheme.surface 
              : Colors.grey.shade50,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: isDarkMode 
                  ? Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.2) 
                  : Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Book Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? theme.colorScheme.surface 
            : Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: isDarkMode 
                ? Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.2) 
                : Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
              label: const Text('Reschedule'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.video_call_rounded, size: 18),
              label: const Text('Join Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
