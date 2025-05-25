import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final String reason;
  final int duration;
  final String? notes;
  final double? fee;
  final String status;
  final int createdAt;
  final int updatedAt;
  
  // Optional loaded data
  final Map<String, dynamic>? patientData;
  final Map<String, dynamic>? doctorData;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    required this.reason,
    required this.duration,
    this.notes,
    this.fee,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.patientData,
    this.doctorData,
  });

  // Convert Appointment to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'dateTime': dateTime.toIso8601String(),
      'reason': reason,
      'duration': duration,
      'notes': notes,
      'fee': fee,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create Appointment object from Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'])
          : DateTime.now(),
      reason: map['reason'] ?? '',
      duration: map['duration'] ?? 30,
      notes: map['notes'],
      fee: map['fee']?.toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      patientData: map['patientData'],
      doctorData: map['doctorData'],
    );
  }
  
  // Create a copy of the appointment with updated values
  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? dateTime,
    String? reason,
    int? duration,
    String? notes,
    double? fee,
    String? status,
    int? createdAt,
    int? updatedAt,
    Map<String, dynamic>? patientData,
    Map<String, dynamic>? doctorData,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      dateTime: dateTime ?? this.dateTime,
      reason: reason ?? this.reason,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      fee: fee ?? this.fee,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientData: patientData ?? this.patientData,
      doctorData: doctorData ?? this.doctorData,
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

      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
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

      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
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
  Future<void> updateStatus(String newStatus) async {
    final database = FirebaseDatabase.instance;
    await database.ref('appointments/$id').update({'status': newStatus});
  }

  // Cancel appointment
  Future<void> cancel() async {
    await updateStatus('cancelled');
  }

  // Complete appointment
  Future<void> complete() async {
    await updateStatus('completed');
  }
}

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
} 