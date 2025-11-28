import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../models/push_notification.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/responsive_utils.dart';
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            title: Text(
              'Notifications',
              style: TextStyle(
                fontSize: ResponsiveUtils.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: ResponsiveUtils.getIconSize(context),
              ),
              onPressed: () => NavigationHelper.safePop(context),
            ),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final unreadCount = notificationProvider.unreadCount;
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.mark_email_read_rounded,
                          size: ResponsiveUtils.getIconSize(context),
                        ),
                        onPressed: unreadCount > 0 
                            ? () => notificationProvider.markAllNotificationsAsRead()
                            : null,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'settings', child: Text('Settings')),
                  const PopupMenuItem(value: 'clear_all', child: Text('Clear All')),
                ],
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: ResponsiveUtils.getIconSize(context),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(ResponsiveUtils.getScreenHeight(context) * 0.08),
              child: Container(
                height: ResponsiveUtils.getScreenHeight(context) * 0.08,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
                    topRight: Radius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.getTextSecondaryColor(isDarkMode),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.inbox_rounded,
                        size: ResponsiveUtils.getIconSize(context) * 0.9,
                      ),
                      text: 'All',
                    ),
                    Tab(
                      icon: Icon(
                        Icons.circle_notifications_rounded,
                        size: ResponsiveUtils.getIconSize(context) * 0.9,
                      ),
                      text: 'Unread',
                    ),
                    Tab(
                      icon: Icon(
                        Icons.local_offer_rounded,
                        size: ResponsiveUtils.getIconSize(context) * 0.9,
                      ),
                      text: 'Offers',
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              _buildFilterChips(isDarkMode),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllNotificationsTab(isDarkMode),
                    _buildUnreadNotificationsTab(isDarkMode),
                    _buildOffersTab(isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.inbox_rounded},
      {'key': 'orders', 'label': 'Orders', 'icon': Icons.shopping_bag_rounded},
      {'key': 'promotions', 'label': 'Promotions', 'icon': Icons.campaign_rounded},
      {'key': 'system', 'label': 'System', 'icon': Icons.settings_rounded},
    ];

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
        vertical: ResponsiveUtils.getVerticalSpacing(context),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return Container(
            margin: EdgeInsets.only(right: ResponsiveUtils.getHorizontalSpacing(context)),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: ResponsiveUtils.getIconSize(context) * 0.8,
                    color: isSelected ? Colors.white : AppColors.getTextColor(isDarkMode),
                  ),
                  SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getBodyFontSize(context),
                      color: isSelected ? Colors.white : AppColors.getTextColor(isDarkMode),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key'] as String;
                });
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllNotificationsTab(bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = _getFilteredNotifications(notificationProvider.userNotifications);

        if (notifications.isEmpty) {
          return _buildEmptyState(
            isDarkMode: isDarkMode,
            icon: Icons.notifications_none_rounded,
            title: 'No Notifications',
            subtitle: 'You\'ll see your notifications here when they arrive',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh logic here
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notifications[index], isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildUnreadNotificationsTab(bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = notificationProvider.getUnreadNotifications();

        if (notifications.isEmpty) {
          return _buildEmptyState(
            isDarkMode: isDarkMode,
            icon: Icons.mark_email_read_rounded,
            title: 'All Caught Up!',
            subtitle: 'You have no unread notifications',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notifications[index], isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildOffersTab(bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = notificationProvider.getNotificationsByType(NotificationType.promotional) +
                             notificationProvider.getNotificationsByType(NotificationType.flashSale);

        if (notifications.isEmpty) {
          return _buildEmptyState(
            isDarkMode: isDarkMode,
            icon: Icons.local_offer_rounded,
            title: 'No Offers',
            subtitle: 'Special offers and promotions will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notifications[index], isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required bool isDarkMode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: FadeTransition(
        opacity: _fadeController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: ResponsiveUtils.getScreenWidth(context) * 0.3,
                    height: ResponsiveUtils.getScreenWidth(context) * 0.3,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: ResponsiveUtils.getIconSize(context) * 3,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(PushNotification notification, bool isDarkMode) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: ResponsiveUtils.getHorizontalPadding(context)),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: ResponsiveUtils.getIconSize(context),
        ),
      ),
      onDismissed: (direction) {
        Provider.of<NotificationProvider>(context, listen: false)
            .deleteUserNotification(notification.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Implement undo functionality
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUtils.getVerticalSpacing(context)),
        decoration: BoxDecoration(
          color: AppColors.getCardBackgroundColor(isDarkMode),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
          border: !notification.isRead 
              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(isDarkMode),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.type, !notification.isRead),
                SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                color: AppColors.getTextColor(isDarkMode),
                              ),
                            ),
                          ),
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getCaptionFontSize(context),
                              color: AppColors.getTextSecondaryColor(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.5),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context) * 0.9,
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.imageUrl != null) ...[
                        SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 0.5),
                          child: Image.network(
                            notification.imageUrl!,
                            height: ResponsiveUtils.getScreenHeight(context) * 0.12,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: ResponsiveUtils.getScreenHeight(context) * 0.12,
                              decoration: BoxDecoration(
                                color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 0.5),
                              ),
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: AppColors.getTextSecondaryColor(isDarkMode),
                              ),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.5),
                      Row(
                        children: [
                          _buildTypeChip(notification.type, isDarkMode),
                          const Spacer(),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildNotificationIcon(NotificationType type, bool isUnread) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.promotional:
        iconData = Icons.campaign_rounded;
        iconColor = AppColors.primary;
        break;
      case NotificationType.orderUpdate:
        iconData = Icons.shopping_bag_rounded;
        iconColor = AppColors.success;
        break;
      case NotificationType.flashSale:
        iconData = Icons.flash_on_rounded;
        iconColor = AppColors.warning;
        break;
      case NotificationType.newProduct:
        iconData = Icons.new_releases_rounded;
        iconColor = AppColors.info;
        break;
      case NotificationType.system:
        iconData = Icons.settings_rounded;
        iconColor = Colors.grey;
        break;
      case NotificationType.review:
        iconData = Icons.star_rounded;
        iconColor = Colors.amber;
        break;
      case NotificationType.general:
        iconData = Icons.notifications_rounded;
        iconColor = AppColors.primary;
        break;
    }

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(isUnread ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
        border: isUnread ? Border.all(color: iconColor.withOpacity(0.3)) : null,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: ResponsiveUtils.getIconSize(context),
      ),
    );
  }

  Widget _buildTypeChip(NotificationType type, bool isDarkMode) {
    String text;
    Color color;

    switch (type) {
      case NotificationType.promotional:
        text = 'Promo';
        color = AppColors.primary;
        break;
      case NotificationType.orderUpdate:
        text = 'Order';
        color = AppColors.success;
        break;
      case NotificationType.flashSale:
        text = 'Flash Sale';
        color = AppColors.warning;
        break;
      case NotificationType.newProduct:
        text = 'New';
        color = AppColors.info;
        break;
      case NotificationType.system:
        text = 'System';
        color = Colors.grey;
        break;
      case NotificationType.review:
        text = 'Review';
        color = Colors.amber;
        break;
      case NotificationType.general:
        text = 'General';
        color = AppColors.primary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalSpacing(context) * 0.8,
        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveUtils.getCaptionFontSize(context) * 0.9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<PushNotification> _getFilteredNotifications(List<PushNotification> notifications) {
    switch (_selectedFilter) {
      case 'orders':
        return notifications.where((n) => n.type == NotificationType.orderUpdate).toList();
      case 'promotions':
        return notifications.where((n) => 
            n.type == NotificationType.promotional || 
            n.type == NotificationType.flashSale).toList();
      case 'system':
        return notifications.where((n) => n.type == NotificationType.system).toList();
      case 'all':
      default:
        return notifications;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  void _handleNotificationTap(PushNotification notification) {
    // Mark as read
    if (!notification.isRead) {
      Provider.of<NotificationProvider>(context, listen: false)
          .markNotificationAsRead(notification.id);
    }

    // Handle navigation based on notification type and data
    if (notification.actionUrl != null) {
      // Navigate to specific URL or screen
      _handleNotificationAction(notification);
    } else {
      // Show notification details
      _showNotificationDetails(notification);
    }
  }

  void _handleNotificationAction(PushNotification notification) {
    // TODO: Implement navigation based on notification type and data
    // Example:
    // if (notification.productId != null) {
    //   Navigator.pushNamed(context, '/product', arguments: notification.productId);
    // } else if (notification.orderId != null) {
    //   Navigator.pushNamed(context, '/order-details', arguments: notification.orderId);
    // }
    
    _showNotificationDetails(notification);
  }

  void _showNotificationDetails(PushNotification notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NotificationDetailsSheet(
        notification: notification,
        isDarkMode: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
      ),
    );
  }

  void _handleMenuAction(String action) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    
    switch (action) {
      case 'settings':
        Navigator.pushNamed(context, '/notification-settings');
        break;
      case 'clear_all':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear All Notifications'),
            content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.clearAllUserNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All notifications cleared'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Clear All', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        break;
    }
  }
}

class _NotificationDetailsSheet extends StatelessWidget {
  final PushNotification notification;
  final bool isDarkMode;

  const _NotificationDetailsSheet({
    required this.notification,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: ResponsiveUtils.getVerticalSpacing(context)),
              width: ResponsiveUtils.getScreenWidth(context) * 0.15,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(isDarkMode),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                
                // Time and type
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: ResponsiveUtils.getIconSize(context) * 0.8,
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                    SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(notification.createdAt),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getHorizontalSpacing(context),
                        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                      ),
                      child: Text(
                        notification.typeDisplayName,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getCaptionFontSize(context),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 1.5),
                
                // Body
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    color: AppColors.getTextColor(isDarkMode),
                    height: 1.5,
                  ),
                ),
                
                // Image if available
                if (notification.imageUrl != null) ...[
                  SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 1.5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                    child: Image.network(
                      notification.imageUrl!,
                      width: double.infinity,
                      height: ResponsiveUtils.getScreenHeight(context) * 0.2,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: ResponsiveUtils.getScreenHeight(context) * 0.2,
                        decoration: BoxDecoration(
                          color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                        ),
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          size: ResponsiveUtils.getIconSize(context) * 2,
                        ),
                      ),
                    ),
                  ),
                ],
                
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
                
                // Actions
                if (notification.actionUrl != null || notification.productId != null || notification.orderId != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Handle navigation based on notification data
                      },
                      icon: Icon(
                        Icons.launch_rounded,
                        size: ResponsiveUtils.getIconSize(context),
                      ),
                      label: Text(
                        _getActionButtonText(),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.getVerticalPadding(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                        ),
                      ),
                    ),
                  ),
                
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActionButtonText() {
    if (notification.productId != null) {
      return 'View Product';
    } else if (notification.orderId != null) {
      return 'View Order';
    } else if (notification.actionUrl != null) {
      return 'Open';
    } else {
      return 'View Details';
    }
  }
}