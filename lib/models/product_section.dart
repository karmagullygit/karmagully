class ProductSection {
  final String id;
  final String name;
  final String description;
  final int order;
  final bool isActive;
  final DateTime createdAt;

  ProductSection({
    required this.id,
    required this.name,
    this.description = '',
    this.order = 0,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProductSection.fromJson(Map<String, dynamic> json) {
    return ProductSection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProductSection copyWith({
    String? id,
    String? name,
    String? description,
    int? order,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductSection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
