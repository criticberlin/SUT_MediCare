import 'package:firebase_database/firebase_database.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int experience;
  final String hospital;
  final int patients;
  final String about;
  final String address;
  final List<String> workingHours;
  final List<String> services;
  final List<Review> reviews;
  final bool isOnline;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.experience,
    required this.hospital,
    required this.patients,
    required this.about,
    required this.address,
    required this.workingHours,
    required this.services,
    required this.reviews,
    this.isOnline = false,
  });

  // Convert Doctor object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'imageUrl': imageUrl,
      'rating': rating,
      'experience': experience,
      'hospital': hospital,
      'patients': patients,
      'about': about,
      'address': address,
      'workingHours': workingHours,
      'services': services,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'isOnline': isOnline,
    };
  }

  // Create Doctor object from Map
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      experience: map['experience'] ?? 0,
      hospital: map['hospital'] ?? '',
      patients: map['patients'] ?? 0,
      about: map['about'] ?? '',
      address: map['address'] ?? '',
      workingHours: List<String>.from(map['workingHours'] ?? []),
      services: List<String>.from(map['services'] ?? []),
      reviews: (map['reviews'] as List<dynamic>?)
          ?.map((review) => Review.fromMap(review))
          .toList() ?? [],
      isOnline: map['isOnline'] ?? false,
    );
  }

  // Get all doctors from Firebase
  static Future<List<Doctor>> getAllDoctors() async {
    final database = FirebaseDatabase.instance;
    final doctorsRef = database.ref('doctors');
    final snapshot = await doctorsRef.get();
    
    if (snapshot.exists) {
      final List<Doctor> doctors = [];
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        doctors.add(Doctor.fromMap(Map<String, dynamic>.from(value)));
      });
      return doctors;
    }
    return [];
  }

  // Get a single doctor by ID
  static Future<Doctor?> getDoctorById(String id) async {
    final database = FirebaseDatabase.instance;
    final doctorRef = database.ref('doctors/$id');
    final snapshot = await doctorRef.get();
    
    if (snapshot.exists) {
      return Doctor.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }
}

class Review {
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userName: map['userName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
} 