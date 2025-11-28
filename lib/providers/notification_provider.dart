import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/push_notification.dart';
import 'dart:convert';
import 'dart:math';

class NotificationProvider with ChangeNotifier {
  List<PushNotification> _notifications = [];
  List<PushNotification> _userNotifications = [];
  NotificationSettings? _userSettings;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<PushNotification> get notifications => _notifications;
  List<PushNotification> get userNotifications => _userNotifications;
  NotificationSettings? get userSettings => _userSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Filtered getters
  List<PushNotification> get scheduledNotifications => 
      _notifications.where((n) => n.isScheduled).toList();
  
  List<PushNotification> get sentNotifications => 
      _notifications.where((n) => n.isSent && !n.isScheduled).toList();
  
  List<PushNotification> get failedNotifications => 
      _notifications.where((n) => n.isFailed).toList();

  List<PushNotification> getNotificationsByType(NotificationType type) =>
      _userNotifications.where((n) => n.type == type).toList();

  List<PushNotification> getUnreadNotifications() =>
      _userNotifications.where((n) => !n.isRead).toList();

  NotificationProvider() {
    _loadSampleData();
    _loadUserNotifications();
    _loadUserSettings();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Admin functions
  Future<void> createNotification({
    required String title,
    required String body,
    String? imageUrl,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    DateTime? scheduledAt,
    Map<String, dynamic> data = const {},
    List<String> targetUserIds = const [],
    bool isGlobal = true,
    String? actionUrl,
    String? categoryId,
    String? productId,
    String? orderId,
    int? badgeCount,
    String? sound,
    required String createdBy,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final notification = PushNotification(
        id: _generateId(),
        title: title,
        body: body,
        imageUrl: imageUrl,
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        scheduledAt: scheduledAt,
        data: data,
        targetUserIds: targetUserIds,
        isGlobal: isGlobal,
        actionUrl: actionUrl,
        categoryId: categoryId,
        productId: productId,
        orderId: orderId,
        badgeCount: badgeCount,
        sound: sound,
        createdBy: createdBy,
      );

      _notifications.insert(0, notification);
      await _saveNotifications();

      // If not scheduled, send immediately
      if (scheduledAt == null || scheduledAt.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
        await _sendNotification(notification);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to create notification: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateNotification(PushNotification notification) async {
    try {
      _setLoading(true);
      _setError(null);

      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification;
        await _saveNotifications();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update notification: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      _setLoading(true);
      _setError(null);

      _notifications.removeWhere((n) => n.id == notificationId);
      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete notification: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendNotification(String notificationId) async {
    try {
      _setLoading(true);
      _setError(null);

      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      await _sendNotification(notification);
    } catch (e) {
      _setError('Failed to send notification: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _sendNotification(PushNotification notification) async {
    // Simulate sending notification
    await Future.delayed(const Duration(milliseconds: 500));

    final updatedNotification = notification.copyWith(
      status: NotificationStatus.sent,
      sentAt: DateTime.now(),
    );

    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      _notifications[index] = updatedNotification;
    }

    // Add to user notifications if user should receive it
    if (await _shouldUserReceiveNotification(notification)) {
      _userNotifications.insert(0, updatedNotification);
      _updateUnreadCount();
      await _saveUserNotifications();
    }

    await _saveNotifications();
    notifyListeners();
  }

  Future<bool> _shouldUserReceiveNotification(PushNotification notification) async {
    final settings = _userSettings;
    if (settings == null) return true;

    return settings.shouldReceiveNotification(notification.type) &&
           !settings.isInQuietHours();
  }

  // User functions
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final index = _userNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_userNotifications[index].isRead) {
        _userNotifications[index] = _userNotifications[index].copyWith(
          status: NotificationStatus.read,
          readAt: DateTime.now(),
        );
        _updateUnreadCount();
        await _saveUserNotifications();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      _setLoading(true);
      _setError(null);

      for (int i = 0; i < _userNotifications.length; i++) {
        if (!_userNotifications[i].isRead) {
          _userNotifications[i] = _userNotifications[i].copyWith(
            status: NotificationStatus.read,
            readAt: DateTime.now(),
          );
        }
      }

      _updateUnreadCount();
      await _saveUserNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to mark all notifications as read: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUserNotification(String notificationId) async {
    try {
      _userNotifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      await _saveUserNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete notification: $e');
    }
  }

  Future<void> clearAllUserNotifications() async {
    try {
      _setLoading(true);
      _setError(null);

      _userNotifications.clear();
      _unreadCount = 0;
      await _saveUserNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Settings functions
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      _setLoading(true);
      _setError(null);

      _userSettings = settings.copyWith(lastUpdated: DateTime.now());
      await _saveUserSettings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetNotificationSettings(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      _userSettings = NotificationSettings(
        userId: userId,
        lastUpdated: DateTime.now(),
      );
      await _saveUserSettings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Quick notification methods for common use cases
  Future<void> sendOrderUpdateNotification({
    required String orderId,
    required String title,
    required String body,
    required String userId,
  }) async {
    await createNotification(
      title: title,
      body: body,
      type: NotificationType.orderUpdate,
      priority: NotificationPriority.high,
      isGlobal: false,
      targetUserIds: [userId],
      orderId: orderId,
      createdBy: 'system',
      sound: 'order_update.wav',
    );
  }

  Future<void> sendFlashSaleNotification({
    required String title,
    required String body,
    String? imageUrl,
    String? productId,
  }) async {
    await createNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: NotificationType.flashSale,
      priority: NotificationPriority.high,
      productId: productId,
      createdBy: 'system',
      sound: 'flash_sale.wav',
    );
  }

  Future<void> sendNewProductNotification({
    required String title,
    required String body,
    String? imageUrl,
    required String productId,
    String? categoryId,
  }) async {
    await createNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: NotificationType.newProduct,
      priority: NotificationPriority.normal,
      productId: productId,
      categoryId: categoryId,
      createdBy: 'system',
    );
  }

  Future<void> sendPromotionalNotification({
    required String title,
    required String body,
    String? imageUrl,
    String? actionUrl,
  }) async {
    await createNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: NotificationType.promotional,
      priority: NotificationPriority.normal,
      actionUrl: actionUrl,
      createdBy: 'marketing',
    );
  }

  // Helper methods
  void _updateUnreadCount() {
    _unreadCount = _userNotifications.where((n) => !n.isRead).length;
  }

  String _generateId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Data persistence
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications.map((n) => n.toJson()).toList();
      await prefs.setString('admin_notifications', jsonEncode(notificationsJson));
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('admin_notifications');
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        _notifications = decoded.map((json) => PushNotification.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _saveUserNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _userNotifications.map((n) => n.toJson()).toList();
      await prefs.setString('user_notifications', jsonEncode(notificationsJson));
    } catch (e) {
      debugPrint('Error saving user notifications: $e');
    }
  }

  Future<void> _loadUserNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('user_notifications');
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        _userNotifications = decoded.map((json) => PushNotification.fromJson(json)).toList();
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('Error loading user notifications: $e');
    }
  }

  Future<void> _saveUserSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_userSettings != null) {
        await prefs.setString('notification_settings', jsonEncode(_userSettings!.toJson()));
      }
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  Future<void> _loadUserSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('notification_settings');
      
      if (settingsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(settingsJson);
        _userSettings = NotificationSettings.fromJson(decoded);
      } else {
        // Create default settings
        _userSettings = NotificationSettings(
          userId: 'user_123',
          lastUpdated: DateTime.now(),
        );
        await _saveUserSettings();
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> _loadSampleData() async {
    await _loadNotifications();
    
    if (_notifications.isEmpty) {
      // Add sample admin notifications
      _notifications = [
        PushNotification(
          id: 'notif_1',
          title: 'Flash Sale Alert!',
          body: '50% off on all electronics. Limited time offer!',
          imageUrl: 'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=400',
          type: NotificationType.flashSale,
          priority: NotificationPriority.high,
          status: NotificationStatus.sent,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
          isGlobal: true,
          createdBy: 'marketing',
          sound: 'flash_sale.wav',
        ),
        PushNotification(
          id: 'notif_2',
          title: 'New Product Launch',
          body: 'Check out our latest smartphone collection with amazing features!',
          imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
          type: NotificationType.newProduct,
          priority: NotificationPriority.normal,
          status: NotificationStatus.sent,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
          isGlobal: true,
          createdBy: 'product_team',
          productId: 'prod_123',
        ),
        PushNotification(
          id: 'notif_3',
          title: 'Weekend Special',
          body: 'Get ready for amazing weekend deals starting tomorrow!',
          type: NotificationType.promotional,
          priority: NotificationPriority.normal,
          status: NotificationStatus.sent,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          isGlobal: true,
          createdBy: 'marketing',
        ),
      ];
      await _saveNotifications();
    }
  }

  // Analytics and reporting
  Map<String, int> getNotificationStatsByType() {
    final stats = <String, int>{};
    for (final type in NotificationType.values) {
      stats[type.name] = _notifications.where((n) => n.type == type).length;
    }
    return stats;
  }

  Map<String, int> getNotificationStatsByStatus() {
    final stats = <String, int>{};
    for (final status in NotificationStatus.values) {
      stats[status.name] = _notifications.where((n) => n.status == status).length;
    }
    return stats;
  }

  double getDeliveryRate() {
    if (_notifications.isEmpty) return 0.0;
    final delivered = _notifications.where((n) => n.isDelivered || n.isRead).length;
    return delivered / _notifications.length;
  }

  double getReadRate() {
    if (_userNotifications.isEmpty) return 0.0;
    final read = _userNotifications.where((n) => n.isRead).length;
    return read / _userNotifications.length;
  }
}