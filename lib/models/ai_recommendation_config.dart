class AIRecommendationConfig {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final bool isEnabled;
  final int maxRecommendations;
  final DateTime lastUpdated;

  AIRecommendationConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isEnabled,
    required this.maxRecommendations,
    required this.lastUpdated,
  });

  factory AIRecommendationConfig.defaultConfig() {
    return AIRecommendationConfig(
      id: 'ai_recommendations',
      title: '🤖 AI RECOMMENDED',
      subtitle: 'Curated just for you',
      description: 'Based on your purchase history and preferences',
      isEnabled: true,
      maxRecommendations: 6,
      lastUpdated: DateTime.now(),
    );
  }

  factory AIRecommendationConfig.fromJson(Map<String, dynamic> json) {
    return AIRecommendationConfig(
      id: json['id'] ?? 'ai_recommendations',
      title: json['title'] ?? '🤖 AI RECOMMENDED',
      subtitle: json['subtitle'] ?? 'Curated just for you',
      description: json['description'] ?? 'Based on your purchase history and preferences',
      isEnabled: json['isEnabled'] ?? true,
      maxRecommendations: json['maxRecommendations'] ?? 6,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'isEnabled': isEnabled,
      'maxRecommendations': maxRecommendations,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  AIRecommendationConfig copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    bool? isEnabled,
    int? maxRecommendations,
    DateTime? lastUpdated,
  }) {
    return AIRecommendationConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      maxRecommendations: maxRecommendations ?? this.maxRecommendations,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}