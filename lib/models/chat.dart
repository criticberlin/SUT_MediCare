class Chat {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageSender;
  final int? lastMessageTime;
  final int createdAt;
  final int updatedAt;
  
  // Loaded data
  final Map<String, dynamic>? otherUser;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
    this.otherUser,
  });

  // Convert Chat to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'participantsString': participants.join(','),  // For querying
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageTime': lastMessageTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create Chat object from Map
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      participants: map['participants'] != null 
        ? List<String>.from(map['participants']) 
        : [],
      lastMessage: map['lastMessage'],
      lastMessageSender: map['lastMessageSender'],
      lastMessageTime: map['lastMessageTime'],
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      otherUser: map['otherUser'],
    );
  }
  
  // Create a copy of the chat with updated values
  Chat copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    String? lastMessageSender,
    int? lastMessageTime,
    int? createdAt,
    int? updatedAt,
    Map<String, dynamic>? otherUser,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      otherUser: otherUser ?? this.otherUser,
    );
  }
} 