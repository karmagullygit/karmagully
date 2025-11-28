import 'product_variant.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // Keep for backward compatibility
  final List<String> imageUrls; // New field for multiple images
  final String category;
  final int stock;
  final DateTime createdAt;
  final bool isActive;
  final bool isFeatured; // New field for featured products
  final List<ProductVariant> variants; // New field for product variants
  final bool hasVariants; // Helper to know if product has variants
  final List<VariantAttribute> variantAttributes; // Available attributes for variants
  final List<String> sectionIds; // IDs of sections this product belongs to

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    String? imageUrl,
    List<String>? imageUrls,
    required this.category,
    required this.stock,
    required this.createdAt,
    this.isActive = true,
    this.isFeatured = false,
    this.variants = const [],
    List<VariantAttribute>? variantAttributes,
    this.sectionIds = const [],
  }) : imageUrl = imageUrl ?? (imageUrls?.isNotEmpty == true ? imageUrls!.first : ''),
       imageUrls = imageUrls ?? (imageUrl != null ? [imageUrl] : []),
       hasVariants = variants.isNotEmpty,
       variantAttributes = variantAttributes ?? [];

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls'])
          : null,
      category: json['category'],
      stock: json['stock'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      variants: json['variants'] != null
          ? (json['variants'] as List).map((v) => ProductVariant.fromJson(v)).toList()
          : [],
      variantAttributes: json['variantAttributes'] != null
          ? (json['variantAttributes'] as List).map((v) => VariantAttribute.fromJson(v)).toList()
          : [],
      sectionIds: json['sectionIds'] != null
          ? List<String>.from(json['sectionIds'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': category,
      'stock': stock,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'variants': variants.map((v) => v.toJson()).toList(),
      'variantAttributes': variantAttributes.map((v) => v.toJson()).toList(),
      'sectionIds': sectionIds,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? imageUrls,
    String? category,
    int? stock,
    DateTime? createdAt,
    bool? isActive,
    bool? isFeatured,
    List<ProductVariant>? variants,
    List<VariantAttribute>? variantAttributes,
    List<String>? sectionIds,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      variants: variants ?? this.variants,
      variantAttributes: variantAttributes ?? this.variantAttributes,
      sectionIds: sectionIds ?? this.sectionIds,
    );
  }

  // Helper methods for variants
  List<ProductVariant> get activeVariants => variants.where((v) => v.isActive).toList();
  ProductVariant? get defaultVariant => variants.isNotEmpty ? variants.first : null;
  double get minPrice => hasVariants ? variants.map((v) => v.price).reduce((a, b) => a < b ? a : b) : price;
  double get maxPrice => hasVariants ? variants.map((v) => v.price).reduce((a, b) => a > b ? a : b) : price;
  bool get isInStock => hasVariants ? variants.any((v) => v.isInStock) : stock > 0;
  int get totalStock => hasVariants ? variants.fold(0, (sum, v) => sum + v.stock) : stock;
}