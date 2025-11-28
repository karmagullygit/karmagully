class CarouselBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? actionUrl;
  final String? productId;
  final bool isActive;
  final int order; // For sorting banners
  final DateTime startDate;
  final DateTime? endDate;
  final String backgroundColor;
  final String textColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  CarouselBanner({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.imageUrl,
    this.actionUrl,
    this.productId,
    this.isActive = true,
    this.order = 0,
    required this.startDate,
    this.endDate,
    this.backgroundColor = '#1976D2', // Default blue
    this.textColor = '#FFFFFF', // Default white
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCurrentlyActive {
    final now = DateTime.now();
    if (!isActive) return false;
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  factory CarouselBanner.fromJson(Map<String, dynamic> json) {
    return CarouselBanner(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      productId: json['productId'],
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      backgroundColor: json['backgroundColor'] ?? '#1976D2',
      textColor: json['textColor'] ?? '#FFFFFF',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'productId': productId,
      'isActive': isActive,
      'order': order,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CarouselBanner copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? actionUrl,
    String? productId,
    bool? isActive,
    int? order,
    DateTime? startDate,
    DateTime? endDate,
    String? backgroundColor,
    String? textColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarouselBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      productId: productId ?? this.productId,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CarouselBanner{id: $id, title: $title, order: $order, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarouselBanner && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}