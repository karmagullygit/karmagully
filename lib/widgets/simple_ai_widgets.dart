import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/simple_ai_provider.dart';

// Simple AI Marketing Banner that actually shows changes
class SimpleAIBanner extends StatelessWidget {
  const SimpleAIBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAIProvider>(
      builder: (context, aiProvider, child) {
        // Only show if AI marketing is enabled and there's a promotional banner
        if (!aiProvider.isAIMarketingEnabled || aiProvider.promotionalBanner.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getBannerColor(aiProvider.promotionalBanner),
                _getBannerColor(aiProvider.promotionalBanner).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _getBannerColor(aiProvider.promotionalBanner).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon based on banner type
              Icon(
                _getBannerIcon(aiProvider.promotionalBanner),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aiProvider.promotionalBanner,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (aiProvider.currentDiscount > 0)
                      Text(
                        'Save ${aiProvider.currentDiscount.toInt()}% on all items!',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              if (aiProvider.showUrgencyBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIMITED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getBannerColor(String banner) {
    if (banner.contains('FLASH') || banner.contains('URGENT')) {
      return Colors.red[600]!;
    } else if (banner.contains('Featuring')) {
      return Colors.blue[600]!;
    } else if (banner.contains('Special') || banner.contains('FREE')) {
      return Colors.green[600]!;
    } else {
      return Colors.purple[600]!;
    }
  }

  IconData _getBannerIcon(String banner) {
    if (banner.contains('FLASH') || banner.contains('URGENT')) {
      return Icons.flash_on;
    } else if (banner.contains('Featuring')) {
      return Icons.star;
    } else if (banner.contains('Special') || banner.contains('FREE')) {
      return Icons.card_giftcard;
    } else {
      return Icons.campaign;
    }
  }
}

// Featured Collection Widget
class SimpleAIFeaturedCollection extends StatelessWidget {
  const SimpleAIFeaturedCollection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAIProvider>(
      builder: (context, aiProvider, child) {
        // Only show if AI marketing is enabled
        if (!aiProvider.isAIMarketingEnabled) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'AI RECOMMENDED',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (aiProvider.currentDiscount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${aiProvider.currentDiscount.toInt()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '🎯 ${aiProvider.featuredCollection} Collection',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Recommended Products
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: aiProvider.recommendedProducts.length,
                  itemBuilder: (context, index) {
                    final product = aiProvider.recommendedProducts[index];
                    return _buildProductCard(product, aiProvider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(String productName, SimpleAIProvider aiProvider) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[300]!, Colors.purple[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Icon(Icons.image, color: Colors.white, size: 40),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (aiProvider.currentDiscount > 0) ...[
                      Text(
                        '\$29.99',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${(29.99 * (1 - aiProvider.currentDiscount / 100)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        '\$29.99',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Special Offer Widget
class SimpleAISpecialOffer extends StatelessWidget {
  const SimpleAISpecialOffer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAIProvider>(
      builder: (context, aiProvider, child) {
        // Only show if there's a special offer
        if (aiProvider.specialOffer.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            border: Border.all(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                aiProvider.showUrgencyBadge ? Icons.access_time : Icons.local_offer,
                color: Colors.orange[800],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  aiProvider.specialOffer,
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (aiProvider.showUrgencyBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}