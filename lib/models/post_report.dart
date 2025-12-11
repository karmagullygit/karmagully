class PostReport {
  final String id;
  final String postId;
  final String reportedBy; // User ID who reported
  final String reportedByUsername;
  final String reportedByKarmaId;
  final String postOwnerId; // User ID of post owner
  final String postOwnerUsername;
  final String postOwnerKarmaId;
  final String reason;
  final String? description;
  final DateTime reportedAt;
  final bool isResolved;
  final String? resolvedBy; // Admin ID who resolved
  final DateTime? resolvedAt;
  final String? adminNotes;
  final String postContent; // Copy of post content for reference
  final List<String> postMediaUrls; // Copy of media for reference

  PostReport({
    required this.id,
    required this.postId,
    required this.reportedBy,
    required this.reportedByUsername,
    required this.reportedByKarmaId,
    required this.postOwnerId,
    required this.postOwnerUsername,
    required this.postOwnerKarmaId,
    required this.reason,
    this.description,
    required this.reportedAt,
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
    this.adminNotes,
    required this.postContent,
    this.postMediaUrls = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'reportedBy': reportedBy,
      'reportedByUsername': reportedByUsername,
      'reportedByKarmaId': reportedByKarmaId,
      'postOwnerId': postOwnerId,
      'postOwnerUsername': postOwnerUsername,
      'postOwnerKarmaId': postOwnerKarmaId,
      'reason': reason,
      'description': description,
      'reportedAt': reportedAt.toIso8601String(),
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'adminNotes': adminNotes,
      'postContent': postContent,
      'postMediaUrls': postMediaUrls,
    };
  }

  factory PostReport.fromJson(Map<String, dynamic> json) {
    return PostReport(
      id: json['id'] as String,
      postId: json['postId'] as String,
      reportedBy: json['reportedBy'] as String,
      reportedByUsername: json['reportedByUsername'] as String,
      reportedByKarmaId: json['reportedByKarmaId'] as String,
      postOwnerId: json['postOwnerId'] as String,
      postOwnerUsername: json['postOwnerUsername'] as String,
      postOwnerKarmaId: json['postOwnerKarmaId'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      adminNotes: json['adminNotes'] as String?,
      postContent: json['postContent'] as String,
      postMediaUrls: (json['postMediaUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }

  PostReport copyWith({
    String? id,
    String? postId,
    String? reportedBy,
    String? reportedByUsername,
    String? reportedByKarmaId,
    String? postOwnerId,
    String? postOwnerUsername,
    String? postOwnerKarmaId,
    String? reason,
    String? description,
    DateTime? reportedAt,
    bool? isResolved,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? adminNotes,
    String? postContent,
    List<String>? postMediaUrls,
  }) {
    return PostReport(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByUsername: reportedByUsername ?? this.reportedByUsername,
      reportedByKarmaId: reportedByKarmaId ?? this.reportedByKarmaId,
      postOwnerId: postOwnerId ?? this.postOwnerId,
      postOwnerUsername: postOwnerUsername ?? this.postOwnerUsername,
      postOwnerKarmaId: postOwnerKarmaId ?? this.postOwnerKarmaId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      reportedAt: reportedAt ?? this.reportedAt,
      isResolved: isResolved ?? this.isResolved,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      postContent: postContent ?? this.postContent,
      postMediaUrls: postMediaUrls ?? this.postMediaUrls,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(reportedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Report reasons
enum ReportReason {
  spam,
  harassment,
  hateSpeech,
  violence,
  nudity,
  misinformation,
  scam,
  other,
}

extension ReportReasonExtension on ReportReason {
  String get value {
    switch (this) {
      case ReportReason.spam:
        return 'spam';
      case ReportReason.harassment:
        return 'harassment';
      case ReportReason.hateSpeech:
        return 'hate_speech';
      case ReportReason.violence:
        return 'violence';
      case ReportReason.nudity:
        return 'nudity';
      case ReportReason.misinformation:
        return 'misinformation';
      case ReportReason.scam:
        return 'scam';
      case ReportReason.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment or Bullying';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.violence:
        return 'Violence or Dangerous Content';
      case ReportReason.nudity:
        return 'Nudity or Sexual Content';
      case ReportReason.misinformation:
        return 'False Information';
      case ReportReason.scam:
        return 'Scam or Fraud';
      case ReportReason.other:
        return 'Other';
    }
  }
}
