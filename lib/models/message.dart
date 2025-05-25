import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  bool get isSent => senderId == FirebaseAuth.instance.currentUser?.uid;

  // Convert Message object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString(),
      'attachmentUrl': attachmentUrl,
    };
  }

  // Create Message object from Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MessageType.text,
      ),
      attachmentUrl: map['attachmentUrl'],
    );
  }

  // Get chat messages between two users
  static Stream<List<Message>> getChatMessages(String otherUserId) async* {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final database = FirebaseDatabase.instance;
    final messagesRef = database.ref('messages')
        .orderByChild('timestamp')
        .startAt(DateTime.now().subtract(const Duration(days: 30)).toIso8601String());

    yield* messagesRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final List<Message> messages = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        final message = Message.fromMap(Map<String, dynamic>.from(value));
        if ((message.senderId == currentUserId && message.receiverId == otherUserId) ||
            (message.senderId == otherUserId && message.receiverId == currentUserId)) {
          messages.add(message);
        }
      });

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  // Send a new message
  Future<void> send() async {
    final database = FirebaseDatabase.instance;
    final messagesRef = database.ref('messages').push();
    await messagesRef.set(toMap());
  }

  // Mark message as read
  Future<void> markAsRead() async {
    final database = FirebaseDatabase.instance;
    await database.ref('messages/$id').update({'isRead': true});
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

  // Convert ChatPreview object to Map
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorImage': doctorImage,
      'lastMessage': lastMessage,
      'timestamp': timestamp.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  // Create ChatPreview object from Map
  factory ChatPreview.fromMap(Map<String, dynamic> map) {
    return ChatPreview(
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'] ?? '',
      doctorImage: map['doctorImage'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  // Get chat previews for current user
  static Stream<List<ChatPreview>> getChatPreviews() async* {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final database = FirebaseDatabase.instance;
    final chatPreviewsRef = database.ref('chat_previews/$currentUserId');

    yield* chatPreviewsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final List<ChatPreview> previews = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        previews.add(ChatPreview.fromMap(Map<String, dynamic>.from(value)));
      });

      previews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return previews;
    });
  }
} 