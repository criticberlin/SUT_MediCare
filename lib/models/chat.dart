import 'package:firebase_database/firebase_database.dart';
import 'message.dart';
import 'user.dart' as app_user;

class Chat {
  final String id;
  final List<String> participants; // User IDs of participants
  final Map<String, String> participantRoles; // Map of userId to role (doctor or patient)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? lastMessage;
  final List<Message>? messages; // Optional loaded messages
  final Map<String, app_user.User>? participantData; // Optional loaded user data

  Chat({
    required this.id,
    required this.participants,
    required this.participantRoles,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.messages,
    this.participantData,
  });

  // Convert Chat to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'participantRoles': participantRoles,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }

  // Create Chat object from Map
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      participantRoles: Map<String, String>.from(map['participantRoles'] ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      lastMessage: map['lastMessage'],
    );
  }

  // Create a new chat between users
  static Future<String> createChat({
    required String userId1,
    required String role1,
    required String userId2,
    required String role2,
  }) async {
    // Validate that we're not creating a patient-patient chat
    if (role1 == 'Patient' && role2 == 'Patient') {
      throw Exception('Patient-to-patient chats are not allowed');
    }
    
    // Check if a chat already exists between these users
    final existingChatId = await getChatIdBetweenUsers(userId1, userId2);
    if (existingChatId != null) {
      return existingChatId;
    }
    
    final database = FirebaseDatabase.instance;
    final chatRef = database.ref('chats').push();
    final chatId = chatRef.key!;
    
    final now = DateTime.now();
    final chat = Chat(
      id: chatId,
      participants: [userId1, userId2],
      participantRoles: {
        userId1: role1,
        userId2: role2,
      },
      createdAt: now,
      updatedAt: now,
    );
    
    await chatRef.set(chat.toMap());
    
    // Create user chat references for easy lookup
    await database.ref('user_chats/$userId1/$chatId').set(true);
    await database.ref('user_chats/$userId2/$chatId').set(true);
    
    return chatId;
  }

  // Get all chats for a user
  static Stream<List<Chat>> getChatsForUser(String userId) {
    final database = FirebaseDatabase.instance;
    final userChatsRef = database.ref('user_chats/$userId');
    
    return userChatsRef.onValue.map<Stream<List<Chat>>>((event) {
      if (!event.snapshot.exists) {
        return Stream.value(<Chat>[]);
      }
      
      final chatIds = (event.snapshot.value as Map<dynamic, dynamic>).keys.toList();
      final idsList = chatIds.map((id) => id.toString()).toList();
      return getChatsByIds(idsList);
    }).asyncExpand((stream) => stream);
  }
  
  // Get multiple chats by their IDs
  static Stream<List<Chat>> getChatsByIds(List<String> chatIds) {
    if (chatIds.isEmpty) return Stream.value(<Chat>[]);
    
    return Stream.fromFuture(
      Future.wait(chatIds.map((id) => _getChatById(id)))
    );
  }

  // Get a chat by ID
  static Future<Chat> _getChatById(String chatId) async {
    final database = FirebaseDatabase.instance;
    final chatRef = database.ref('chats/$chatId');
    final snapshot = await chatRef.get();
    
    if (!snapshot.exists) {
      throw Exception('Chat not found');
    }
    
    final data = snapshot.value as Map<dynamic, dynamic>;
    return Chat.fromMap({
      'id': chatId,
      ...Map<String, dynamic>.from(data),
    });
  }

  // Get chat ID between two users if it exists
  static Future<String?> getChatIdBetweenUsers(String userId1, String userId2) async {
    final database = FirebaseDatabase.instance;
    final userChatsRef = database.ref('user_chats/$userId1');
    final snapshot = await userChatsRef.get();
    
    if (!snapshot.exists) return null;
    
    final chatIds = (snapshot.value as Map<dynamic, dynamic>).keys.toList();
    
    for (final chatId in chatIds) {
      final chatRef = database.ref('chats/$chatId');
      final chatSnapshot = await chatRef.get();
      
      if (chatSnapshot.exists) {
        final chatData = chatSnapshot.value as Map<dynamic, dynamic>;
        final participants = List<String>.from(chatData['participants'] ?? []);
        
        if (participants.contains(userId2)) {
          return chatId.toString();
        }
      }
    }
    
    return null;
  }

  // Load messages for this chat
  Future<List<Message>> loadMessages() async {
    return Message.getMessagesForChat(id);
  }

  // Add a message to this chat
  Future<String> addMessage({
    required String senderId,
    required String content,
    String type = 'text',
  }) async {
    final messageId = await Message.createMessage(
      chatId: id,
      senderId: senderId,
      content: content,
      type: type,
    );
    
    // Update the last message and timestamp
    final database = FirebaseDatabase.instance;
    await database.ref('chats/$id').update({
      'lastMessage': content,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    // Create notifications for other participants
    for (final userId in participants) {
      if (userId != senderId) {
        // Get sender name
        final userRef = database.ref('users/$senderId');
        final userSnapshot = await userRef.get();
        String senderName = 'User';
        
        if (userSnapshot.exists) {
          final userData = userSnapshot.value as Map<dynamic, dynamic>;
          senderName = userData['name'] ?? 'User';
        }
        
        // Create notification
        await database.ref('notifications/$userId').push().set({
          'type': 'chat',
          'title': 'New message from $senderName',
          'message': content.length > 50 ? '${content.substring(0, 47)}...' : content,
          'isRead': false,
          'createdAt': ServerValue.timestamp,
          'data': {
            'chatId': id,
            'senderId': senderId,
          },
        });
      }
    }
    
    return messageId;
  }
} 