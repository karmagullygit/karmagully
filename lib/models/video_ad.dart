class VideoAd {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String? targetUrl;
  final int duration; // in seconds
  final bool isActive;
  final DateTime createdAt;
  final int priority;

  VideoAd({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.targetUrl,
    required this.duration,
    this.isActive = true,
    required this.createdAt,
    this.priority = 0,
  });

  VideoAd copyWith({
    String? id,
    String? title,
    String? videoUrl,
    String? thumbnailUrl,
    String? targetUrl,
    int? duration,
    bool? isActive,
    DateTime? createdAt,
    int? priority,
  }) {
    return VideoAd(
      id: id ?? this.id,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      targetUrl: targetUrl ?? this.targetUrl,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'targetUrl': targetUrl,
      'duration': duration,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority,
    };
  }

  factory VideoAd.fromJson(Map<String, dynamic> json) {
    return VideoAd(
      id: json['id'] as String,
      title: json['title'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      targetUrl: json['targetUrl'] as String?,
      duration: json['duration'] as int,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      priority: json['priority'] as int? ?? 0,
    );
  }
}
