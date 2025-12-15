enum PostType {
  text,
  image,
  video,
  mixed,
}

enum PostPrivacy { public, friends, private }

class SocialPost {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String? userDisplayName;
  final String content;
  final PostType type;
  final List<String> mediaUrls;
  final List<String> tags;
  final String? location;
  final PostPrivacy privacy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final List<String> likedBy;
  final List<String> dislikedBy;
  final bool isEdited;
  final bool isPinned;
  final bool isPromoted;
  final bool isVerified;
  final Map<String, dynamic> metadata;

  SocialPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    this.userDisplayName,
    required this.content,
    required this.type,
    this.mediaUrls = const [],
    this.tags = const [],
    this.location,
    this.privacy = PostPrivacy.public,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.likedBy = const [],
    this.dislikedBy = const [],
    this.isEdited = false,
    this.isPinned = false,
    this.isPromoted = false,
    this.isVerified = false,
    this.metadata = const {},
  });

  // Helper getters
  bool get hasMedia => mediaUrls.isNotEmpty;
  bool get hasImages => type == PostType.image || type == PostType.mixed;
  bool get hasVideo => type == PostType.video || type == PostType.mixed;
  bool get hasLocation => location != null && location!.isNotEmpty;
  bool get hasTags => tags.isNotEmpty;
  
  int get totalEngagement => likesCount + dislikesCount + commentsCount + sharesCount;
  double get engagementRate => viewsCount > 0 ? (totalEngagement / viewsCount) * 100 : 0;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  // Check if user has liked/disliked the post
  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isDislikedBy(String userId) => dislikedBy.contains(userId);
  bool isOwnedBy(String userId) => this.userId == userId;

  // Create copy with updated values
  SocialPost copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? userDisplayName,
    String? content,
    PostType? type,
    List<String>? mediaUrls,
    List<String>? tags,
    String? location,
    PostPrivacy? privacy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? dislikesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    List<String>? likedBy,
    List<String>? dislikedBy,
    bool? isEdited,
    bool? isPinned,
    bool? isPromoted,
    bool? isVerified,
    Map<String, dynamic>? metadata,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      privacy: privacy ?? this.privacy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      likedBy: likedBy ?? this.likedBy,
      dislikedBy: dislikedBy ?? this.dislikedBy,
      isEdited: isEdited ?? this.isEdited,
      isPinned: isPinned ?? this.isPinned,
      isPromoted: isPromoted ?? this.isPromoted,
      isVerified: isVerified ?? this.isVerified,
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'userDisplayName': userDisplayName,
      'content': content,
      'type': type.toString().split('.').last,
      'mediaUrls': mediaUrls,
      'tags': tags,
      'location': location,
      'privacy': privacy.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'isEdited': isEdited,
      'isPinned': isPinned,
      'isPromoted': isPromoted,
      'isVerified': isVerified,
      'metadata': metadata,
    };
  }

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      userDisplayName: json['userDisplayName'],
      content: json['content'] ?? '',
      type: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PostType.text,
      ),
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'],
      privacy: PostPrivacy.values.firstWhere(
        (e) => e.toString().split('.').last == json['privacy'],
        orElse: () => PostPrivacy.public,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      dislikedBy: List<String>.from(json['dislikedBy'] ?? []),
      isEdited: json['isEdited'] ?? false,
      isPinned: json['isPinned'] ?? false,
      isPromoted: json['isPromoted'] ?? false,
      isVerified: json['isVerified'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'SocialPost(id: $id, username: $username, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}