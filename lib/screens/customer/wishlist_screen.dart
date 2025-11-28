import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(themeProvider.isDarkMode),
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.wishlist,
              style: TextStyle(
                color: AppColors.getTextColor(themeProvider.isDarkMode),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.getBackgroundColor(themeProvider.isDarkMode),
            elevation: 0,
            iconTheme: IconThemeData(
              color: AppColors.getTextColor(themeProvider.isDarkMode),
            ),
            actions: [
              Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, child) {
                  if (wishlistProvider.itemCount > 0) {
                    return IconButton(
                      onPressed: () {
                        _showClearWishlistDialog(context, wishlistProvider, themeProvider.isDarkMode);
                      },
                      icon: Icon(
                        Icons.clear_all,
                        color: AppColors.getTextColor(themeProvider.isDarkMode),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
          body: Consumer2<WishlistProvider, ProductProvider>(
            builder: (context, wishlistProvider, productProvider, child) {
              if (wishlistProvider.itemCount == 0) {
                return _buildEmptyWishlist(themeProvider.isDarkMode, context);
              }

              final wishlistProducts = productProvider.products
                  .where((product) => wishlistProvider.isInWishlist(product.id))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: wishlistProducts.length,
                itemBuilder: (context, index) {
                  final product = wishlistProducts[index];
                  return _buildWishlistItem(
                    product, 
                    wishlistProvider, 
                    themeProvider.isDarkMode,
                    context,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyWishlist(bool isDarkMode, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Wishlist is Empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products you love to your wishlist',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(dynamic product, WishlistProvider wishlistProvider, bool isDarkMode, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.getBorderColor(isDarkMode),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_outlined,
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          size: 32,
                        );
                      },
                    )
                  : Icon(
                      Icons.image_outlined,
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Column(
            children: [
              IconButton(
                onPressed: () {
                  wishlistProvider.removeFromWishlist(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} removed from wishlist'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                  color: AppColors.error,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Add to cart functionality
                  Provider.of<CartProvider>(context, listen: false).addItem(
                    product.id,
                    product.name,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  Icons.shopping_cart,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearWishlistDialog(BuildContext context, WishlistProvider wishlistProvider, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
          title: Text(
            'Clear Wishlist',
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          content: Text(
            'Are you sure you want to remove all items from your wishlist?',
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                wishlistProvider.clearWishlist();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wishlist cleared'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}