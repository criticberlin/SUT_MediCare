import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String type; // 'text', 'image', 'video', etc.
  final DateTime timestamp;
  final bool isRead;
  final Map<String, bool>? readBy; // Map of userIds to read status

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.readBy,
  });

  // Convert Message to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'readBy': readBy,
    };
  }

  // Create Message object from Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      timestamp: map['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : map['timestamp'] is String
              ? DateTime.parse(map['timestamp'])
              : DateTime.now(),
      isRead: map['isRead'] ?? false,
      readBy: map['readBy'] != null ? Map<String, bool>.from(map['readBy']) : null,
    );
  }

  // Create a new message
  static Future<String> createMessage({
    required String chatId,
    required String senderId,
    required String content,
    String type = 'text',
  }) async {
    final database = FirebaseDatabase.instance;
    final messageRef = database.ref('messages/$chatId').push();
    final id = messageRef.key!;
    
    final message = Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      readBy: {senderId: true},
    );
    
    await messageRef.set(message.toMap());
    
    // Update the chat's last message
    await database.ref('chats/$chatId').update({
      'lastMessage': content,
      'updatedAt': ServerValue.timestamp,
    });
    
    return id;
  }

  // Get all messages for a chat
  static Future<List<Message>> getMessagesForChat(String chatId) async {
    final database = FirebaseDatabase.instance;
    final messagesRef = database.ref('messages/$chatId');
    final snapshot = await messagesRef.orderByChild('timestamp').get();
    
    if (!snapshot.exists) return [];
    
    final messagesData = snapshot.value as Map<dynamic, dynamic>;
    final messages = <Message>[];
    
    messagesData.forEach((key, value) {
      final data = value as Map<dynamic, dynamic>;
      messages.add(Message.fromMap({
        'id': key,
        ...Map<String, dynamic>.from(data),
      }));
    });
    
    // Sort by timestamp, oldest first
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  // Stream messages for a chat
  static Stream<List<Message>> streamMessagesForChat(String chatId) {
    final database = FirebaseDatabase.instance;
    final messagesRef = database.ref('messages/$chatId');
    
    return messagesRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];
      
      final messagesData = event.snapshot.value as Map<dynamic, dynamic>;
      final messages = <Message>[];
      
      messagesData.forEach((key, value) {
        final data = value as Map<dynamic, dynamic>;
        messages.add(Message.fromMap({
          'id': key,
          ...Map<String, dynamic>.from(data),
        }));
      });
      
      // Sort by timestamp, oldest first
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  // Mark message as read by user
  Future<void> markAsReadBy(String userId) async {
    final database = FirebaseDatabase.instance;
    
    final updatedReadBy = readBy ?? {};
    updatedReadBy[userId] = true;
    
    await database.ref('messages/$chatId/$id').update({
      'readBy': updatedReadBy,
      'isRead': true,
    });
  }

  // Create a copy of this message with updated fields
  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, bool>? readBy,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readBy: readBy ?? this.readBy,
    );
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