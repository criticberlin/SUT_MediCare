import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final String? attachment;
  final bool read;
  final int createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.attachment,
    required this.read,
    required this.createdAt,
  });

  // Convert Message to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'attachment': attachment,
      'read': read,
      'createdAt': createdAt,
    };
  }

  // Create Message object from Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      attachment: map['attachment'],
      read: map['read'] ?? false,
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  // Create a copy of the message with updated values
  Message copyWith({
    String? id,
    String? senderId,
    String? text,
    String? attachment,
    bool? read,
    int? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      attachment: attachment ?? this.attachment,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get chat messages for a specific chatId
  static Stream<List<Message>> getChatMessages(String chatId) async* {
    final database = FirebaseDatabase.instance;
    final messagesRef = database.ref('messages/$chatId')
        .orderByChild('createdAt');

    yield* messagesRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final List<Message> messages = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        final message = Message.fromMap({
          'id': key,
          ...Map<String, dynamic>.from(value as Map),
        });
        messages.add(message);
      });

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return messages;
    });
  }

  // Send a new message
  static Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? attachment,
  }) async {
    final database = FirebaseDatabase.instance;
    final newMessageRef = database.ref('messages/$chatId').push();
    
    final messageData = {
      'id': newMessageRef.key,
      'senderId': senderId,
      'text': text,
      'attachment': attachment,
      'read': false,
      'createdAt': ServerValue.timestamp,
    };
    
    // Add message
    await newMessageRef.set(messageData);
    
    // Update chat's last message
    await database.ref('chats/$chatId').update({
      'lastMessage': text,
      'lastMessageSender': senderId,
      'lastMessageTime': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Mark message as read
  Future<void> markAsRead() async {
    final database = FirebaseDatabase.instance;
    await database.ref('messages/$id').update({'read': true});
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