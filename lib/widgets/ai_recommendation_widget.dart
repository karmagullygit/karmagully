import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recommendation_provider.dart';
import '../models/product.dart';
import '../screens/customer/product_detail_screen.dart';

class AIRecommendationWidget extends StatelessWidget {
  const AIRecommendationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<ProductProvider, OrderProvider, AuthProvider, RecommendationProvider>(
      builder: (context, productProvider, orderProvider, authProvider, recommendationProvider, child) {
        // Only show for logged-in users who have made orders
        if (authProvider.currentUser == null) return const SizedBox.shrink();
        
        final userOrders = orderProvider.getUserOrders(authProvider.currentUser!.id);
        if (userOrders.isEmpty) return const SizedBox.shrink();

        // Always regenerate recommendations when products change to ensure sync
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final userOrderHistory = userOrders.expand((order) => order.items.map((item) => item.product.id)).toList();
          recommendationProvider.generateRecommendationsFromRealProducts(
            productProvider.products,
            userOrderHistory: userOrderHistory,
          );
        });

        // Use the real recommendation system
        final recommendedProducts = recommendationProvider.recommendedProducts;
        
        // Show recommendations if available
        if (recommendedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildRecommendationCard(context, recommendedProducts.take(6).toList());
      },
    );
  }

  Widget _buildRecommendationCard(BuildContext context, List<Product> products) {
    return Consumer<RecommendationProvider>(
      builder: (context, recommendationProvider, child) {
        final config = recommendationProvider.config;
        
        if (!config.isEnabled) {
          return const SizedBox.shrink();
        }

        final displayProducts = products.take(config.maxRecommendations).toList();

        return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      config.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayProducts.length,
              itemBuilder: (context, index) {
                final product = displayProducts[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(productId: product.id),
                    ),
                  ),
                  child: Container(
                    width: 100,
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
                        Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: product.imageUrls.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    product.imageUrls.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.image, color: Colors.grey),
                                  ),
                                )
                              : const Icon(Icons.image, color: Colors.grey),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}