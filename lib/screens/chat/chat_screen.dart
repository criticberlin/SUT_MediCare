import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../routes.dart';
import '../../models/doctor.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Message> _messages = [];
  late Doctor _doctor;
  bool _isAttachmentOpen = false;
  final ScrollController _scrollController = ScrollController();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
    _loadChat();
    
    // Scroll to bottom after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _loadDoctor() async {
    final doctor = await Doctor.getDoctorById(widget.doctorId);
    if (doctor != null) {
      setState(() {
        _doctor = doctor;
      });
    }
  }

  Future<void> _loadChat() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Listen to messages using the Message model's method
    Message.getChatMessages(widget.doctorId).listen((messages) {
      setState(() {
        _messages = messages;
      });
      _markMessagesAsRead();
    });
  }

  Future<void> _markMessagesAsRead() async {
    for (final message in _messages) {
      if (!message.isRead && !message.isSent) {
        await message.markAsRead();
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _auth.currentUser?.uid ?? '',
      receiverId: widget.doctorId,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
      type: MessageType.text,
    );

    await message.send();
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: 'doctor_${_doctor.id}',
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(_doctor.imageUrl),
                onBackgroundImageError: (_, __) {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${_doctor.name}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _doctor.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
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
                color: AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.1),
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
                arguments: _doctor,
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.1),
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
          color: isDarkMode ? AppTheme.darkBackgroundColor : Colors.grey.shade50,
          image: DecorationImage(
            image: const NetworkImage(
              'https://img.freepik.com/free-vector/abstract-medical-wallpaper-template-design_53876-61802.jpg',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              isDarkMode 
                ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.85) 
                : Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.95),
              isDarkMode ? BlendMode.darken : BlendMode.lighten,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildChatMessages(isDarkMode),
            ),
            if (_isAttachmentOpen) _buildAttachmentOptions(isDarkMode),
            _buildMessageInput(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages(bool isDarkMode) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages.reversed.toList()[index];
        final showAvatar = _shouldShowAvatar(index, _messages.reversed.toList());
        return _buildMessageItem(message, showAvatar, isDarkMode);
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

  Widget _buildMessageItem(Message message, bool showAvatar, bool isDarkMode) {
    final isSent = message.isSent;

    if (message.type == MessageType.image) {
      return _buildImageMessage(message, isSent, showAvatar, isDarkMode);
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
              backgroundImage: NetworkImage(_doctor.imageUrl),
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
                    : isDarkMode ? AppTheme.darkCardColor : Colors.white,
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
                    color: isDarkMode 
                        ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2) 
                        : Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.05),
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
                          color: isDarkMode 
                              ? AppTheme.darkTextSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7) 
                              : AppTheme.textSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isSent 
                          ? Colors.white 
                          : isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
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
                              color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 12,
                            color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.7),
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

  Widget _buildImageMessage(Message message, bool isSent, bool showAvatar, bool isDarkMode) {
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
                backgroundImage: NetworkImage(_doctor.imageUrl),
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
                    : isDarkMode ? AppTheme.darkCardColor : Colors.white,
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
                    color: isDarkMode 
                        ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2) 
                        : Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.05),
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
                          color: isDarkMode 
                              ? Colors.grey.shade800 
                              : Colors.grey.withValues(red: null, green: null, blue: null, alpha: 0.3),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: isDarkMode 
                                ? AppTheme.darkTextSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7) 
                                : AppTheme.textSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7),
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
                                ? Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.7) 
                                : isDarkMode 
                                    ? AppTheme.darkTextSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7) 
                                    : AppTheme.textSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                        if (isSent) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 12,
                            color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.7),
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

  Widget _buildAttachmentOptions(bool isDarkMode) {
    final options = [
      {'icon': Icons.image, 'label': 'Gallery', 'color': Colors.purple},
      {'icon': Icons.camera_alt, 'label': 'Camera', 'color': Colors.blue},
      {'icon': Icons.mic, 'label': 'Audio', 'color': Colors.orange},
      {'icon': Icons.insert_drive_file, 'label': 'Files', 'color': Colors.teal},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2) 
                : Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.05),
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode 
                      ? AppTheme.darkTextSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7) 
                      : AppTheme.textSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageInput(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.2) 
                : Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.05),
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
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDarkMode 
                                ? AppTheme.darkTextSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7) 
                                : AppTheme.textSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: TextStyle(
                          color: isDarkMode 
                              ? AppTheme.darkTextPrimaryColor 
                              : AppTheme.textPrimaryColor,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: isDarkMode 
                            ? AppTheme.darkTextSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7) 
                            : AppTheme.textSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7),
                      ),
                      onPressed: () {
                        // Show emoji picker
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.mic_none,
                        color: isDarkMode 
                            ? AppTheme.darkTextSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7) 
                            : AppTheme.textSecondaryColor.withValues(red: null, green: null, blue: null, alpha: 0.7),
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
} 