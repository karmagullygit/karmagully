import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Responsive flex
            Expanded(
              flex: isSmallScreen ? 2 : 3, // Adjust flex based on screen size
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildProductImage(product.imageUrl),
                ),
              ),
            ),
            
            // Product Details - Responsive flex and padding
            Expanded(
              flex: isSmallScreen ? 3 : 2, // More space for content on small screens
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 4.0 : 6.0), // Responsive padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important: minimize space usage
                  children: [
                    // Product name - Flexible
                    Flexible(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 1 : 2), // Responsive spacing
                    
                    // Price - Flexible
                    Flexible(
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 15,
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    // Add to Cart Button - Responsive height
                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 24 : 28, // Responsive button height
                      child: Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          final isInCart = cart.isInCart(product.id);
                          return ElevatedButton(
                            onPressed: product.stock > 0 
                                ? () => cart.addItem(product)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInCart 
                                  ? Colors.green 
                                  : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8), // Responsive padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isInCart ? Icons.check : Icons.add_shopping_cart,
                                  size: isSmallScreen ? 14 : 16, // Responsive icon size
                                ),
                                SizedBox(width: isSmallScreen ? 2 : 4), // Responsive spacing
                                Flexible( // Make text flexible to prevent overflow
                                  child: Text(
                                    isInCart ? 'Added' : 'Add',
                                    style: TextStyle(fontSize: isSmallScreen ? 10 : 12), // Responsive font size
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
  }
  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey,
          ),
        ),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      // Assume local file path
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey,
          ),
        ),
      );
    }
  }}