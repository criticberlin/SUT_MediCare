import '../widgets/appointment_card.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImage;
  final DateTime date;
  final String time;
  final String duration;
  final AppointmentStatus status;
  final String? notes;
  final String? prescriptionUrl;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImage,
    required this.date,
    required this.time,
    required this.duration,
    required this.status,
    this.notes,
    this.prescriptionUrl,
  });

  // Dummy data for appointment list
  static List<Appointment> getDummyAppointments() {
    return [
      Appointment(
        id: '1',
        doctorId: '1',
        doctorName: 'Dr. Jason Response',
        doctorSpecialty: 'Orthopedic Surgeon',
        doctorImage: 'https://img.freepik.com/free-photo/smiling-doctor-with-strethoscope-isolated-grey_651396-974.jpg',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '10:00 AM',
        duration: '30 mins',
        status: AppointmentStatus.upcoming,
        notes: 'Annual check-up for knee surgery recovery',
      ),
      Appointment(
        id: '2',
        doctorId: '2',
        doctorName: 'Dr. Dianne Ameter',
        doctorSpecialty: 'Neurosurgeon',
        doctorImage: 'https://img.freepik.com/free-photo/portrait-female-doctor-holding-plus-window_23-2150572356.jpg',
        date: DateTime.now().add(const Duration(days: 5)),
        time: '2:30 PM',
        duration: '45 mins',
        status: AppointmentStatus.upcoming,
        notes: 'Follow-up consultation for headaches',
      ),
      Appointment(
        id: '3',
        doctorId: '4',
        doctorName: 'Dr. Fletch Skinner',
        doctorSpecialty: 'Heart Surgeon',
        doctorImage: 'https://img.freepik.com/free-photo/male-nurse-with-stethoscope-uniform_23-2148124598.jpg',
        date: DateTime.now().subtract(const Duration(days: 10)),
        time: '9:15 AM',
        duration: '60 mins',
        status: AppointmentStatus.completed,
        notes: 'Cardiac evaluation',
        prescriptionUrl: 'assets/images/prescription_sample.jpg',
      ),
      Appointment(
        id: '4',
        doctorId: '3',
        doctorName: 'Dr. Norman Gordon',
        doctorSpecialty: 'Infectious Diseases',
        doctorImage: 'https://img.freepik.com/free-photo/doctor-smiling-offering-handshake_23-2148085248.jpg',
        date: DateTime.now().subtract(const Duration(days: 5)),
        time: '11:00 AM',
        duration: '30 mins',
        status: AppointmentStatus.cancelled,
        notes: 'Consultation for recurring fever',
      ),
    ];
  }
} 