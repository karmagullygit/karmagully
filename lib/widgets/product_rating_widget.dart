import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';

class ProductRatingWidget extends StatelessWidget {
  final String productId;
  final double size;
  final bool showCount;
  
  const ProductRatingWidget({
    super.key,
    required this.productId,
    this.size = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final reviews = reviewProvider.getProductReviews(productId);
        final averageRating = reviewProvider.getAverageRating(productId);
        
        if (reviews.isEmpty) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_border,
                    color: Colors.grey[400],
                    size: size,
                  );
                }),
              ),
              if (showCount) ...[
                const SizedBox(width: 4),
                Text(
                  '(0)',
                  style: TextStyle(
                    fontSize: size * 0.8,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          );
        }
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < averageRating
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: size,
                );
              }),
            ),
            if (showCount) ...[
              const SizedBox(width: 4),
              Text(
                averageRating > 0 
                    ? '${averageRating.toStringAsFixed(1)} (${reviews.length})'
                    : '(${reviews.length})',
                style: TextStyle(
                  fontSize: size * 0.8,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class ReviewSummaryWidget extends StatelessWidget {
  final String productId;
  
  const ReviewSummaryWidget({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final reviews = reviewProvider.getProductReviews(productId);
        final averageRating = reviewProvider.getAverageRating(productId);
        
        if (reviews.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.star_border,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to review this product!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reviews.length} reviews',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: List.generate(5, (index) {
                      final starCount = 5 - index;
                      final count = reviews
                          .where((review) => review.rating.toInt() == starCount)
                          .length;
                      final percentage = count / reviews.length;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$starCount'),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.amber,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 20,
                              child: Text(
                                '$count',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}