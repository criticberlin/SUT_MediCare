import 'package:firebase_database/firebase_database.dart';
import 'base_service.dart';

class DoctorService extends BaseService {
  // Get all doctors
  Stream<DatabaseEvent> getAllDoctors() {
    return streamData('doctors');
  }

  // Get doctor by ID
  Future<Map<String, dynamic>?> getDoctorById(String doctorId) async {
    return getData('doctors/$doctorId/profile');
  }

  // Get doctor's appointments
  Stream<DatabaseEvent> getDoctorAppointments(String doctorId) {
    return streamData('doctors/$doctorId/appointments');
  }

  // Update doctor's availability
  Future<void> updateAvailability(String doctorId, Map<String, List<String>> availability) async {
    await updateData('doctors/$doctorId/profile/availability', availability);
  }

  // Update doctor's profile
  Future<void> updateDoctorProfile(String doctorId, Map<String, dynamic> profileData) async {
    await updateData('doctors/$doctorId/profile', {
      ...profileData,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Get doctors by specialization
  Stream<DatabaseEvent> getDoctorsBySpecialization(String specialization) {
    return streamData('doctors');
  }

  // Get available time slots for a doctor on a specific date
  Future<List<String>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    final doctor = await getDoctorById(doctorId);
    if (doctor == null) return [];

    final availability = doctor['profile']['availability'] as Map<String, dynamic>;
    final dayOfWeek = date.weekday.toString();
    final timeSlots = availability[dayOfWeek] as List<dynamic>? ?? [];

    // Get all appointments for the date
    final appointments = await getData('doctors/$doctorId/appointments');
    final bookedSlots = appointments?.values
        .where((appointment) => appointment['date'] == date.toIso8601String())
        .map((appointment) => appointment['time'])
        .toList() ?? [];

    // Filter out booked slots
    return timeSlots
        .where((slot) => !bookedSlots.contains(slot))
        .map((slot) => slot.toString())
        .toList();
  }
} 