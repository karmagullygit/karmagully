class PromotionalBanner {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? backgroundColor;
  final String? textColor;
  final String? buttonColor;
  final String buttonText;
  final String? buttonLink;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> targetPages; // ['search', 'category', 'home', 'all']
  final List<String> targetCategories; // empty means all categories
  final int priority; // higher priority shows first

  PromotionalBanner({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.imageUrl,
    this.backgroundColor,
    this.textColor,
    this.buttonColor,
    this.buttonText = 'Shop Now',
    this.buttonLink,
    this.isActive = true,
    required this.startDate,
    required this.endDate,
    this.targetPages = const ['all'],
    this.targetCategories = const [],
    this.priority = 0,
  });

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(startDate) && 
           now.isBefore(endDate);
  }

  bool shouldShowOnPage(String page, {String? category}) {
    if (!isCurrentlyActive) return false;
    
    // Check if banner targets this page
    if (!targetPages.contains('all') && !targetPages.contains(page)) {
      return false;
    }
    
    // If specific categories are targeted, check if current category matches
    if (targetCategories.isNotEmpty && category != null) {
      return targetCategories.contains(category);
    }
    
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'buttonColor': buttonColor,
      'buttonText': buttonText,
      'buttonLink': buttonLink,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'targetPages': targetPages,
      'targetCategories': targetCategories,
      'priority': priority,
    };
  }

  factory PromotionalBanner.fromJson(Map<String, dynamic> json) {
    return PromotionalBanner(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
      buttonColor: json['buttonColor'] as String?,
      buttonText: json['buttonText'] as String? ?? 'Shop Now',
      buttonLink: json['buttonLink'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      targetPages: List<String>.from(json['targetPages'] ?? ['all']),
      targetCategories: List<String>.from(json['targetCategories'] ?? []),
      priority: json['priority'] as int? ?? 0,
    );
  }

  PromotionalBanner copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? backgroundColor,
    String? textColor,
    String? buttonColor,
    String? buttonText,
    String? buttonLink,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? targetPages,
    List<String>? targetCategories,
    int? priority,
  }) {
    return PromotionalBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonText: buttonText ?? this.buttonText,
      buttonLink: buttonLink ?? this.buttonLink,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetPages: targetPages ?? this.targetPages,
      targetCategories: targetCategories ?? this.targetCategories,
      priority: priority ?? this.priority,
    );
  }
}
