class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final double? height;
  final double? weight;
  final List<String>? allergies;
  final List<String>? medications;
  final List<String>? chronicConditions;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.height,
    this.weight,
    this.allergies,
    this.medications,
    this.chronicConditions,
  });

  // Mock current user data
  static User getCurrentUser() {
    return User(
      id: 'user1',
      name: 'Mohamed Ahmed',
      email: 'mohamed.ahmed@gmail.com',
      phone: '+20 1015183968',
      profileImage: 'https://img.freepik.com/free-photo/handsome-bearded-businessman-rubbing-hands-having-deal_176420-18778.jpg',
      dateOfBirth: '2005-08-17',
      gender: 'Male',
      bloodType: 'O+',
      height: 175.0,
      weight: 70.5,
      allergies: ['Penicillin', 'Peanuts'],
      medications: ['Lisinopril', 'Vitamin D'],
      chronicConditions: ['Hypertension'],
    );
  }

  // Create a copy of the user with updated values
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    List<String>? allergies,
    List<String>? medications,
    List<String>? chronicConditions,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      chronicConditions: chronicConditions ?? this.chronicConditions,
    );
  }
} 