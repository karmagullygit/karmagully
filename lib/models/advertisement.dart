enum AdType {
  banner,
  video,
  promotion,
  product,
}

enum AdPlacement {
  carousel,
  floatingVideo,
  banner,
  popup,
}

class Advertisement {
  final String id;
  final String title;
  final String description;
  final AdType type;
  final AdPlacement placement;
  final String imageUrl;
  final String? videoUrl;
  final String? actionUrl; // Deep link or product URL
  final String? productId; // For product promotions
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final int priority; // Higher number = higher priority
  final Map<String, dynamic> metadata; // Additional data
  final DateTime createdAt;
  final DateTime updatedAt;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.placement,
    required this.imageUrl,
    this.videoUrl,
    this.actionUrl,
    this.productId,
    this.isActive = true,
    required this.startDate,
    this.endDate,
    this.priority = 0,
    this.metadata = const {},
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

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AdType.values.firstWhere(
        (e) => e.toString() == 'AdType.${json['type']}',
        orElse: () => AdType.banner,
      ),
      placement: AdPlacement.values.firstWhere(
        (e) => e.toString() == 'AdPlacement.${json['placement']}',
        orElse: () => AdPlacement.banner,
      ),
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      actionUrl: json['actionUrl'],
      productId: json['productId'],
      isActive: json['isActive'] ?? true,
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      priority: json['priority'] ?? 0,
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'placement': placement.toString().split('.').last,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'actionUrl': actionUrl,
      'productId': productId,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'priority': priority,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Advertisement copyWith({
    String? id,
    String? title,
    String? description,
    AdType? type,
    AdPlacement? placement,
    String? imageUrl,
    String? videoUrl,
    String? actionUrl,
    String? productId,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    int? priority,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Advertisement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      placement: placement ?? this.placement,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      productId: productId ?? this.productId,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Advertisement{id: $id, title: $title, type: $type, placement: $placement, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Advertisement && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}