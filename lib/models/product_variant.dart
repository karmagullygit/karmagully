class ProductVariant {
  final String id;
  final String productId;
  final String name; // e.g., "Red-Large", "Blue-Medium"
  final Map<String, String> attributes; // e.g., {"color": "Red", "size": "Large"}
  final double price;
  final double? compareAtPrice; // original price for discounts
  final int stock;
  final String? sku;
  final List<String> images;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.attributes,
    required this.price,
    this.compareAtPrice,
    required this.stock,
    this.sku,
    this.images = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
      price: (json['price'] ?? 0.0).toDouble(),
      compareAtPrice: json['compareAtPrice']?.toDouble(),
      stock: json['stock'] ?? 0,
      sku: json['sku'],
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'attributes': attributes,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'stock': stock,
      'sku': sku,
      'images': images,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductVariant copyWith({
    String? id,
    String? productId,
    String? name,
    Map<String, String>? attributes,
    double? price,
    double? compareAtPrice,
    int? stock,
    String? sku,
    List<String>? images,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      attributes: attributes ?? this.attributes,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isInStock => stock > 0;
  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;
  double get discountPercentage => hasDiscount ? ((compareAtPrice! - price) / compareAtPrice!) * 100 : 0;
  String get displayName => name.isNotEmpty ? name : attributes.values.join(' - ');
}

class VariantAttribute {
  final String name; // e.g., "Color", "Size"
  final List<String> values; // e.g., ["Red", "Blue", "Green"]
  final String displayType; // "color", "text", "image"

  VariantAttribute({
    required this.name,
    required this.values,
    this.displayType = 'text',
  });

  factory VariantAttribute.fromJson(Map<String, dynamic> json) {
    return VariantAttribute(
      name: json['name'] ?? '',
      values: List<String>.from(json['values'] ?? []),
      displayType: json['displayType'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values,
      'displayType': displayType,
    };
  }
}