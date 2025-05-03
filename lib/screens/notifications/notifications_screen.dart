import 'package:flutter/material.dart';
import '../../utils/theme/app_theme.dart';
import 'dart:math' as math;

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });

  // Get dummy notifications for testing
  static List<NotificationItem> getDummyNotifications() {
    return [
      NotificationItem(
        id: '1',
        title: 'Appointment Confirmed',
        message: 'Your appointment with Dr. Ahmed Kamal has been confirmed for tomorrow at 10:00 AM.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: NotificationType.appointment,
      ),
      NotificationItem(
        id: '2',
        title: 'New Message',
        message: 'Dr. Tarek Mahmoud sent you a message regarding your recent lab results.',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        type: NotificationType.message,
      ),
      NotificationItem(
        id: '3',
        title: 'Medication Reminder',
        message: 'Don\'t forget to take your medication today at 8:00 PM.',
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        type: NotificationType.reminder,
      ),
      NotificationItem(
        id: '4',
        title: 'Appointment Reminder',
        message: 'Your appointment with Dr. Nour El-Sayed is scheduled for tomorrow at 2:30 PM.',
        time: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        isRead: true,
        type: NotificationType.appointment,
      ),
      NotificationItem(
        id: '5',
        title: 'Special Offer',
        message: 'Get 20% off on your next consultation when booked before the end of the month.',
        time: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        type: NotificationType.promotion,
      ),
      NotificationItem(
        id: '6',
        title: 'Health Tips',
        message: 'Staying hydrated is essential for maintaining good health. Aim to drink at least 8 glasses of water daily.',
        time: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        type: NotificationType.general,
      ),
    ];
  }
}

enum NotificationType {
  appointment,
  message,
  reminder,
  promotion,
  general,
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late List<NotificationItem> _notifications;
  late TabController _tabController;
  late List<NotificationItem> _filteredNotifications;
  
