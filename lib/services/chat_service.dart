import 'package:firebase_database/firebase_database.dart';
import 'base_service.dart';

class ChatService extends BaseService {
  // Get or create chat between two users
  Future<String> getOrCreateChat(String otherUserId) async {
    if (!isAuthenticated) throw 'User not authenticated';

    // Check if chat already exists
    final chats = await getData('chats');
    if (chats != null) {
      for (final entry in chats.entries) {
        final chat = entry.value as Map<String, dynamic>;
        final participants = chat['participants'] as Map<String, dynamic>;
        if (participants['user1'] == currentUserId && participants['user2'] == otherUserId ||
            participants['user1'] == otherUserId && participants['user2'] == currentUserId) {
          return entry.key;
        }
      }
    }

    // Create new chat
    final chatRef = await pushData('chats', {
      'participants': {
        'user1': currentUserId,
        'user2': otherUserId,
      },
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });

    return chatRef.key!;
  }

  // Send message
  Future<void> sendMessage(String chatId, String content, {String type = 'text'}) async {
    if (!isAuthenticated) throw 'User not authenticated';

    final messageRef = await pushData('chats/$chatId/messages', {
      'senderId': currentUserId,
      'content': content,
      'type': type,
      'timestamp': ServerValue.timestamp,
      'read': false,
    });

    // Update last message
    await updateData('chats/$chatId/lastMessage', {
      'content': content,
      'timestamp': ServerValue.timestamp,
      'senderId': currentUserId,
    });

    // Update chat timestamp
    await updateData('chats/$chatId', {
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Get chat messages
  Stream<DatabaseEvent> getChatMessages(String chatId) {
    return streamData('chats/$chatId/messages');
  }

  // Get user's chats
  Stream<DatabaseEvent> getUserChats() {
    if (!isAuthenticated) throw 'User not authenticated';
    return streamData('chats');
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    if (!isAuthenticated) throw 'User not authenticated';

    final messages = await getData('chats/$chatId/messages');
    if (messages != null) {
      for (final entry in messages.entries) {
        final message = entry.value as Map<String, dynamic>;
        if (message['senderId'] != currentUserId && message['read'] == false) {
          await updateData('chats/$chatId/messages/${entry.key}', {
            'read': true,
          });
        }
      }
    }
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await deleteData('chats/$chatId');
  }

  // Delete message
  Future<void> deleteMessage(String chatId, String messageId) async {
    if (!isAuthenticated) throw 'User not authenticated';
    await deleteData('chats/$chatId/messages/$messageId');
  }
} 