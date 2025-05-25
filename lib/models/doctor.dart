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
  // Additional fields from form
  final String? phone;
  final String? email;
  final String? qualifications;
  final String? licenseNumber;
  final double? consultationFee;
  final List<String>? languages;
  final List<String>? acceptedInsurance;

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
    this.phone,
    this.email,
    this.qualifications,
    this.licenseNumber,
    this.consultationFee,
    this.languages,
    this.acceptedInsurance,
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
      'phone': phone,
      'email': email,
      'qualifications': qualifications,
      'licenseNumber': licenseNumber,
      'consultationFee': consultationFee,
      'languages': languages,
      'acceptedInsurance': acceptedInsurance,
    };
  }

  // Create Doctor object from Map
  factory Doctor.fromMap(Map<String, dynamic> map) {
    try {
      print('Parsing doctor from map with ID: ${map['id']}');
      
      var doc = Doctor(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        specialty: map['specialty'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        rating: (map['rating'] != null) ? double.tryParse(map['rating'].toString()) ?? 0.0 : 0.0,
        experience: map['experience'] != null ? int.tryParse(map['experience'].toString()) ?? 0 : 0,
        hospital: map['hospital'] ?? '',
        patients: map['patients'] != null ? int.tryParse(map['patients'].toString()) ?? 0 : 0,
        about: map['about'] ?? '',
        address: map['address'] ?? '',
        workingHours: map['workingHours'] != null ? List<String>.from(map['workingHours']) : [],
        services: map['services'] != null ? List<String>.from(map['services']) : [],
        reviews: _parseReviews(map['reviews']),
        isOnline: map['isOnline'] ?? false,
        phone: map['phone'],
        email: map['email'],
        qualifications: map['qualifications'],
        licenseNumber: map['licenseNumber'],
        consultationFee: map['consultationFee'] != null ? 
          double.tryParse(map['consultationFee'].toString()) : null,
        languages: map['languages'] != null ? List<String>.from(map['languages']) : null,
        acceptedInsurance: map['acceptedInsurance'] != null ? 
          List<String>.from(map['acceptedInsurance']) : null,
      );
      
      print('Successfully parsed doctor: ${doc.name}');
      return doc;
    } catch (e) {
      print('Error parsing doctor from map: $e');
      // Provide a default doctor object if parsing fails
      return Doctor(
        id: map['id'] ?? '',
        name: map['name'] ?? 'Unknown Doctor',
        specialty: 'General Medicine',
        imageUrl: 'assets/images/doctor_placeholder.png',
        rating: 0.0,
        experience: 0,
        hospital: 'Unknown',
        patients: 0,
        about: 'No information available',
        address: 'Not specified',
        workingHours: ['9:00 AM - 5:00 PM'],
        services: ['General Consultation'],
        reviews: [],
      );
    }
  }

  // Create Doctor object from Firebase user data
  factory Doctor.fromFirebase(String docId, Map<dynamic, dynamic> userData) {
    try {
      print('Parsing doctor from firebase with ID: $docId');
      
      // Handle specialty field naming difference
      String specialty = 'General Physician';
      if (userData['specialization'] != null) {
        specialty = userData['specialization'].toString();
      } else if (userData['specialty'] != null) {
        specialty = userData['specialty'].toString();
      }
      
      // Parse working hours
      List<String> workingHours = ['Monday-Friday: 9:00 AM - 5:00 PM'];
      if (userData['workingHours'] != null) {
        workingHours = List<String>.from(userData['workingHours']);
      } else if (userData['availability'] != null) {
        var availability = userData['availability'];
        if (availability is Map) {
          String startTime = availability['startTime'] ?? '9:00 AM';
          String endTime = availability['endTime'] ?? '5:00 PM';
          workingHours = ['${startTime} - ${endTime}'];
        }
      }
      
      // Parse services
      List<String> services = ['General Consultation'];
      if (userData['services'] != null) {
        services = List<String>.from(userData['services']);
      }
      
      // Parse experience
      int experience = 0;
      if (userData['yearsOfExperience'] != null) {
        experience = int.tryParse(userData['yearsOfExperience'].toString()) ?? 0;
      } else if (userData['experience'] != null) {
        experience = int.tryParse(userData['experience'].toString()) ?? 0;
      }
      
      var doc = Doctor(
        id: docId,
        name: userData['name'] != null ? 
          (userData['name'].toString().startsWith('Dr.') ? userData['name'] : "Dr. ${userData['name']}") : 
          'Unknown Doctor',
        specialty: specialty,
        imageUrl: userData['profileImage'] ?? 'assets/images/doctor_placeholder.png',
        rating: userData['rating'] != null ? double.tryParse(userData['rating'].toString()) ?? 4.0 : 4.0,
        experience: experience,
        hospital: userData['hospital'] ?? 'Not specified',
        patients: userData['patientCount'] != null ? int.tryParse(userData['patientCount'].toString()) ?? 0 : 0,
        about: userData['about'] ?? 'No information available.',
        address: userData['address'] ?? 'Not specified',
        workingHours: workingHours,
        services: services,
        reviews: [],
        isOnline: userData['isOnline'] ?? false,
        phone: userData['phone'],
        email: userData['email'],
        qualifications: userData['qualifications'],
        licenseNumber: userData['licenseNumber'],
        consultationFee: userData['consultationFee'] != null ? 
          double.tryParse(userData['consultationFee'].toString()) : null,
        languages: userData['languages'] != null ? List<String>.from(userData['languages']) : null,
        acceptedInsurance: userData['acceptedInsurance'] != null ? 
          List<String>.from(userData['acceptedInsurance']) : null,
      );
      
      print('Successfully parsed doctor from firebase: ${doc.name}');
      return doc;
    } catch (e) {
      print('Error parsing doctor from firebase: $e');
      // Return a default doctor object with minimal info if parsing fails
      return Doctor(
        id: docId,
        name: userData['name'] != null ? "Dr. ${userData['name']}" : "Unknown Doctor",
        specialty: 'General Physician',
        imageUrl: 'assets/images/doctor_placeholder.png',
        rating: 4.0,
        experience: 0,
        hospital: 'Not specified',
        patients: 0,
        about: 'No information available.',
        address: 'Not specified',
        workingHours: ['Monday-Friday: 9:00 AM - 5:00 PM'],
        services: ['General Consultation'],
        reviews: [],
      );
    }
  }
  
  // Helper method to parse reviews
  static List<Review> _parseReviews(dynamic reviewsData) {
    if (reviewsData == null) return [];
    
    try {
      if (reviewsData is List) {
        return reviewsData
          .map((review) => Review.fromMap(Map<String, dynamic>.from(review)))
          .toList();
      }
      return [];
    } catch (e) {
      print('Error parsing reviews: $e');
      return [];
    }
  }

  // Get all doctors from Firebase
  static Future<List<Doctor>> getAllDoctors() async {
    try {
      print('Getting all doctors from Firebase');
      final database = FirebaseDatabase.instance;
      final doctorsRef = database.ref('doctors');
      final snapshot = await doctorsRef.get();
      
      if (snapshot.exists) {
        final List<Doctor> doctors = [];
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          try {
            doctors.add(Doctor.fromMap(Map<String, dynamic>.from(value)));
          } catch (e) {
            print('Error parsing doctor $key: $e');
          }
        });
        print('Fetched ${doctors.length} doctors');
        return doctors;
      }
      
      // If no doctors in the doctors collection, try users/Doctors
      final doctorsInRolePath = await database.ref('users/Doctors').get();
      if (doctorsInRolePath.exists) {
        final List<Doctor> doctors = [];
        final data = doctorsInRolePath.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          try {
            doctors.add(Doctor.fromFirebase(key, value));
          } catch (e) {
            print('Error parsing doctor $key from users/Doctors: $e');
          }
        });
        print('Fetched ${doctors.length} doctors from users/Doctors');
        return doctors;
      }
      
      print('No doctors found in any collection');
      return [];
    } catch (e) {
      print('Error getting all doctors: $e');
      return [];
    }
  }

  // Get a single doctor by ID
  static Future<Doctor?> getDoctorById(String id) async {
    try {
      print('Getting doctor by ID: $id');
      final database = FirebaseDatabase.instance;
      
      // Try doctors collection first
      final doctorRef = database.ref('doctors/$id');
      final snapshot = await doctorRef.get();
      
      if (snapshot.exists) {
        print('Found doctor in doctors collection');
        return Doctor.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
      
      // Try flat users collection
      final userRef = database.ref('users/$id');
      final userSnapshot = await userRef.get();
      
      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        if (userData['role'] == 'Doctor') {
          print('Found doctor in users collection');
          return Doctor.fromFirebase(id, userData);
        }
      }
      
      // Try users/Doctors collection
      final doctorInRolePath = database.ref('users/Doctors/$id');
      final doctorRoleSnapshot = await doctorInRolePath.get();
      
      if (doctorRoleSnapshot.exists) {
        print('Found doctor in users/Doctors collection');
        return Doctor.fromFirebase(id, doctorRoleSnapshot.value as Map);
      }
      
      print('Doctor not found in any collection');
      return null;
    } catch (e) {
      print('Error getting doctor by ID: $e');
      return null;
    }
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
    try {
      return Review(
        userName: map['userName'] ?? '',
        rating: (map['rating'] != null) ? double.tryParse(map['rating'].toString()) ?? 0.0 : 0.0,
        comment: map['comment'] ?? '',
        date: map['date'] != null ? 
          DateTime.parse(map['date']) : 
          DateTime.now(),
      );
    } catch (e) {
      print('Error parsing review: $e');
      return Review(
        userName: 'Anonymous',
        rating: 0.0,
        comment: 'Error parsing review',
        date: DateTime.now(),
      );
    }
  }
} 