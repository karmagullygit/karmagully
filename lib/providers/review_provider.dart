import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_review.dart';

class ReviewProvider extends ChangeNotifier {
  List<ProductReview> _reviews = [];
  Map<String, ProductRating> _productRatings = {};
  bool _isLoading = false;

  // Getters
  List<ProductReview> get reviews => _reviews;
  Map<String, ProductRating> get productRatings => _productRatings;
  bool get isLoading => _isLoading;

  // Get reviews for a specific product
  List<ProductReview> getProductReviews(String productId) {
    return _reviews.where((review) => review.productId == productId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get rating summary for a product
  ProductRating getProductRating(String productId) {
    if (_productRatings.containsKey(productId)) {
      return _productRatings[productId]!;
    }
    
    final productReviews = getProductReviews(productId);
    final rating = ProductRating.fromReviews(productReviews);
    _productRatings[productId] = rating;
    return rating;
  }

  ReviewProvider() {
    loadReviews();
  }

  // Load reviews from storage
  Future<void> loadReviews() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = prefs.getString('product_reviews');
      
      if (reviewsJson != null) {
        final List<dynamic> decoded = json.decode(reviewsJson);
        _reviews = decoded.map((item) => ProductReview.fromJson(item)).toList();
      } else {
        // Initialize with sample reviews
        _initializeSampleReviews();
      }
      
      _updateProductRatings();
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      _initializeSampleReviews();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save reviews to storage
  Future<void> _saveReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = json.encode(_reviews.map((review) => review.toJson()).toList());
      await prefs.setString('product_reviews', reviewsJson);
    } catch (e) {
      debugPrint('Error saving reviews: $e');
    }
  }

  // Update product ratings cache
  void _updateProductRatings() {
    _productRatings.clear();
    final Map<String, List<ProductReview>> productReviews = {};
    
    for (final review in _reviews) {
      productReviews.putIfAbsent(review.productId, () => []).add(review);
    }
    
    for (final entry in productReviews.entries) {
      _productRatings[entry.key] = ProductRating.fromReviews(entry.value);
    }
  }

  // Add a new review
  Future<bool> addReview(ProductReview review) async {
    try {
      _reviews.add(review);
      _updateProductRatings();
      await _saveReviews();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding review: $e');
      return false;
    }
  }

  // Add a new review with simplified parameters
  Future<bool> addSimpleReview(
    String productId, 
    String userName, 
    double rating, 
    String comment, {
    bool isVerifiedPurchase = false,
  }) async {
    final review = ProductReview(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      userId: 'user_1', // Default user ID
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isVerifiedPurchase: isVerifiedPurchase,
    );
    
    return await addReview(review);
  }

  // Toggle helpful status for a review
  Future<void> toggleHelpful(String reviewId) async {
    try {
      final index = _reviews.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        final review = _reviews[index];
        final currentUserId = 'user_1'; // Default user ID
        
        List<String> helpfulUsers = List.from(review.helpfulUsers);
        int helpfulCount = review.helpfulCount;
        
        if (helpfulUsers.contains(currentUserId)) {
          helpfulUsers.remove(currentUserId);
          helpfulCount = math.max(0, helpfulCount - 1);
        } else {
          helpfulUsers.add(currentUserId);
          helpfulCount += 1;
        }
        
        final updatedReview = ProductReview(
          id: review.id,
          productId: review.productId,
          userId: review.userId,
          userName: review.userName,
          userAvatar: review.userAvatar,
          rating: review.rating,
          comment: review.comment,
          images: review.images,
          createdAt: review.createdAt,
          updatedAt: DateTime.now(),
          isVerifiedPurchase: review.isVerifiedPurchase,
          helpfulCount: helpfulCount,
          helpfulUsers: helpfulUsers,
        );
        
        _reviews[index] = updatedReview;
        await _saveReviews();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling helpful: $e');
    }
  }

  // Update an existing review
  Future<bool> updateReview(ProductReview updatedReview) async {
    try {
      final index = _reviews.indexWhere((review) => review.id == updatedReview.id);
      if (index != -1) {
        _reviews[index] = updatedReview;
        _updateProductRatings();
        await _saveReviews();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating review: $e');
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      _reviews.removeWhere((review) => review.id == reviewId);
      _updateProductRatings();
      await _saveReviews();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  // Mark review as helpful
  Future<bool> markReviewHelpful(String reviewId, String userId) async {
    try {
      final index = _reviews.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        final review = _reviews[index];
        final helpfulUsers = List<String>.from(review.helpfulUsers);
        
        if (!helpfulUsers.contains(userId)) {
          helpfulUsers.add(userId);
          _reviews[index] = review.copyWith(
            helpfulUsers: helpfulUsers,
            helpfulCount: helpfulUsers.length,
          );
          await _saveReviews();
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error marking review helpful: $e');
      return false;
    }
  }

  // Initialize sample reviews
  void _initializeSampleReviews() {
    final now = DateTime.now();
    _reviews = [
      ProductReview(
        id: 'review_1',
        productId: '1', // Wireless Headphones
        userId: 'user_1',
        userName: 'Alice Johnson',
        userAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b6b96999?w=100',
        rating: 5.0,
        comment: 'Amazing sound quality! The noise cancellation works perfectly. Great for long flights and commutes.',
        images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isVerifiedPurchase: true,
        helpfulCount: 12,
      ),
      ProductReview(
        id: 'review_2',
        productId: '1',
        userId: 'user_2',
        userName: 'Bob Smith',
        userAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        rating: 4.0,
        comment: 'Good headphones overall. Battery life is excellent, but the build quality could be better.',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
        isVerifiedPurchase: true,
        helpfulCount: 8,
      ),
      ProductReview(
        id: 'review_3',
        productId: '2', // Smart Watch
        userId: 'user_3',
        userName: 'Carol Davis',
        userAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
        rating: 5.0,
        comment: 'Love this smartwatch! Health tracking is very accurate and the battery lasts for days.',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isVerifiedPurchase: true,
        helpfulCount: 15,
      ),
      ProductReview(
        id: 'review_4',
        productId: '3', // Running Shoes
        userId: 'user_4',
        userName: 'David Wilson',
        userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        rating: 4.5,
        comment: 'Very comfortable for long runs. Great cushioning and support. Highly recommended!',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        isVerifiedPurchase: true,
        helpfulCount: 6,
      ),
      ProductReview(
        id: 'review_5',
        productId: '2',
        userId: 'user_5',
        userName: 'Emma Brown',
        userAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
        rating: 3.0,
        comment: 'It\'s okay, but the interface can be confusing sometimes. Good value for money though.',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        isVerifiedPurchase: false,
        helpfulCount: 2,
      ),
    ];
    _saveReviews();
  }

  // Get reviews by rating
  List<ProductReview> getReviewsByRating(String productId, int rating) {
    return getProductReviews(productId)
        .where((review) => review.rating.round() == rating)
        .toList();
  }

  // Get average rating for a product
  double getAverageRating(String productId) {
    return getProductRating(productId).averageRating;
  }

  // Get total review count for a product
  int getTotalReviewCount(String productId) {
    return getProductRating(productId).totalReviews;
  }
}