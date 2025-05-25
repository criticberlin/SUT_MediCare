import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? profileImage;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final double? height;
  final double? weight;
  final List<String>? allergies;
  final List<String>? medications;
  final List<String>? chronicConditions;
  
  // Doctor-specific fields
  final String? specialization;
  final int? yearsOfExperience;
  final String? qualifications;
  final String? licenseNumber;
  final String? hospital;
  final bool? isVerified;
  final double? rating;
  final int? totalReviews;
  final List<String>? languages;
  final Map<String, dynamic>? availability;
  final List<String>? acceptedInsurance;
  final double? consultationFee;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.profileImage,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.height,
    this.weight,
    this.allergies,
    this.medications,
    this.chronicConditions,
    // Doctor-specific fields
    this.specialization,
    this.yearsOfExperience,
    this.qualifications,
    this.licenseNumber,
    this.hospital,
    this.isVerified,
    this.rating,
    this.totalReviews,
    this.languages,
    this.availability,
    this.acceptedInsurance,
    this.consultationFee,
  });

  // Convert User object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'medications': medications,
      'chronicConditions': chronicConditions,
      // Doctor-specific fields
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
      'qualifications': qualifications,
      'licenseNumber': licenseNumber,
      'hospital': hospital,
      'isVerified': isVerified,
      'rating': rating,
      'totalReviews': totalReviews,
      'languages': languages,
      'availability': availability,
      'acceptedInsurance': acceptedInsurance,
      'consultationFee': consultationFee,
    };
  }

  // Create User object from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'patient',
      phone: map['phone'],
      address: map['address'],
      profileImage: map['profileImage'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      bloodType: map['bloodType'],
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      allergies: map['allergies'] != null ? List<String>.from(map['allergies']) : null,
      medications: map['medications'] != null ? List<String>.from(map['medications']) : null,
      chronicConditions: map['chronicConditions'] != null ? List<String>.from(map['chronicConditions']) : null,
      // Doctor-specific fields
      specialization: map['specialization'],
      yearsOfExperience: map['yearsOfExperience'],
      qualifications: map['qualifications'],
      licenseNumber: map['licenseNumber'],
      hospital: map['hospital'],
      isVerified: map['isVerified'],
      rating: map['rating']?.toDouble(),
      totalReviews: map['totalReviews'],
      languages: map['languages'] != null ? List<String>.from(map['languages']) : null,
      availability: map['availability'],
      acceptedInsurance: map['acceptedInsurance'] != null ? List<String>.from(map['acceptedInsurance']) : null,
      consultationFee: map['consultationFee']?.toDouble(),
    );
  }

  // Get current user from Firebase Auth and Database
  static Future<User?> getCurrentUser() async {
    try {
      final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;
      final FirebaseDatabase database = FirebaseDatabase.instance;
      
      final firebase_auth.User? firebaseUser = auth.currentUser;
      if (firebaseUser == null) {
        print('No Firebase user found');
        return null;
      }

      print('Fetching user data for: ${firebaseUser.uid}');
      final DatabaseEvent event = await database.ref('users/${firebaseUser.uid}').once();
      
      if (!event.snapshot.exists) {
        print('No user data found in database');
        return null;
      }

      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        print('User data is null');
        return null;
      }

      print('User data retrieved: $data');
      final user = User.fromMap({
        'id': firebaseUser.uid,
        ...data,
      });
      print('User object created successfully');
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Stream user data changes
  static Stream<User?> streamUserData() {
    final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;
    final FirebaseDatabase database = FirebaseDatabase.instance;
    
    return auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final DatabaseEvent event = await database.ref('users/${firebaseUser.uid}').once();
        if (!event.snapshot.exists) return null;

        final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) return null;

        return User.fromMap({
          'id': firebaseUser.uid,
          ...data,
        });
      } catch (e) {
        print('Error streaming user data: $e');
        return null;
      }
    });
  }

  // Create a copy of the user with updated values
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    String? profileImage,
    String? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    List<String>? allergies,
    List<String>? medications,
    List<String>? chronicConditions,
    // Doctor-specific fields
    String? specialization,
    int? yearsOfExperience,
    String? qualifications,
    String? licenseNumber,
    String? hospital,
    bool? isVerified,
    double? rating,
    int? totalReviews,
    List<String>? languages,
    Map<String, dynamic>? availability,
    List<String>? acceptedInsurance,
    double? consultationFee,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      // Doctor-specific fields
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      qualifications: qualifications ?? this.qualifications,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      hospital: hospital ?? this.hospital,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      languages: languages ?? this.languages,
      availability: availability ?? this.availability,
      acceptedInsurance: acceptedInsurance ?? this.acceptedInsurance,
      consultationFee: consultationFee ?? this.consultationFee,
    );
  }

  // Save user data to Firebase
  Future<void> save() async {
    final database = FirebaseDatabase.instance;
    await database.ref('users/$id').set(toMap());
  }

  // Update user data in Firebase
  Future<void> update() async {
    final database = FirebaseDatabase.instance;
    await database.ref('users/$id').update(toMap());
  }

  // Delete user data from Firebase
  Future<void> delete() async {
    final database = FirebaseDatabase.instance;
    await database.ref('users/$id').remove();
  }
} 