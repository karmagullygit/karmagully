class SocialMediaLink {
  final String id;
  final String name;
  final String url;
  final String iconName; // e.g., 'facebook', 'instagram', 'twitter', etc.
  final int order;
  final bool isActive;

  SocialMediaLink({
    required this.id,
    required this.name,
    required this.url,
    required this.iconName,
    this.order = 0,
    this.isActive = true,
  });

  SocialMediaLink copyWith({
    String? id,
    String? name,
    String? url,
    String? iconName,
    int? order,
    bool? isActive,
  }) {
    return SocialMediaLink(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      iconName: iconName ?? this.iconName,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'iconName': iconName,
      'order': order,
      'isActive': isActive,
    };
  }

  factory SocialMediaLink.fromJson(Map<String, dynamic> json) {
    return SocialMediaLink(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      iconName: json['iconName'] as String,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
