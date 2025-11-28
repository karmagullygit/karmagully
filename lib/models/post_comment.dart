class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String userAvatar;
  final String? userDisplayName;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int dislikesCount;
  final int repliesCount;
  final List<String> likedBy;
  final List<String> dislikedBy;
  final String? parentCommentId; // For replies
  final bool isEdited;
  final bool isPinned;
  final List<String> mentions; // @username mentions
  final Map<String, dynamic> metadata;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userAvatar,
    this.userDisplayName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.repliesCount = 0,
    this.likedBy = const [],
    this.dislikedBy = const [],
    this.parentCommentId,
    this.isEdited = false,
    this.isPinned = false,
    this.mentions = const [],
    this.metadata = const {},
  });

  // Helper getters
  bool get isReply => parentCommentId != null;
  bool get hasReplies => repliesCount > 0;
  bool get hasMentions => mentions.isNotEmpty;
  
  int get totalEngagement => likesCount + dislikesCount + repliesCount;
  
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

  // Check if user has liked/disliked the comment
  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isDislikedBy(String userId) => dislikedBy.contains(userId);
  bool isOwnedBy(String userId) => this.userId == userId;

  // Create copy with updated values
  PostComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? userAvatar,
    String? userDisplayName,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? dislikesCount,
    int? repliesCount,
    List<String>? likedBy,
    List<String>? dislikedBy,
    String? parentCommentId,
    bool? isEdited,
    bool? isPinned,
    List<String>? mentions,
    Map<String, dynamic>? metadata,
  }) {
    return PostComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      likedBy: likedBy ?? this.likedBy,
      dislikedBy: dislikedBy ?? this.dislikedBy,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isEdited: isEdited ?? this.isEdited,
      isPinned: isPinned ?? this.isPinned,
      mentions: mentions ?? this.mentions,
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'userDisplayName': userDisplayName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'repliesCount': repliesCount,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'parentCommentId': parentCommentId,
      'isEdited': isEdited,
      'isPinned': isPinned,
      'mentions': mentions,
      'metadata': metadata,
    };
  }

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      userDisplayName: json['userDisplayName'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      dislikedBy: List<String>.from(json['dislikedBy'] ?? []),
      parentCommentId: json['parentCommentId'],
      isEdited: json['isEdited'] ?? false,
      isPinned: json['isPinned'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'PostComment(id: $id, username: $username, content: ${content.length > 30 ? '${content.substring(0, 30)}...' : content})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostComment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Class to represent nested comments structure
class CommentThread {
  final PostComment comment;
  final List<PostComment> replies;

  CommentThread({
    required this.comment,
    this.replies = const [],
  });

  bool get hasReplies => replies.isNotEmpty;
  int get totalReplies => replies.length;

  CommentThread copyWith({
    PostComment? comment,
    List<PostComment>? replies,
  }) {
    return CommentThread(
      comment: comment ?? this.comment,
      replies: replies ?? this.replies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment.toJson(),
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }

  factory CommentThread.fromJson(Map<String, dynamic> json) {
    return CommentThread(
      comment: PostComment.fromJson(json['comment']),
      replies: (json['replies'] as List<dynamic>?)
          ?.map((reply) => PostComment.fromJson(reply))
          .toList() ?? [],
    );
  }
}