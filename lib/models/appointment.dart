import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime date;
  final String timeSlot;
  final String status; // 'pending', 'confirmed', 'completed', 'canceled'
  final String type; // 'online', 'in-person'
  final String? symptoms;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPatientNotified;
  final bool isDoctorNotified;
  final String? meetingUrl; // For online appointments
  final double? fee;
  final bool? isPaid;
  final String? paymentId;
  
  // Optional loaded data
  final Map<String, dynamic>? patientData;
  final Map<String, dynamic>? doctorData;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.type,
    required this.createdAt,
    this.symptoms,
    this.notes,
    this.updatedAt,
    this.isPatientNotified = false,
    this.isDoctorNotified = false,
    this.meetingUrl,
    this.fee,
    this.isPaid,
    this.paymentId,
    this.patientData,
    this.doctorData,
  });

  // Convert Appointment to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'type': type,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPatientNotified': isPatientNotified,
      'isDoctorNotified': isDoctorNotified,
      'meetingUrl': meetingUrl,
      'fee': fee,
      'isPaid': isPaid,
      'paymentId': paymentId,
    };
  }

  // Create Appointment object from Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      date: DateTime.parse(map['date']),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'pending',
      type: map['type'] ?? 'in-person',
      symptoms: map['symptoms'],
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isPatientNotified: map['isPatientNotified'] ?? false,
      isDoctorNotified: map['isDoctorNotified'] ?? false,
      meetingUrl: map['meetingUrl'],
      fee: map['fee']?.toDouble(),
      isPaid: map['isPaid'],
      paymentId: map['paymentId'],
      patientData: map['patientData'],
      doctorData: map['doctorData'],
    );
  }
  
  // Create a copy of the appointment with updated values
  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? date,
    String? timeSlot,
    String? status,
    String? type,
    String? symptoms,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPatientNotified,
    bool? isDoctorNotified,
    String? meetingUrl,
    double? fee,
    bool? isPaid,
    String? paymentId,
    Map<String, dynamic>? patientData,
    Map<String, dynamic>? doctorData,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      type: type ?? this.type,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPatientNotified: isPatientNotified ?? this.isPatientNotified,
      isDoctorNotified: isDoctorNotified ?? this.isDoctorNotified,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      fee: fee ?? this.fee,
      isPaid: isPaid ?? this.isPaid,
      paymentId: paymentId ?? this.paymentId,
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