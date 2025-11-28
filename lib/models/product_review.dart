class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final List<String> helpfulUsers;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.helpfulUsers = const [],
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      helpfulCount: json['helpfulCount'] ?? 0,
      helpfulUsers: List<String>.from(json['helpfulUsers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'helpfulUsers': helpfulUsers,
    };
  }

  ProductReview copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerifiedPurchase,
    int? helpfulCount,
    List<String>? helpfulUsers,
  }) {
    return ProductReview(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
    );
  }
}

class ProductRating {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // star -> count
  final List<ProductReview> recentReviews;

  ProductRating({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.recentReviews,
  });

  factory ProductRating.fromReviews(List<ProductReview> reviews) {
    if (reviews.isEmpty) {
      return ProductRating(
        averageRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        recentReviews: [],
      );
    }

    final Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double totalRating = 0.0;

    for (final review in reviews) {
      totalRating += review.rating;
      final starRating = review.rating.round();
      distribution[starRating] = (distribution[starRating] ?? 0) + 1;
    }

    final averageRating = totalRating / reviews.length;
    final recentReviews = List<ProductReview>.from(reviews)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
      ..take(5);

    return ProductRating(
      averageRating: averageRating,
      totalReviews: reviews.length,
      ratingDistribution: distribution,
      recentReviews: recentReviews.toList(),
    );
  }
}