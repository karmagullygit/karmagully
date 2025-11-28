class FlashSale {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final int discountPercentage;
  final double? maxDiscountAmount;
  final List<String> productIds;
  final List<String> categoryIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? maxItems; // Maximum items that can be sold at discount
  final int soldItems; // Items sold so far
  final String? bannerColor; // Custom banner color
  final String type; // 'percentage', 'fixed_amount', 'buy_one_get_one'

  FlashSale({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.discountPercentage,
    this.maxDiscountAmount,
    required this.productIds,
    required this.categoryIds,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.maxItems,
    this.soldItems = 0,
    this.bannerColor,
    this.type = 'percentage',
  });

  // Check if sale is expired (dynamic)
  bool get isExpired => DateTime.now().isAfter(endTime);

  // Get time remaining
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isBefore(startTime)) {
      return startTime.difference(now);
    } else if (now.isAfter(endTime)) {
      return Duration.zero;
    } else {
      return endTime.difference(now);
    }
  }

  // Check if sale is currently live
  bool get isLive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime) && isActive;
  }

  // Check if sale is upcoming
  bool get isUpcoming {
    return DateTime.now().isBefore(startTime) && isActive;
  }

  // Check if sale has items available
  bool get hasItemsAvailable {
    if (maxItems == null) return true;
    return soldItems < maxItems!;
  }

  // Get percentage sold
  double get percentageSold {
    if (maxItems == null) return 0.0;
    return (soldItems / maxItems!) * 100;
  }

  // Get remaining items
  int get remainingItems {
    if (maxItems == null) return -1; // Unlimited
    return maxItems! - soldItems;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'discountPercentage': discountPercentage,
      'maxDiscountAmount': maxDiscountAmount,
      'productIds': productIds,
      'categoryIds': categoryIds,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'maxItems': maxItems,
      'soldItems': soldItems,
      'bannerColor': bannerColor,
      'type': type,
    };
  }

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    return FlashSale(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      discountPercentage: json['discountPercentage'],
      maxDiscountAmount: json['maxDiscountAmount']?.toDouble(),
      productIds: List<String>.from(json['productIds']),
      categoryIds: List<String>.from(json['categoryIds']),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      maxItems: json['maxItems'],
      soldItems: json['soldItems'] ?? 0,
      bannerColor: json['bannerColor'],
      type: json['type'] ?? 'percentage',
    );
  }

  FlashSale copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startTime,
    DateTime? endTime,
    int? discountPercentage,
    double? maxDiscountAmount,
    List<String>? productIds,
    List<String>? categoryIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? maxItems,
    int? soldItems,
    String? bannerColor,
    String? type,
  }) {
    return FlashSale(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      productIds: productIds ?? this.productIds,
      categoryIds: categoryIds ?? this.categoryIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maxItems: maxItems ?? this.maxItems,
      soldItems: soldItems ?? this.soldItems,
      bannerColor: bannerColor ?? this.bannerColor,
      type: type ?? this.type,
    );
  }
}