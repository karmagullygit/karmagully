import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../models/push_notification.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/responsive_utils.dart';
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() => _NotificationManagementScreenState();
}

class _NotificationManagementScreenState extends State<NotificationManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: ResponsiveUtils.getScreenHeight(context) * 0.15,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: ResponsiveUtils.getIconSize(context),
                    ),
                    onPressed: () => NavigationHelper.safePop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.analytics_rounded,
                        size: ResponsiveUtils.getIconSize(context),
                      ),
                      onPressed: () => _showAnalyticsDialog(isDarkMode),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: FadeTransition(
                      opacity: _fadeController,
                      child: Text(
                        'Push Notifications',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                            AppColors.secondary.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -ResponsiveUtils.getScreenWidth(context) * 0.1,
                            top: -ResponsiveUtils.getScreenHeight(context) * 0.05,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, -1),
                                end: Offset.zero,
                              ).animate(_slideController),
                              child: Icon(
                                Icons.notifications_active_rounded,
                                size: ResponsiveUtils.getScreenWidth(context) * 0.3,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.getTextSecondaryColor(isDarkMode),
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context) * 0.85,
                          fontWeight: FontWeight.w600,
                        ),
                        isScrollable: true,
                        tabs: [
                          Tab(
                            icon: Icon(
                              Icons.send_rounded,
                              size: ResponsiveUtils.getIconSize(context) * 0.9,
                            ),
                            text: 'Sent',
                          ),
                          Tab(
                            icon: Icon(
                              Icons.schedule_rounded,
                              size: ResponsiveUtils.getIconSize(context) * 0.9,
                            ),
                            text: 'Scheduled',
                          ),
                          Tab(
                            icon: Icon(
                              Icons.error_rounded,
                              size: ResponsiveUtils.getIconSize(context) * 0.9,
                            ),
                            text: 'Failed',
                          ),
                          Tab(
                            icon: Icon(
                              Icons.bar_chart_rounded,
                              size: ResponsiveUtils.getIconSize(context) * 0.9,
                            ),
                            text: 'Analytics',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildSentNotificationsTab(isDarkMode),
                _buildScheduledNotificationsTab(isDarkMode),
                _buildFailedNotificationsTab(isDarkMode),
                _buildAnalyticsTab(isDarkMode),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(isDarkMode),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showCreateNotificationDialog(isDarkMode),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(
          Icons.add_rounded,
          size: ResponsiveUtils.getIconSize(context),
        ),
        label: Text(
          'New Notification',
          style: TextStyle(
            fontSize: ResponsiveUtils.getBodyFontSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSentNotificationsTab(bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = notificationProvider.sentNotifications;

        if (notifications.isEmpty) {
          return _buildEmptyState(
            isDarkMode: isDarkMode,
            icon: Icons.send_rounded,
            title: 'No Sent Notifications',
            subtitle: 'Your sent notifications will appear here',
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
              return _buildNotificationCard(notifications[index], isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildScheduledNotificationsTab(bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = notificationProvider.scheduledNotifications;

        if (notifications.isEmpty) {
          return _buildEmptyState(
            isDarkMode: isDarkMode,
            icon: Icons.schedule_rounded,
            title: 'No Scheduled Notifications',
            subtitle: 'Schedule notifications to be sent later',
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
              return _buildNotificationCard(notifications[index], isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildFailedNotificationsTab(bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = notificationProvider.failedNotifications;

        if (notifications.isEmpty) {
          return _buildEmptyState(
            isDarkMode: isDarkMode,
            icon: Icons.check_circle_rounded,
            title: 'All Good!',
            subtitle: 'No failed notifications to show',
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
              return _buildNotificationCard(notifications[index], isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
          child: Column(
            children: [
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              _buildStatsCard(isDarkMode, notificationProvider),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
              _buildTypeDistributionCard(isDarkMode, notificationProvider),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
              _buildPerformanceCard(isDarkMode, notificationProvider),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 3),
            ],
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

  Widget _buildNotificationCard(PushNotification notification, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getVerticalSpacing(context)),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            child: Row(
              children: [
                _buildTypeIcon(notification.type),
                SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(isDarkMode),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.3),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(notification, isDarkMode),
              ],
            ),
          ),
          
          // Image if available
          if (notification.imageUrl != null) ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
              height: ResponsiveUtils.getScreenHeight(context) * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                image: DecorationImage(
                  image: NetworkImage(notification.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
          ],
          
          // Footer
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: ResponsiveUtils.getIconSize(context) * 0.8,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
                SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5),
                Text(
                  notification.isScheduled
                      ? 'Scheduled: ${DateFormat('MMM d, h:mm a').format(notification.scheduledAt!)}'
                      : 'Sent: ${DateFormat('MMM d, h:mm a').format(notification.sentAt ?? notification.createdAt)}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getCaptionFontSize(context),
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                  ),
                ),
                const Spacer(),
                if (!notification.isSent && notification.isScheduled) ...[
                  TextButton.icon(
                    onPressed: () => _sendNowDialog(notification),
                    icon: Icon(
                      Icons.send_rounded,
                      size: ResponsiveUtils.getIconSize(context) * 0.8,
                    ),
                    label: Text(
                      'Send Now',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                      ),
                    ),
                  ),
                ],
                PopupMenuButton<String>(
                  onSelected: (value) => _handleNotificationAction(value, notification),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: ResponsiveUtils.getIconSize(context) * 0.8,
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(NotificationType type) {
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
      padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.6),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: ResponsiveUtils.getIconSize(context),
      ),
    );
  }

  Widget _buildStatusChip(PushNotification notification, bool isDarkMode) {
    Color chipColor;
    String text;

    if (notification.isScheduled) {
      chipColor = AppColors.warning;
      text = 'SCHEDULED';
    } else if (notification.isFailed) {
      chipColor = AppColors.error;
      text = 'FAILED';
    } else if (notification.isSent) {
      chipColor = AppColors.success;
      text = 'SENT';
    } else {
      chipColor = Colors.grey;
      text = 'DRAFT';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalSpacing(context),
        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.3,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveUtils.getCaptionFontSize(context),
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isDarkMode, NotificationProvider provider) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 1.5),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  isDarkMode: isDarkMode,
                  title: 'Total Sent',
                  value: provider.sentNotifications.length.toString(),
                  icon: Icons.send_rounded,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  isDarkMode: isDarkMode,
                  title: 'Scheduled',
                  value: provider.scheduledNotifications.length.toString(),
                  icon: Icons.schedule_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  isDarkMode: isDarkMode,
                  title: 'Delivery Rate',
                  value: '${(provider.getDeliveryRate() * 100).toStringAsFixed(1)}%',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  isDarkMode: isDarkMode,
                  title: 'Failed',
                  value: provider.failedNotifications.length.toString(),
                  icon: Icons.error_rounded,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required bool isDarkMode,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveUtils.getIconSize(context) * 1.2,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.5),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.8,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(isDarkMode),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.getCaptionFontSize(context),
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDistributionCard(bool isDarkMode, NotificationProvider provider) {
    final stats = provider.getNotificationStatsByType();
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Types',
            style: TextStyle(
              fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 1.5),
          ...stats.entries.map((entry) => _buildTypeStatRow(
            isDarkMode: isDarkMode,
            type: entry.key,
            count: entry.value,
          )),
        ],
      ),
    );
  }

  Widget _buildTypeStatRow({
    required bool isDarkMode,
    required String type,
    required int count,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getVerticalSpacing(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              type.substring(0, 1).toUpperCase() + type.substring(1),
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
          ),
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
              count.toString(),
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(bool isDarkMode, NotificationProvider provider) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: TextStyle(
              fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 1.5),
          _buildPerformanceRow(
            isDarkMode: isDarkMode,
            title: 'Delivery Rate',
            value: '${(provider.getDeliveryRate() * 100).toStringAsFixed(1)}%',
            color: AppColors.success,
          ),
          _buildPerformanceRow(
            isDarkMode: isDarkMode,
            title: 'Read Rate',
            value: '${(provider.getReadRate() * 100).toStringAsFixed(1)}%',
            color: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow({
    required bool isDarkMode,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getVerticalSpacing(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateNotificationDialog(bool isDarkMode) {
    // Implementation for create notification dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CreateNotificationDialog(isDarkMode: isDarkMode),
    );
  }

  void _showAnalyticsDialog(bool isDarkMode) {
    // Implementation for analytics dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Analytics'),
        content: const Text('Detailed analytics coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sendNowDialog(PushNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Now'),
        content: Text('Send "${notification.title}" immediately?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<NotificationProvider>(context, listen: false)
                  .sendNotification(notification.id);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationAction(String action, PushNotification notification) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    
    switch (action) {
      case 'edit':
        // Implementation for edit
        break;
      case 'duplicate':
        // Implementation for duplicate
        break;
      case 'delete':
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }
}

class _CreateNotificationDialog extends StatefulWidget {
  final bool isDarkMode;

  const _CreateNotificationDialog({required this.isDarkMode});

  @override
  State<_CreateNotificationDialog> createState() => _CreateNotificationDialogState();
}

class _CreateNotificationDialogState extends State<_CreateNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  NotificationType _selectedType = NotificationType.general;
  NotificationPriority _selectedPriority = NotificationPriority.normal;
  DateTime? _scheduledDateTime;
  bool _isGlobal = true;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
      ),
      title: const Text('Create Notification'),
      content: SizedBox(
        width: ResponsiveUtils.getScreenWidth(context) * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                DropdownButtonFormField<NotificationType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: NotificationType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name.substring(0, 1).toUpperCase() + type.name.substring(1)),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                DropdownButtonFormField<NotificationPriority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: NotificationPriority.values.map((priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name.substring(0, 1).toUpperCase() + priority.name.substring(1)),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedPriority = value!),
                ),
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                ListTile(
                  title: const Text('Schedule for later'),
                  trailing: Switch(
                    value: _scheduledDateTime != null,
                    onChanged: (value) {
                      setState(() {
                        _scheduledDateTime = value ? DateTime.now().add(const Duration(hours: 1)) : null;
                      });
                    },
                  ),
                ),
                if (_scheduledDateTime != null) ...[
                  ListTile(
                    title: Text('Send at: ${DateFormat('MMM d, h:mm a').format(_scheduledDateTime!)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _selectDateTime(),
                    ),
                  ),
                ],
                SwitchListTile(
                  title: const Text('Send to all users'),
                  value: _isGlobal,
                  onChanged: (value) => setState(() => _isGlobal = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createNotification,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledDateTime ?? DateTime.now()),
      );

      if (time != null && mounted) {
        setState(() {
          _scheduledDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _createNotification() {
    if (_formKey.currentState?.validate() == true) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      
      provider.createNotification(
        title: _titleController.text,
        body: _bodyController.text,
        imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
        type: _selectedType,
        priority: _selectedPriority,
        scheduledAt: _scheduledDateTime,
        isGlobal: _isGlobal,
        createdBy: 'admin',
      );

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_scheduledDateTime == null ? 'Notification sent!' : 'Notification scheduled!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}