class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final bool read;
  final int createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.read,
    required this.createdAt,
  });

  // Convert Notification to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': referenceId,
      'read': read,
      'createdAt': createdAt,
    };
  }

  // Create Notification object from Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      referenceId: map['referenceId'],
      read: map['read'] ?? false,
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  // Create a copy of the notification with updated values
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? referenceId,
    bool? read,
    int? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 