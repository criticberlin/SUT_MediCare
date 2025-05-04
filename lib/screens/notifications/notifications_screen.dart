import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme/theme_provider.dart';
import '../../utils/theme/app_theme.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final unreadCount = _notifications.where((notif) => !notif.isRead).length;
    
    return Scaffold(
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
            label: Text(
              '$unreadCount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            isLabelVisible: unreadCount > 0,
            backgroundColor: AppTheme.primaryColor,
            child: IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
              ),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
            ),
            onSelected: (value) {
              if (value == 'clear') {
                setState(() {
                  _notifications.clear();
                  _filteredNotifications.clear();
                });
              }
            },
            color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_sweep, 
                      color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Clear all',
                      style: TextStyle(
                        color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                    ),
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
          unselectedLabelColor: isDarkMode 
              ? AppTheme.darkTextSecondaryColor 
              : AppTheme.textSecondaryColor,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.2) : AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.notifications_off_outlined,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.2) : AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      indent: 8,
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            ...sectionNotifications.asMap().entries.map((entry) {
              int index = entry.key;
              NotificationItem notification = entry.value;
              return _buildNotificationItem(notification, index);
            }),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, int index) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(notification.id),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
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
              content: Text(
                'Notification deleted',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.black87,
              action: SnackBarAction(
                label: 'Undo',
                textColor: AppTheme.primaryColor,
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
          elevation: notification.isRead ? 0 : 2,
          shadowColor: isDarkMode ? Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.3) : AppTheme.primaryColor.withValues(red: null, green: null, blue: null, alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDarkMode ? notification.isRead ? Colors.grey.shade800 : _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: 0.5) : notification.isRead ? Colors.grey.shade200 : _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: 0.3),
              width: notification.isRead ? 1 : 1.5,
            ),
          ),
          child: InkWell(
            onTap: () => _handleNotificationTap(notification),
            borderRadius: BorderRadius.circular(16),
            splashColor: _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: 0.1),
            highlightColor: _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: notification.isRead ? isDarkMode ? AppTheme.darkCardColor : theme.cardColor : isDarkMode ? _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: 0.15) : _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                gradient: notification.isRead ? null : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1),
                    _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.05 : 0.03),
                  ],
                ),
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
                                  color: notification.isRead ? isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor : _getNotificationTypeColor(notification.type).withValues(red: null, green: null, blue: null, alpha: 1),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey.shade800.withValues(red: null, green: null, blue: null, alpha: 0.5) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatTime(notification.time),
                                style: TextStyle(
                                  color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: notification.isRead ? isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor : isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        _buildActionButtons(notification),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Colors.blue;
      case NotificationType.message:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.promotion:
        return Colors.purple;
      case NotificationType.general:
        return AppTheme.primaryColor;
    }
  }

  Widget _buildNotificationIcon(NotificationType type) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    IconData icon;
    Color color = _getNotificationTypeColor(type);
    
    switch (type) {
      case NotificationType.appointment:
        icon = Icons.calendar_today;
        break;
      case NotificationType.message:
        icon = Icons.chat_bubble_outline;
        break;
      case NotificationType.reminder:
        icon = Icons.access_time;
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer_outlined;
        break;
      case NotificationType.general:
        icon = Icons.notifications_none;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(red: null, green: null, blue: null, alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(red: null, green: null, blue: null, alpha: isDarkMode ? 0.2 : 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color.withValues(red: null, green: null, blue: null, alpha: 1),
        size: 20,
      ),
    );
  }
  
  Widget _buildActionButtons(NotificationItem notification) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    Color primaryButtonColor = _getNotificationTypeColor(notification.type);
    
    switch (notification.type) {
      case NotificationType.appointment:
        return Row(
          children: [
            _buildActionButton('View details', primaryButtonColor, isDarkMode),
            const SizedBox(width: 12),
            _buildActionButton(
              'Reschedule', 
              isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor, 
              isDarkMode
            ),
          ],
        );
      case NotificationType.message:
        return _buildActionButton('Reply', primaryButtonColor, isDarkMode);
      case NotificationType.reminder:
        return _buildActionButton('Mark as done', primaryButtonColor, isDarkMode);
      case NotificationType.promotion:
        return _buildActionButton('View offer', primaryButtonColor, isDarkMode);
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildActionButton(String label, Color color, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(red: null, green: null, blue: null, alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(red: null, green: null, blue: null, alpha: 0.1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
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
    setState(() {
      final index = _notifications.indexWhere((item) => item.id == notification.id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = NotificationItem(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          time: notification.time,
          isRead: true,
          type: notification.type,
        );
        
        // Update filtered notifications based on current tab
        if (_tabController.index == 0) {
          _filteredNotifications = _notifications;
        } else {
          _filteredNotifications = _notifications.where((notif) => !notif.isRead).toList();
        }
      }
    });
    
    // Handle notification navigation based on type
    switch (notification.type) {
      case NotificationType.appointment:
        // Navigate to appointment details
        break;
      case NotificationType.message:
        // Navigate to chat
        break;
      case NotificationType.reminder:
        // Navigate to medication details
        break;
      case NotificationType.promotion:
        // Navigate to promotion details
        break;
      case NotificationType.general:
        // Just show a notification detail dialog
        break;
    }
  }
  
  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = NotificationItem(
            id: _notifications[i].id,
            title: _notifications[i].title,
            message: _notifications[i].message,
            time: _notifications[i].time,
            isRead: true,
            type: _notifications[i].type,
          );
        }
      }
      
      // Update filtered notifications based on current tab
      if (_tabController.index == 0) {
        _filteredNotifications = _notifications;
      } else {
        _filteredNotifications = _notifications.where((notif) => !notif.isRead).toList();
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All notifications marked as read',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
} 