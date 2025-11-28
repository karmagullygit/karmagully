class Story {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String mediaUrl;
  final String type; // 'image' or 'video'
  final String caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int likes;
  final int views;

  Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.mediaUrl,
    required this.type,
    required this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.likes = 0,
    this.views = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'mediaUrl': mediaUrl,
      'type': type,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'likes': likes,
      'views': views,
    };
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      mediaUrl: json['mediaUrl'],
      type: json['type'],
      caption: json['caption'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toReelsFormat() {
    return {
      'name': userName,
      'image': userAvatar,
      'type': type,
      'videoUrl': type == 'video' ? mediaUrl : null,
      'time': timeAgo,
      'likes': likes.toString(),
      'comments': '0',
      'shares': '0',
      'caption': caption,
    };
  }
}
