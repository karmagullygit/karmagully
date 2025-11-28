class Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final String type; // 'percentage', 'fixed_amount', 'free_shipping'
  final double value; // Percentage or fixed amount
  final double? minimumOrderAmount;
  final double? maximumDiscountAmount;
  final DateTime? expiryDate;
  final int? usageLimit; // null for unlimited
  final int usedCount;
  final bool isActive;
  final List<String> applicableProductIds; // Empty for all products
  final List<String> applicableCategoryIds; // Empty for all categories
  final List<String> excludedProductIds;
  final List<String> excludedCategoryIds;
  final bool isFirstTimeOnly; // Only for new customers
  final List<String> allowedUserIds; // Empty for all users
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bannerColor;
  final String? iconUrl;

  Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.minimumOrderAmount,
    this.maximumDiscountAmount,
    this.expiryDate,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
    this.applicableProductIds = const [],
    this.applicableCategoryIds = const [],
    this.excludedProductIds = const [],
    this.excludedCategoryIds = const [],
    this.isFirstTimeOnly = false,
    this.allowedUserIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.bannerColor,
    this.iconUrl,
  });

  // Check if coupon is valid
  bool get isValid {
    final now = DateTime.now();
    
    // Check if active
    if (!isActive) return false;
    
    // Check expiry
    if (expiryDate != null && now.isAfter(expiryDate!)) return false;
    
    // Check usage limit
    if (usageLimit != null && usedCount >= usageLimit!) return false;
    
    return true;
  }

  // Check if coupon is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Get remaining uses
  int get remainingUses {
    if (usageLimit == null) return -1; // Unlimited
    return usageLimit! - usedCount;
  }

  // Get usage percentage
  double get usagePercentage {
    if (usageLimit == null) return 0.0;
    return (usedCount / usageLimit!) * 100;
  }

  // Check if coupon applies to specific product
  bool appliesToProduct(String productId) {
    // Check if product is excluded
    if (excludedProductIds.contains(productId)) return false;
    
    // If no specific products, applies to all (unless excluded)
    if (applicableProductIds.isEmpty) return true;
    
    // Check if product is in applicable list
    return applicableProductIds.contains(productId);
  }

  // Check if coupon applies to specific category
  bool appliesToCategory(String categoryId) {
    // Check if category is excluded
    if (excludedCategoryIds.contains(categoryId)) return false;
    
    // If no specific categories, applies to all (unless excluded)
    if (applicableCategoryIds.isEmpty) return true;
    
    // Check if category is in applicable list
    return applicableCategoryIds.contains(categoryId);
  }

  // Calculate discount amount
  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0.0;
    
    // Check minimum order amount
    if (minimumOrderAmount != null && orderAmount < minimumOrderAmount!) {
      return 0.0;
    }
    
    double discount = 0.0;
    
    switch (type) {
      case 'percentage':
        discount = orderAmount * (value / 100);
        break;
      case 'fixed_amount':
        discount = value;
        break;
      case 'free_shipping':
        // This would be handled separately in shipping calculation
        discount = 0.0;
        break;
    }
    
    // Apply maximum discount limit
    if (maximumDiscountAmount != null && discount > maximumDiscountAmount!) {
      discount = maximumDiscountAmount!;
    }
    
    // Ensure discount doesn't exceed order amount
    if (discount > orderAmount) {
      discount = orderAmount;
    }
    
    return discount;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'type': type,
      'value': value,
      'minimumOrderAmount': minimumOrderAmount,
      'maximumDiscountAmount': maximumDiscountAmount,
      'expiryDate': expiryDate?.toIso8601String(),
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'isActive': isActive,
      'applicableProductIds': applicableProductIds,
      'applicableCategoryIds': applicableCategoryIds,
      'excludedProductIds': excludedProductIds,
      'excludedCategoryIds': excludedCategoryIds,
      'isFirstTimeOnly': isFirstTimeOnly,
      'allowedUserIds': allowedUserIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'bannerColor': bannerColor,
      'iconUrl': iconUrl,
    };
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      value: json['value'].toDouble(),
      minimumOrderAmount: json['minimumOrderAmount']?.toDouble(),
      maximumDiscountAmount: json['maximumDiscountAmount']?.toDouble(),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      usageLimit: json['usageLimit'],
      usedCount: json['usedCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      applicableProductIds: List<String>.from(json['applicableProductIds'] ?? []),
      applicableCategoryIds: List<String>.from(json['applicableCategoryIds'] ?? []),
      excludedProductIds: List<String>.from(json['excludedProductIds'] ?? []),
      excludedCategoryIds: List<String>.from(json['excludedCategoryIds'] ?? []),
      isFirstTimeOnly: json['isFirstTimeOnly'] ?? false,
      allowedUserIds: List<String>.from(json['allowedUserIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      bannerColor: json['bannerColor'],
      iconUrl: json['iconUrl'],
    );
  }

  Coupon copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? type,
    double? value,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    DateTime? expiryDate,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
    List<String>? applicableProductIds,
    List<String>? applicableCategoryIds,
    List<String>? excludedProductIds,
    List<String>? excludedCategoryIds,
    bool? isFirstTimeOnly,
    List<String>? allowedUserIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bannerColor,
    String? iconUrl,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumDiscountAmount: maximumDiscountAmount ?? this.maximumDiscountAmount,
      expiryDate: expiryDate ?? this.expiryDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableCategoryIds: applicableCategoryIds ?? this.applicableCategoryIds,
      excludedProductIds: excludedProductIds ?? this.excludedProductIds,
      excludedCategoryIds: excludedCategoryIds ?? this.excludedCategoryIds,
      isFirstTimeOnly: isFirstTimeOnly ?? this.isFirstTimeOnly,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bannerColor: bannerColor ?? this.bannerColor,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }
}