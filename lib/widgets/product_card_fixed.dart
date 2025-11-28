import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCardFixed extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCardFixed({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildProductImage(),
                ),
              ),
            ),
            
            // Product Details - Fixed height container to prevent overflow
            Container(
              height: 80, // Fixed height prevents overflow
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Expanded(
                    flex: 2,
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Add to Cart Button - Fixed height
                  SizedBox(
                    width: double.infinity,
                    height: 28,
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
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isInCart ? Icons.check : Icons.add_shopping_cart,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  isInCart ? 'Added' : 'Add',
                                  style: const TextStyle(fontSize: 10),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    // Get the first image URL/path
    String? imagePath;
    if (product.imageUrls.isNotEmpty) {
      imagePath = product.imageUrls.first;
    } else if (product.imageUrl.isNotEmpty) {
      imagePath = product.imageUrl;
    }

    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 50,
          ),
        ),
      );
    }

    // Check if it's a local file path
    if (imagePath.startsWith('/') || imagePath.contains('\\') || imagePath.startsWith('file://')) {
      final file = File(imagePath.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 50,
              ),
            ),
          ),
        );
      }
    }

    // It's a URL, use cached network image
    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 50,
          ),
        ),
      ),
    );
  }
}