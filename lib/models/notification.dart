import 'package:firebase_database/firebase_database.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'appointment', 'chat', 'system', etc.
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // Additional data specific to the notification type

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  // Create a new notification in Firebase
  static Future<String> create({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final database = FirebaseDatabase.instance;
    final notificationRef = database.ref('notifications/$userId').push();
    final id = notificationRef.key!;
    
    await notificationRef.set({
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': ServerValue.timestamp,
      'data': data,
    });
    
    return id;
  }

  // Convert notification to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
    };
  }

  // Create notification from Map
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'system',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : map['createdAt'] is String
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      data: map['data'],
    );
  }

  // Create a copy of this notification with updated fields
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  // Mark notification as read
  Future<void> markAsRead() async {
    final database = FirebaseDatabase.instance;
    await database.ref('notifications/$userId/$id').update({
      'isRead': true,
    });
  }

  // Get notifications for a user
  static Stream<List<AppNotification>> getNotificationsForUser(String userId) {
    final database = FirebaseDatabase.instance;
    final notificationsRef = database.ref('notifications/$userId');
    
    return notificationsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];
      
      final notificationsData = event.snapshot.value as Map<dynamic, dynamic>;
      final notifications = <AppNotification>[];
      
      notificationsData.forEach((key, value) {
        final data = value as Map<dynamic, dynamic>;
        notifications.add(AppNotification.fromMap({
          'id': key,
          ...Map<String, dynamic>.from(data),
        }));
      });
      
      // Sort by created date, newest first
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  // Get unread notification count for a user
  static Stream<int> getUnreadCount(String userId) {
    return getNotificationsForUser(userId).map(
      (notifications) => notifications.where((n) => !n.isRead).length,
    );
  }

  // Delete notification
  Future<void> delete() async {
    final database = FirebaseDatabase.instance;
    await database.ref('notifications/$userId/$id').remove();
  }

  // Create an appointment notification
  static Future<String> createAppointmentNotification({
    required String userId,
    required String appointmentId,
    required String title,
    required String message,
  }) async {
    return create(
      userId: userId,
      title: title,
      message: message,
      type: 'appointment',
      data: {
        'appointmentId': appointmentId,
      },
    );
  }

  // Create a chat notification
  static Future<String> createChatNotification({
    required String userId,
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    return create(
      userId: userId,
      title: 'New message from $senderName',
      message: message,
      type: 'chat',
      data: {
        'chatId': chatId,
        'senderId': senderId,
      },
    );
  }
} 