enum NotificationType {
  promotional,
  orderUpdate,
  system,
  flashSale,
  newProduct,
  review,
  general,
}

enum NotificationStatus {
  sent,
  delivered,
  read,
  failed,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class PushNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime? readAt;
  final Map<String, dynamic> data;
  final List<String> targetUserIds;
  final bool isGlobal;
  final String? actionUrl;
  final String? categoryId;
  final String? productId;
  final String? orderId;
  final int? badgeCount;
  final String? sound;
  final String createdBy;

  const PushNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.status = NotificationStatus.sent,
    required this.createdAt,
    this.scheduledAt,
    this.sentAt,
    this.readAt,
    this.data = const {},
    this.targetUserIds = const [],
    this.isGlobal = true,
    this.actionUrl,
    this.categoryId,
    this.productId,
    this.orderId,
    this.badgeCount,
    this.sound,
    required this.createdBy,
  });

  PushNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
    List<String>? targetUserIds,
    bool? isGlobal,
    String? actionUrl,
    String? categoryId,
    String? productId,
    String? orderId,
    int? badgeCount,
    String? sound,
    String? createdBy,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      targetUserIds: targetUserIds ?? this.targetUserIds,
      isGlobal: isGlobal ?? this.isGlobal,
      actionUrl: actionUrl ?? this.actionUrl,
      categoryId: categoryId ?? this.categoryId,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      badgeCount: badgeCount ?? this.badgeCount,
      sound: sound ?? this.sound,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'data': data,
      'targetUserIds': targetUserIds,
      'isGlobal': isGlobal,
      'actionUrl': actionUrl,
      'categoryId': categoryId,
      'productId': productId,
      'orderId': orderId,
      'badgeCount': badgeCount,
      'sound': sound,
      'createdBy': createdBy,
    };
  }

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.sent,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      targetUserIds: List<String>.from(json['targetUserIds'] ?? []),
      isGlobal: json['isGlobal'] ?? true,
      actionUrl: json['actionUrl'],
      categoryId: json['categoryId'],
      productId: json['productId'],
      orderId: json['orderId'],
      badgeCount: json['badgeCount'],
      sound: json['sound'],
      createdBy: json['createdBy'] ?? '',
    );
  }

  bool get isScheduled => scheduledAt != null && scheduledAt!.isAfter(DateTime.now());
  bool get isSent => sentAt != null;
  bool get isRead => readAt != null;
  bool get isDelivered => status == NotificationStatus.delivered;
  bool get isFailed => status == NotificationStatus.failed;

  String get typeDisplayName {
    switch (type) {
      case NotificationType.promotional:
        return 'Promotional';
      case NotificationType.orderUpdate:
        return 'Order Update';
      case NotificationType.system:
        return 'System';
      case NotificationType.flashSale:
        return 'Flash Sale';
      case NotificationType.newProduct:
        return 'New Product';
      case NotificationType.review:
        return 'Review';
      case NotificationType.general:
        return 'General';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PushNotification &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        type.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'PushNotification(id: $id, title: $title, type: $type, status: $status)';
  }
}

class NotificationSettings {
  final String userId;
  final bool enablePushNotifications;
  final bool enablePromotional;
  final bool enableOrderUpdates;
  final bool enableFlashSales;
  final bool enableNewProducts;
  final bool enableReviews;
  final bool enableSound;
  final bool enableVibration;
  final String quietHoursStart;
  final String quietHoursEnd;
  final List<String> mutedCategories;
  final DateTime lastUpdated;

  const NotificationSettings({
    required this.userId,
    this.enablePushNotifications = true,
    this.enablePromotional = true,
    this.enableOrderUpdates = true,
    this.enableFlashSales = true,
    this.enableNewProducts = true,
    this.enableReviews = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.mutedCategories = const [],
    required this.lastUpdated,
  });

  NotificationSettings copyWith({
    String? userId,
    bool? enablePushNotifications,
    bool? enablePromotional,
    bool? enableOrderUpdates,
    bool? enableFlashSales,
    bool? enableNewProducts,
    bool? enableReviews,
    bool? enableSound,
    bool? enableVibration,
    String? quietHoursStart,
    String? quietHoursEnd,
    List<String>? mutedCategories,
    DateTime? lastUpdated,
  }) {
    return NotificationSettings(
      userId: userId ?? this.userId,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enablePromotional: enablePromotional ?? this.enablePromotional,
      enableOrderUpdates: enableOrderUpdates ?? this.enableOrderUpdates,
      enableFlashSales: enableFlashSales ?? this.enableFlashSales,
      enableNewProducts: enableNewProducts ?? this.enableNewProducts,
      enableReviews: enableReviews ?? this.enableReviews,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      mutedCategories: mutedCategories ?? this.mutedCategories,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'enablePushNotifications': enablePushNotifications,
      'enablePromotional': enablePromotional,
      'enableOrderUpdates': enableOrderUpdates,
      'enableFlashSales': enableFlashSales,
      'enableNewProducts': enableNewProducts,
      'enableReviews': enableReviews,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'mutedCategories': mutedCategories,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      userId: json['userId'] ?? '',
      enablePushNotifications: json['enablePushNotifications'] ?? true,
      enablePromotional: json['enablePromotional'] ?? true,
      enableOrderUpdates: json['enableOrderUpdates'] ?? true,
      enableFlashSales: json['enableFlashSales'] ?? true,
      enableNewProducts: json['enableNewProducts'] ?? true,
      enableReviews: json['enableReviews'] ?? true,
      enableSound: json['enableSound'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '08:00',
      mutedCategories: List<String>.from(json['mutedCategories'] ?? []),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  bool shouldReceiveNotification(NotificationType type) {
    if (!enablePushNotifications) return false;

    switch (type) {
      case NotificationType.promotional:
        return enablePromotional;
      case NotificationType.orderUpdate:
        return enableOrderUpdates;
      case NotificationType.flashSale:
        return enableFlashSales;
      case NotificationType.newProduct:
        return enableNewProducts;
      case NotificationType.review:
        return enableReviews;
      case NotificationType.system:
      case NotificationType.general:
        return true;
    }
  }

  bool isInQuietHours() {
    final now = DateTime.now();
    final startTime = _parseTime(quietHoursStart);
    final endTime = _parseTime(quietHoursEnd);
    final currentTime = now.hour * 60 + now.minute;

    if (startTime < endTime) {
      return currentTime >= startTime && currentTime <= endTime;
    } else {
      // Overnight quiet hours
      return currentTime >= startTime || currentTime <= endTime;
    }
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}