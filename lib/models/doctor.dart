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

  // Dummy data for doctor list
  static List<Doctor> getDummyDoctors() {
    return [
      Doctor(
        id: '1',
        name: 'Ahmed Kamal',
        specialty: 'Orthopedic Surgeon',
        imageUrl: 'https://img.freepik.com/free-photo/smiling-doctor-with-strethoscope-isolated-grey_651396-974.jpg',
        rating: 4.9,
        experience: 12,
        hospital: 'Cairo University Hospital',
        patients: 1500,
        about: 'Dr. Ahmed Kamal is a board-certified orthopedic surgeon with 12+ years experience specializing in sports medicine and joint replacement surgery.',
        address: '15 Al-Saraya St, Cairo, Egypt',
        workingHours: ['Sun-Thu, 9:00 AM - 5:00 PM', 'Sat, 9:00 AM - 1:00 PM'],
        services: ['Joint Replacement', 'Sports Medicine', 'Arthroscopy', 'Trauma Care'],
        reviews: [
          Review(
            userName: 'Amira Hassan',
            rating: 5.0,
            comment: 'Dr. Kamal is excellent! Very professional and caring.',
            date: DateTime.now().subtract(const Duration(days: 5)),
          ),
          Review(
            userName: 'Mohamed Salah',
            rating: 4.8,
            comment: 'Great experience. He explained everything clearly.',
            date: DateTime.now().subtract(const Duration(days: 12)),
          ),
        ],
        isOnline: true,
      ),
      Doctor(
        id: '2',
        name: 'Nour El-Sayed',
        specialty: 'Neurosurgeon',
        imageUrl: 'https://img.freepik.com/free-photo/portrait-female-doctor-holding-plus-window_23-2150572356.jpg',
        rating: 4.8,
        experience: 8,
        hospital: 'Ain Shams University Hospital',
        patients: 900,
        about: 'Dr. Nour El-Sayed is a neurosurgeon specializing in brain tumors, spine disorders, and neurological trauma with 8 years of practice.',
        address: '23 Ramses St, Cairo, Egypt',
        workingHours: ['Sun-Thu, 8:00 AM - 4:00 PM', 'Sat, 8:00 AM - 12:00 PM'],
        services: ['Brain Surgery', 'Spine Surgery', 'Neurological Consultation', 'Trauma Care'],
        reviews: [
          Review(
            userName: 'Omar Ibrahim',
            rating: 4.9,
            comment: 'Dr. El-Sayed is the best! She has an excellent bedside manner.',
            date: DateTime.now().subtract(const Duration(days: 8)),
          ),
        ],
        isOnline: false,
      ),
      Doctor(
        id: '3',
        name: 'Tarek Mahmoud',
        specialty: 'Infectious Diseases',
        imageUrl: 'https://img.freepik.com/free-photo/doctor-smiling-offering-handshake_23-2148085248.jpg',
        rating: 4.7,
        experience: 15,
        hospital: 'Al-Azhar University Hospital',
        patients: 2200,
        about: 'Dr. Tarek Mahmoud is an infectious disease specialist with 15 years of experience treating complex infections, tropical diseases, and managing public health initiatives.',
        address: '78 Qasr Al-Ainy St, Cairo, Egypt',
        workingHours: ['Sun-Thu, 9:00 AM - 6:00 PM'],
        services: ['Infectious Disease Treatment', 'Travel Medicine', 'HIV/AIDS Care', 'Vaccination'],
        reviews: [
          Review(
            userName: 'Layla Farouk',
            rating: 4.7,
            comment: 'Very knowledgeable and thorough with his diagnoses.',
            date: DateTime.now().subtract(const Duration(days: 20)),
          ),
        ],
        isOnline: true,
      ),
      Doctor(
        id: '4',
        name: 'Kareem Hossam',
        specialty: 'Cardiologist',
        imageUrl: 'https://img.freepik.com/free-photo/male-nurse-with-stethoscope-uniform_23-2148124598.jpg',
        rating: 4.9,
        experience: 20,
        hospital: 'Alexandria University Hospital',
        patients: 3000,
        about: 'Dr. Kareem Hossam is a renowned cardiologist specializing in minimally invasive cardiac procedures and heart health with 20 years of practice.',
        address: '45 Al-Horreya Road, Alexandria, Egypt',
        workingHours: ['Sun-Wed, 7:00 AM - 3:00 PM', 'Thu, 7:00 AM - 12:00 PM'],
        services: ['Cardiac Surgery', 'Heart Treatments', 'Valve Repair', 'Coronary Care'],
        reviews: [
          Review(
            userName: 'Youssef Nader',
            rating: 5.0,
            comment: 'Dr. Hossam saved my life. Exceptional doctor!',
            date: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ],
        isOnline: false,
      ),
      Doctor(
        id: '5',
        name: 'Yasmine Adel',
        specialty: 'Ophthalmologist',
        imageUrl: 'https://img.freepik.com/free-photo/female-doctor-hospital-with-stethoscope_23-2148827772.jpg',
        rating: 4.5,
        experience: 10,
        hospital: 'Maadi Military Hospital',
        patients: 800,
        about: 'Dr. Yasmine Adel is an ophthalmologist focusing on retinal disorders, glaucoma treatment, and pediatric eye care with 10 years of experience.',
        address: '12 Maadi Corniche, Cairo, Egypt',
        workingHours: ['Sun-Thu, 8:30 AM - 5:30 PM', 'Sat, 9:00 AM - 1:00 PM'],
        services: ['Eye Examinations', 'Cataract Surgery', 'Pediatric Eye Care', 'Laser Treatments'],
        reviews: [
          Review(
            userName: 'Heba Ahmed',
            rating: 4.5,
            comment: 'Dr. Adel is very detailed and spent a lot of time explaining my condition.',
            date: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ],
        isOnline: true,
      ),
    ];
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
} 