  @override
  void initState() {
    super.initState();
    _notifications = NotificationItem.getDummyNotifications();
    _filteredNotifications = _notifications;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    setState(() {
      if (_tabController.index == 0) {
        // All notifications
        _filteredNotifications = _notifications;
      } else {
        // Unread notifications
        _filteredNotifications = _notifications.where((notif) => !notif.isRead).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((notif) => !notif.isRead).length;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          Badge(
            label: Text('$unreadCount'),
            isLabelVisible: unreadCount > 0,
            child: IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                setState(() {
                  _notifications.clear();
                  _filteredNotifications.clear();
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: AppTheme.textPrimaryColor),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          tabs: [
            const Tab(text: 'All'),
            Tab(text: 'Unread ($unreadCount)'),
          ],
        ),
      ),
      body: _filteredNotifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://img.freepik.com/free-vector/notification-concept-illustration_114360-4371.jpg',
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final today = DateTime.now().day;
    
    // Group notifications by date
    final Map<String, List<NotificationItem>> groupedNotifications = {};
    
    for (final notification in _filteredNotifications) {
      final date = notification.time;
      String key;
      
      if (date.day == today) {
        key = 'Today';
      } else if (date.day == today - 1) {
        key = 'Yesterday';
      } else {
        key = '${date.day}/${date.month}/${date.year}';
      }
      
      if (!groupedNotifications.containsKey(key)) {
        groupedNotifications[key] = [];
      }
      
      groupedNotifications[key]!.add(notification);
    }
    
    return TabBarView(
      controller: _tabController,
      children: [
        // All notifications
        _buildListView(groupedNotifications),
        // Unread notifications
        _buildListView(groupedNotifications),
      ],
    );
  }
  
  Widget _buildListView(Map<String, List<NotificationItem>> groupedNotifications) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, sectionIndex) {
        final date = groupedNotifications.keys.elementAt(sectionIndex);
        final sectionNotifications = groupedNotifications[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            ...sectionNotifications.map((notification) => _buildNotificationItem(notification)),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.red,
          size: 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((item) => item.id == notification.id);
          _filteredNotifications.removeWhere((item) => item.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  final deletedNotification = NotificationItem.getDummyNotifications()
                      .firstWhere((item) => item.id == notification.id);
                  _notifications.add(deletedNotification);
                  _notifications.sort((a, b) => b.time.compareTo(a.time));
                  
                  // Update filtered list based on current tab
                  if (_tabController.index == 0) {
                    _filteredNotifications = _notifications;
                  } else {
                    _filteredNotifications = _notifications.where((notif) => !notif.isRead).toList();
                  }
                });
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(8),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: notification.isRead ? Colors.white : AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.type),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                fontSize: 16,
                                color: notification.isRead 
                                    ? AppTheme.textPrimaryColor 
                                    : AppTheme.primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(notification.time),
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: notification.isRead
                              ? AppTheme.textSecondaryColor
                              : AppTheme.textPrimaryColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildActionButtons(notification),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.appointment:
        return Row(
          children: [
            _buildActionButton('View details', AppTheme.primaryColor),
            const SizedBox(width: 12),
            _buildActionButton('Reschedule', AppTheme.textSecondaryColor),
          ],
        );
      case NotificationType.message:
        return _buildActionButton('Reply', AppTheme.primaryColor);
      case NotificationType.reminder:
        return _buildActionButton('Mark as done', AppTheme.primaryColor);
      case NotificationType.promotion:
        return _buildActionButton('View offer', AppTheme.primaryColor);
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildActionButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color color;
    double rotationAngle = 0;

    switch (type) {
      case NotificationType.appointment:
        iconData = Icons.calendar_today;
        color = const Color(0xFF4285F4); // Google Blue
        break;
      case NotificationType.message:
        iconData = Icons.chat_bubble;
        color = const Color(0xFF34A853); // Google Green
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm;
        color = const Color(0xFFFBBC05); // Google Yellow
        rotationAngle = math.pi / 12; // Slightly tilted
        break;
      case NotificationType.promotion:
        iconData = Icons.local_offer;
        color = const Color(0xFFEA4335); // Google Red
        rotationAngle = -math.pi / 12; // Slightly tilted other way
        break;
      case NotificationType.general:
        iconData = Icons.info;
        color = const Color(0xFF9E9E9E); // Grey
        break;
    }

    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexWhere((item) => item.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationItem(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            time: notification.time,
            isRead: true,
            type: notification.type,
          );
          
          // Update filtered list if needed
          if (_tabController.index == 1) {
            _filteredNotifications = _notifications.where((notif) => !notif.isRead).toList();
          } else {
            _filteredNotifications = _notifications;
          }
        }
      });
    }

    // Show full notification content
    _showNotificationDetails(notification);
  }

  void _showNotificationDetails(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          notification.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildNotificationIcon(notification.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getNotificationTypeText(notification.type),
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          _getActionButton(notification.type),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  String _getNotificationTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return 'Appointment notification';
      case NotificationType.message:
        return 'Message notification';
      case NotificationType.reminder:
        return 'Medication reminder';
      case NotificationType.promotion:
        return 'Special offer';
      case NotificationType.general:
        return 'General information';
    }
  }
  
  Widget _getActionButton(NotificationType type) {
    String text;
    VoidCallback? onPressed;
    
    switch (type) {
      case NotificationType.appointment:
        text = 'View Appointment';
        onPressed = () {
          Navigator.pop(context);
          // Navigate to appointment details
        };
        break;
      case NotificationType.message:
        text = 'Reply';
        onPressed = () {
          Navigator.pop(context);
          // Navigate to chat screen
        };
        break;
      case NotificationType.reminder:
        text = 'Mark as Taken';
        onPressed = () {
          Navigator.pop(context);
          // Mark medication as taken
        };
        break;
      case NotificationType.promotion:
        text = 'View Offer';
        onPressed = () {
          Navigator.pop(context);
          // Navigate to promotions screen
        };
        break;
      case NotificationType.general:
        return const SizedBox.shrink(); // No action button for general notifications
    }
    
    return FilledButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((notification) {
        return NotificationItem(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          time: notification.time,
          isRead: true,
          type: notification.type,
        );
      }).toList();
      
      // Update filtered notifications
      if (_tabController.index == 0) {
        _filteredNotifications = _notifications;
      } else {
        _filteredNotifications = [];
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('All notifications marked as read'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }
} 