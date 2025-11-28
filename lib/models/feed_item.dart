class FeedItem {
  final String id;
  final String type;
  final String title;
  final String description;
  final String imageUrl;
  final String actionText;
  final int priority;
  final DateTime timestamp;
  final String? severity; // for admin feed items
  final String? category;
  final String? value;
  final String? trend;
  final bool? actionRequired;
  final Map<String, dynamic> data;

  FeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionText,
    required this.priority,
    required this.timestamp,
    this.severity,
    this.category,
    this.value,
    this.trend,
    this.actionRequired,
    required this.data,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id']?.toString() ?? 'feed_${DateTime.now().millisecondsSinceEpoch}',
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? 'Feed Item',
      description: json['description']?.toString() ?? 'No description',
      imageUrl: json['imageUrl']?.toString() ?? 'https://via.placeholder.com/300x200',
      actionText: json['actionText']?.toString() ?? 'View',
      priority: (json['priority'] as num?)?.toInt() ?? 5,
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      severity: json['severity']?.toString(),
      category: json['category']?.toString(),
      value: json['value']?.toString(),
      trend: json['trend']?.toString(),
      actionRequired: json['actionRequired'] as bool?,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'actionText': actionText,
      'priority': priority,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      'category': category,
      'value': value,
      'trend': trend,
      'actionRequired': actionRequired,
      'data': data,
    };
  }

  // Check if this is a user feed item
  bool get isUserFeedItem => [
    'product_recommendation',
    'trending_deal',
    'personalized_offer',
    'category_spotlight',
    'seasonal_content',
    'flash_sale',
    'new_arrival',
    'review_prompt',
    'wishlist_reminder',
    'restock_alert'
  ].contains(type);

  // Check if this is an admin feed item
  bool get isAdminFeedItem => [
    'sales_insight',
    'user_behavior_alert',
    'inventory_warning',
    'performance_metric',
    'trend_analysis',
    'security_alert',
    'system_status',
    'recommendation_success',
    'customer_feedback',
    'revenue_spike',
    'marketing_opportunity',
    'competitor_analysis',
    'seasonal_prediction',
    'ai_suggestion',
    'urgent_action'
  ].contains(type);

  // Get icon based on feed item type
  String get icon {
    switch (type) {
      case 'product_recommendation':
        return '🛍️';
      case 'trending_deal':
        return '🔥';
      case 'personalized_offer':
        return '💝';
      case 'category_spotlight':
        return '⭐';
      case 'seasonal_content':
        return '🎯';
      case 'flash_sale':
        return '⚡';
      case 'new_arrival':
        return '🆕';
      case 'review_prompt':
        return '⭐';
      case 'wishlist_reminder':
        return '❤️';
      case 'restock_alert':
        return '📦';
      case 'sales_insight':
        return '📈';
      case 'user_behavior_alert':
        return '👥';
      case 'inventory_warning':
        return '⚠️';
      case 'performance_metric':
        return '📊';
      case 'trend_analysis':
        return '📈';
      case 'security_alert':
        return '🔒';
      case 'system_status':
        return '⚙️';
      case 'recommendation_success':
        return '🎯';
      case 'customer_feedback':
        return '💬';
      case 'revenue_spike':
        return '💰';
      case 'marketing_opportunity':
        return '🎪';
      case 'competitor_analysis':
        return '🔍';
      case 'seasonal_prediction':
        return '🔮';
      case 'ai_suggestion':
        return '🤖';
      case 'urgent_action':
        return '🚨';
      default:
        return '📱';
    }
  }

  // Get color based on severity or priority
  int get colorValue {
    if (severity != null) {
      switch (severity) {
        case 'critical':
          return 0xFFE53E3E; // Red
        case 'high':
          return 0xFFED8936; // Orange
        case 'medium':
          return 0xFFECC94B; // Yellow
        case 'low':
          return 0xFF48BB78; // Green
        default:
          return 0xFF4299E1; // Blue
      }
    }
    
    // Use priority for user feed items
    if (priority >= 8) return 0xFFE53E3E; // Red - High priority
    if (priority >= 6) return 0xFFED8936; // Orange - Medium priority
    if (priority >= 4) return 0xFF4299E1; // Blue - Normal priority
    return 0xFF48BB78; // Green - Low priority
  }

  // Get display time
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Check if item requires immediate attention
  bool get needsAttention {
    if (actionRequired == true) return true;
    if (severity == 'critical' || severity == 'high') return true;
    if (priority >= 8) return true;
    return false;
  }

  // Get trend arrow
  String get trendArrow {
    switch (trend) {
      case 'up':
        return '↗️';
      case 'down':
        return '↘️';
      case 'stable':
        return '→';
      default:
        return '';
    }
  }

  // Create a copy with updated values
  FeedItem copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? imageUrl,
    String? actionText,
    int? priority,
    DateTime? timestamp,
    String? severity,
    String? category,
    String? value,
    String? trend,
    bool? actionRequired,
    Map<String, dynamic>? data,
  }) {
    return FeedItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      actionText: actionText ?? this.actionText,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      value: value ?? this.value,
      trend: trend ?? this.trend,
      actionRequired: actionRequired ?? this.actionRequired,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'FeedItem(id: $id, type: $type, title: $title, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}