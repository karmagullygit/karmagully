import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/push_notification.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/responsive_utils.dart';
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  TimeOfDay? _quietHoursStart;
  TimeOfDay? _quietHoursEnd;

  @override
  void initState() {
    super.initState();
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
    
    // Initialize quiet hours from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      final settings = provider.userSettings;
      if (settings != null) {
        final startParts = settings.quietHoursStart.split(':');
        final endParts = settings.quietHoursEnd.split(':');
        _quietHoursStart = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
        _quietHoursEnd = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
      }
    });
  }

  @override
  void dispose() {
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
                    PopupMenuButton<String>(
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'reset', child: Text('Reset to Default')),
                        const PopupMenuItem(value: 'test', child: Text('Send Test Notification')),
                      ],
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: ResponsiveUtils.getIconSize(context),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: FadeTransition(
                      opacity: _fadeController,
                      child: Text(
                        'Notification Settings',
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
                                Icons.settings_rounded,
                                size: ResponsiveUtils.getScreenWidth(context) * 0.3,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                final settings = notificationProvider.userSettings;
                
                if (settings == null) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                  child: Column(
                    children: [
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                      _buildGeneralSection(isDarkMode, settings, notificationProvider),
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
                      _buildNotificationTypesSection(isDarkMode, settings, notificationProvider),
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
                      _buildSoundAndVibrationSection(isDarkMode, settings, notificationProvider),
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
                      _buildQuietHoursSection(isDarkMode, settings, notificationProvider),
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 3),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneralSection(bool isDarkMode, NotificationSettings settings, NotificationProvider provider) {
    return _buildSection(
      isDarkMode: isDarkMode,
      title: 'General',
      icon: Icons.notifications_rounded,
      children: [
        _buildSwitchTile(
          isDarkMode: isDarkMode,
          title: 'Push Notifications',
          subtitle: 'Receive notifications on this device',
          value: settings.enablePushNotifications,
          onChanged: (value) => _updateSettings(provider, settings.copyWith(enablePushNotifications: value)),
          leading: Icon(
            Icons.notifications_active_rounded,
            color: settings.enablePushNotifications ? AppColors.success : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTypesSection(bool isDarkMode, NotificationSettings settings, NotificationProvider provider) {
    return _buildSection(
      isDarkMode: isDarkMode,
      title: 'Notification Types',
      icon: Icons.category_rounded,
      children: [
        _buildSwitchTile(
          isDarkMode: isDarkMode,
          title: 'Promotional Offers',
          subtitle: 'Deals, discounts, and special offers',
          value: settings.enablePromotional,
          onChanged: settings.enablePushNotifications 
              ? (value) => _updateSettings(provider, settings.copyWith(enablePromotional: value))
              : null,
          leading: Icon(
            Icons.campaign_rounded,
            color: settings.enablePromotional && settings.enablePushNotifications 
                ? AppColors.primary 
                : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
        _buildSwitchTile(
          isDarkMode: isDarkMode,
          title: 'Order Updates',
          subtitle: 'Updates about your orders and deliveries',
          value: settings.enableOrderUpdates,
          onChanged: settings.enablePushNotifications 
              ? (value) => _updateSettings(provider, settings.copyWith(enableOrderUpdates: value))
              : null,
          leading: Icon(
            Icons.shopping_bag_rounded,
            color: settings.enableOrderUpdates && settings.enablePushNotifications 
                ? AppColors.success 
                : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
        _buildSwitchTile(
          isDarkMode: isDarkMode,
          title: 'Flash Sales',
          subtitle: 'Limited-time offers and flash sales',
          value: settings.enableFlashSales,
          onChanged: settings.enablePushNotifications 
              ? (value) => _updateSettings(provider, settings.copyWith(enableFlashSales: value))
              : null,
          leading: Icon(
            Icons.flash_on_rounded,
            color: settings.enableFlashSales && settings.enablePushNotifications 
                ? AppColors.warning 
                : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
        _buildSwitchTile(
          isDarkMode: isDarkMode,
          title: 'New Products',
          subtitle: 'Notifications about new product launches',
          value: settings.enableNewProducts,
          onChanged: settings.enablePushNotifications 
              ? (value) => _updateSettings(provider, settings.copyWith(enableNewProducts: value))
              : null,
          leading: Icon(
            Icons.new_releases_rounded,
            color: settings.enableNewProducts && settings.enablePushNotifications 
                ? AppColors.info 
                : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
        _buildSwitchTile(
          isDarkMode: isDarkMode,
          title: 'Reviews & Ratings',
          subtitle: 'Reminders to review purchased products',
          value: settings.enableReviews,
          onChanged: settings.enablePushNotifications 
              ? (value) => _updateSettings(provider, settings.copyWith(enableReviews: value))
              : null,
          leading: Icon(
            Icons.star_rounded,
            color: settings.enableReviews && settings.enablePushNotifications 
                ? Colors.amber 
                : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundAndVibrationSection(bool isDarkMode, NotificationSettings settings, NotificationProvider provider) {
    return _buildSection(
      isDarkMode: isDarkMode,
      title: 'Sound & Vibration',
      icon: Icons.volume_up_rounded,
      children: [
        _buildSwitchTile(
          isDarkMode: isDarkMode,
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          value: settings.enableSound,
          onChanged: settings.enablePushNotifications 
              ? (value) => _updateSettings(provider, settings.copyWith(enableSound: value))
              : null,
          leading: Icon(
            settings.enableSound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: settings.enableSound && settings.enablePushNotifications 
                ? AppColors.primary 
                : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
        _buildSwitchTile(
          isDarkMode: isDarkMode,
          title: 'Vibration',
          subtitle: 'Vibrate device for notifications',
          value: settings.enableVibration,
          onChanged: settings.enablePushNotifications 
              ? (value) => _updateSettings(provider, settings.copyWith(enableVibration: value))
              : null,
          leading: Icon(
            Icons.vibration_rounded,
            color: settings.enableVibration && settings.enablePushNotifications 
                ? AppColors.primary 
                : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildQuietHoursSection(bool isDarkMode, NotificationSettings settings, NotificationProvider provider) {
    return _buildSection(
      isDarkMode: isDarkMode,
      title: 'Quiet Hours',
      icon: Icons.bedtime_rounded,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
          child: Text(
            'During quiet hours, you\'ll still receive notifications but without sound or vibration.',
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              color: AppColors.getTextSecondaryColor(isDarkMode),
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
        _buildTimeTile(
          isDarkMode: isDarkMode,
          title: 'Start Time',
          time: _quietHoursStart ?? TimeOfDay(hour: 22, minute: 0),
          onTap: settings.enablePushNotifications ? () => _selectQuietHoursStart(provider, settings) : null,
          enabled: settings.enablePushNotifications,
        ),
        _buildTimeTile(
          isDarkMode: isDarkMode,
          title: 'End Time',
          time: _quietHoursEnd ?? TimeOfDay(hour: 8, minute: 0),
          onTap: settings.enablePushNotifications ? () => _selectQuietHoursEnd(provider, settings) : null,
          enabled: settings.enablePushNotifications,
        ),
      ],
    );
  }

  Widget _buildSection({
    required bool isDarkMode,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
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
                  // Header
                  Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.primary,
                            size: ResponsiveUtils.getIconSize(context),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Children
                  ...children,
                  
                  SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.5),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required bool isDarkMode,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
    Widget? leading,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getBodyFontSize(context),
          fontWeight: FontWeight.w600,
          color: onChanged == null 
              ? AppColors.getTextSecondaryColor(isDarkMode)
              : AppColors.getTextColor(isDarkMode),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: ResponsiveUtils.getCaptionFontSize(context),
          color: AppColors.getTextSecondaryColor(isDarkMode),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.3,
      ),
    );
  }

  Widget _buildTimeTile({
    required bool isDarkMode,
    required String title,
    required TimeOfDay time,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return ListTile(
      leading: Icon(
        Icons.access_time_rounded,
        color: enabled ? AppColors.primary : AppColors.getTextSecondaryColor(isDarkMode),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getBodyFontSize(context),
          fontWeight: FontWeight.w600,
          color: enabled 
              ? AppColors.getTextColor(isDarkMode)
              : AppColors.getTextSecondaryColor(isDarkMode),
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalSpacing(context),
          vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.5,
        ),
        decoration: BoxDecoration(
          color: enabled 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
          border: Border.all(
            color: enabled 
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.3),
          ),
        ),
        child: Text(
          time.format(context),
          style: TextStyle(
            fontSize: ResponsiveUtils.getBodyFontSize(context),
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.primary : AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.3,
      ),
    );
  }

  void _updateSettings(NotificationProvider provider, NotificationSettings newSettings) {
    provider.updateNotificationSettings(newSettings);
  }

  Future<void> _selectQuietHoursStart(NotificationProvider provider, NotificationSettings settings) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _quietHoursStart ?? TimeOfDay(hour: 22, minute: 0),
      helpText: 'Select quiet hours start time',
    );

    if (time != null) {
      setState(() {
        _quietHoursStart = time;
      });
      
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateSettings(provider, settings.copyWith(quietHoursStart: timeString));
    }
  }

  Future<void> _selectQuietHoursEnd(NotificationProvider provider, NotificationSettings settings) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _quietHoursEnd ?? TimeOfDay(hour: 8, minute: 0),
      helpText: 'Select quiet hours end time',
    );

    if (time != null) {
      setState(() {
        _quietHoursEnd = time;
      });
      
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateSettings(provider, settings.copyWith(quietHoursEnd: timeString));
    }
  }

  void _handleMenuAction(String action) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    
    switch (action) {
      case 'reset':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text('Are you sure you want to reset all notification settings to default values?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.resetNotificationSettings('user_123');
                  
                  // Reset local time values
                  setState(() {
                    _quietHoursStart = TimeOfDay(hour: 22, minute: 0);
                    _quietHoursEnd = TimeOfDay(hour: 8, minute: 0);
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Settings reset to default'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Reset', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        break;
      case 'test':
        provider.createNotification(
          title: 'Test Notification',
          body: 'This is a test notification to verify your settings are working correctly.',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdBy: 'system',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Test notification sent!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }
}