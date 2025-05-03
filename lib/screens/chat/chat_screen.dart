import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../utils/theme/app_theme.dart';
import '../../routes.dart';
import '../../models/doctor.dart';

class ChatScreen extends StatefulWidget {
  final String doctorId;

  const ChatScreen({
    super.key, 
    required this.doctorId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<Message> _messages;
  late ChatPreview _chatData;
  bool _isAttachmentOpen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadChatData();
    
    // Scroll to bottom after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    _messages = Message.getDummyChatMessages(widget.doctorId);
  }

  void _loadChatData() {
    final doctor = _getDoctor();
    // Get the chat data from doctor data to ensure consistency
    _chatData = ChatPreview(
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      doctorImage: doctor.imageUrl,
      lastMessage: _getLastMessage(),
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0
    );
  }

  // Get doctor object from doctorId
  Doctor _getDoctor() {
    return Doctor.getDummyDoctors().firstWhere(
      (doctor) => doctor.id == widget.doctorId,
      orElse: () => Doctor.getDummyDoctors().first,
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'user1',
      receiverId: 'doctor${widget.doctorId}',
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
      type: MessageType.text,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
    
    // Scroll to bottom after adding new message
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleAttachment() {
    setState(() {
      _isAttachmentOpen = !_isAttachmentOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get doctor object to ensure we're using the most up-to-date data
    final doctor = _getDoctor();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.textPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: 'doctor_${doctor.id}',
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(doctor.imageUrl),
                onBackgroundImageError: (_, __) {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.videoCall,
                arguments: doctor,
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            onPressed: () {
              // Make a phone call
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          image: DecorationImage(
            image: const NetworkImage(
              'https://img.freepik.com/free-vector/abstract-medical-wallpaper-template-design_53876-61802.jpg',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.95),
              BlendMode.lighten,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildChatMessages(),
            ),
            if (_isAttachmentOpen) _buildAttachmentOptions(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages.reversed.toList()[index];
        final showAvatar = _shouldShowAvatar(index, _messages.reversed.toList());
        return _buildMessageItem(message, showAvatar);
      },
    );
  }

  bool _shouldShowAvatar(int index, List<Message> messages) {
    // Show avatar if it's from doctor AND the next message is from user or this is the last message
    if (index == messages.length - 1) {
      return !messages[index].isSent;
    }
    return !messages[index].isSent && messages[index + 1].isSent;
  }

  Widget _buildMessageItem(Message message, bool showAvatar) {
    final isSent = message.isSent;
    final doctor = _getDoctor();

    if (message.type == MessageType.image) {
      return _buildImageMessage(message, isSent, showAvatar, doctor);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        right: isSent ? 0 : 48,
        left: isSent ? 48 : 0,
      ),
      child: Row(
        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(doctor.imageUrl),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 8),
          ] else if (!isSent) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSent
                    ? AppTheme.primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isSent
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isSent
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSent && !showAvatar) ...[
                    // Show timestamp in a more subtle way in messenger style
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isSent ? Colors.white : AppTheme.textPrimaryColor,
                      fontSize: 15,
                    ),
                  ),
                  if (isSent) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(Message message, bool isSent, bool showAvatar, Doctor doctor) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 8,
          right: isSent ? 0 : 48,
          left: isSent ? 48 : 0,
        ),
        child: Row(
          mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSent && showAvatar) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(doctor.imageUrl),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 8),
            ] else if (!isSent) ...[
              const SizedBox(width: 40),
            ],
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              decoration: BoxDecoration(
                color: isSent
                    ? AppTheme.primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isSent
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isSent
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      message.content,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey.withOpacity(0.3),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppTheme.textSecondaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: isSent 
                                ? Colors.white.withOpacity(0.7) 
                                : AppTheme.textSecondaryColor,
                            fontSize: 10,
                          ),
                        ),
                        if (isSent) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOptions() {
    final options = [
      {'icon': Icons.image, 'label': 'Gallery', 'color': Colors.purple},
      {'icon': Icons.camera_alt, 'label': 'Camera', 'color': Colors.blue},
      {'icon': Icons.mic, 'label': 'Audio', 'color': Colors.orange},
      {'icon': Icons.insert_drive_file, 'label': 'Files', 'color': Colors.teal},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((option) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: option['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                option['label'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Material(
              type: MaterialType.circle,
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                onPressed: _toggleAttachment,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: AppTheme.textSecondaryColor,
                      ),
                      onPressed: () {
                        // Show emoji picker
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.mic_none,
                        color: AppTheme.textSecondaryColor,
                      ),
                      onPressed: () {
                        // Voice recording
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              type: MaterialType.circle,
              color: AppTheme.primaryColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper method to get the most recent message for each doctor
  String _getLastMessage() {
    final doctor = _getDoctor();
    switch (doctor.id) {
      case '1': // Ahmed Kamal
        return 'Great! I\'ll see you soon. Take care.';
      case '2': // Nour El-Sayed 
        return 'Please don\'t forget to bring your previous scan results.';
      case '3': // Tarek Mahmoud
        return 'Your test results look good. No need to worry.';
      case '4': // Kareem Hossam
        return 'Remember to take your medication regularly.';
      case '5': // Yasmine Adel
        return 'I\'ll see you at your next appointment.';
      default:
        return 'Thank you for your message.';
    }
  }
} 