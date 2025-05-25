import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Convert Appointment object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorImage': doctorImage,
      'date': date.toIso8601String(),
      'time': time,
      'duration': duration,
      'status': status.toString(),
      'notes': notes,
      'prescriptionUrl': prescriptionUrl,
    };
  }

  // Create Appointment object from Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'] ?? '',
      doctorImage: map['doctorImage'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      time: map['time'] ?? '',
      duration: map['duration'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => AppointmentStatus.upcoming,
      ),
      notes: map['notes'],
      prescriptionUrl: map['prescriptionUrl'],
    );
  }

  // Get appointments for current user
  static Stream<List<Appointment>> getUserAppointments() async* {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final database = FirebaseDatabase.instance;
    final appointmentsRef = database.ref('appointments')
        .orderByChild('userId')
        .equalTo(currentUserId);

    yield* appointmentsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final List<Appointment> appointments = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        appointments.add(Appointment.fromMap(Map<String, dynamic>.from(value)));
      });

      appointments.sort((a, b) => a.date.compareTo(b.date));
      return appointments;
    });
  }

  // Get appointments for a specific doctor
  static Stream<List<Appointment>> getDoctorAppointments(String doctorId) async* {
    final database = FirebaseDatabase.instance;
    final appointmentsRef = database.ref('appointments')
        .orderByChild('doctorId')
        .equalTo(doctorId);

    yield* appointmentsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final List<Appointment> appointments = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        appointments.add(Appointment.fromMap(Map<String, dynamic>.from(value)));
      });

      appointments.sort((a, b) => a.date.compareTo(b.date));
      return appointments;
    });
  }

  // Create a new appointment
  Future<void> create() async {
    final database = FirebaseDatabase.instance;
    final appointmentsRef = database.ref('appointments').push();
    await appointmentsRef.set(toMap());
  }

  // Update appointment status
  Future<void> updateStatus(AppointmentStatus newStatus) async {
    final database = FirebaseDatabase.instance;
    await database.ref('appointments/$id').update({'status': newStatus.toString()});
  }

  // Cancel appointment
  Future<void> cancel() async {
    await updateStatus(AppointmentStatus.cancelled);
  }

  // Complete appointment
  Future<void> complete() async {
    await updateStatus(AppointmentStatus.completed);
  }
}

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
} 