class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final String? attachmentUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.attachmentUrl,
  });

  bool get isSent => senderId == 'user1';

  // Get dummy chat messages
  static List<Message> getDummyChatMessages(String doctorId) {
    return [
      Message(
        id: '1',
        senderId: 'doctor$doctorId',
        receiverId: 'user1',
        content: 'Hello! How can I help you today?',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '2',
        senderId: 'user1',
        receiverId: 'doctor$doctorId',
        content: 'Hi doctor, I\'ve been experiencing headaches for the past week.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 45)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '3',
        senderId: 'doctor$doctorId',
        receiverId: 'user1',
        content: 'I\'m sorry to hear that. Can you describe the pain? Is it constant or does it come and go?',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 30)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '4',
        senderId: 'user1',
        receiverId: 'doctor$doctorId',
        content: 'It comes and goes, mostly in the afternoon. Sometimes it\'s very intense.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 20)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '5',
        senderId: 'doctor$doctorId',
        receiverId: 'user1',
        content: 'I see. Have you taken any medication for it?',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '6',
        senderId: 'user1',
        receiverId: 'doctor$doctorId',
        content: 'Just some over-the-counter painkillers, but they don\'t help much.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, minutes: 45)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '7',
        senderId: 'doctor$doctorId',
        receiverId: 'user1',
        content: 'I recommend you schedule an appointment so I can examine you properly. In the meantime, try to rest and stay hydrated.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, minutes: 30)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '8',
        senderId: 'user1',
        receiverId: 'doctor$doctorId',
        content: 'Thank you, I\'ll book an appointment right away.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, minutes: 15)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '9',
        senderId: 'doctor$doctorId',
        receiverId: 'user1',
        content: 'Great! I\'ll see you soon. Take care.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '10',
        senderId: 'user1',
        receiverId: 'doctor$doctorId',
        content: 'Doctor, I also wanted to show you this rash that appeared yesterday.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
        type: MessageType.image,
        attachmentUrl: 'https://img.freepik.com/free-photo/dermatologist-checking-patient-mole_23-2148868872.jpg',
      ),
      Message(
        id: '11',
        senderId: 'doctor$doctorId',
        receiverId: 'user1',
        content: 'Thanks for sharing. It looks like a mild allergic reaction. We\'ll discuss this during your appointment as well. You can apply some calamine lotion for temporary relief.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        type: MessageType.text,
      ),
      Message(
        id: '12',
        senderId: 'user1',
        receiverId: 'doctor$doctorId',
        content: 'Thank you for the advice!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        type: MessageType.text,
      ),
    ];
  }

  // Get dummy chat list of recent doctors
  static List<ChatPreview> getDummyChatPreviews() {
    return [
      ChatPreview(
        doctorId: '1',
        doctorName: 'Dr. Jason Response',
        doctorSpecialty: 'Orthopedic Surgeon',
        doctorImage: 'https://img.freepik.com/free-photo/smiling-doctor-with-strethoscope-isolated-grey_651396-974.jpg',
        lastMessage: 'Great! I\'ll see you soon. Take care.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
      ChatPreview(
        doctorId: '2',
        doctorName: 'Dr. Dianne Ameter',
        doctorSpecialty: 'Neurosurgeon',
        doctorImage: 'https://img.freepik.com/free-photo/portrait-female-doctor-holding-plus-window_23-2150572356.jpg',
        lastMessage: 'Please don\'t forget to bring your previous scan results.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        unreadCount: 1,
      ),
      ChatPreview(
        doctorId: '3',
        doctorName: 'Dr. Norman Gordon',
        doctorSpecialty: 'Infectious Diseases',
        doctorImage: 'https://img.freepik.com/free-photo/doctor-smiling-offering-handshake_23-2148085248.jpg',
        lastMessage: 'Your test results look good. No need to worry.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        unreadCount: 0,
      ),
    ];
  }
}

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
}

class ChatPreview {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImage;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;

  ChatPreview({
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImage,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
  });
} 