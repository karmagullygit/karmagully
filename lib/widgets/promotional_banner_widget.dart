import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/promotional_banner_provider.dart';
import '../models/promotional_banner.dart';

class PromotionalBannerWidget extends StatelessWidget {
  final String page;
  final String? category;

  const PromotionalBannerWidget({
    super.key,
    required this.page,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionalBannerProvider>(
      builder: (context, provider, child) {
        final banners = provider.getBannersForPage(page, category: category);
        
        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show the highest priority banner
        final banner = banners.first;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 70,
          decoration: BoxDecoration(
            color: banner.backgroundColor != null
                ? Color(int.parse(banner.backgroundColor!.replaceFirst('#', '0xFF')))
                : const Color(0xFF6B73FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Image (if provided)
              if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildBackgroundImage(banner.imageUrl!),
                  ),
                ),
              
              // Content
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: banner.imageUrl != null
                        ? LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      // App Logo
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/karma_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Icon(
                              Icons.local_offer,
                              color: banner.textColor != null
                                  ? Color(int.parse(banner.textColor!.replaceFirst('#', '0xFF')))
                                  : Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Text Content
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.title,
                              style: TextStyle(
                                color: banner.textColor != null
                                    ? Color(int.parse(banner.textColor!.replaceFirst('#', '0xFF')))
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (banner.subtitle.isNotEmpty)
                              Text(
                                banner.subtitle,
                                style: TextStyle(
                                  color: banner.textColor != null
                                      ? Color(int.parse(banner.textColor!.replaceFirst('#', '0xFF'))).withOpacity(0.8)
                                      : Colors.white70,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      
                      // Shop Now Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (banner.buttonLink != null && banner.buttonLink!.isNotEmpty) {
                              Navigator.pushNamed(context, banner.buttonLink!);
                            }
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: banner.buttonColor != null
                                  ? Color(int.parse(banner.buttonColor!.replaceFirst('#', '0xFF')))
                                  : Colors.amber,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: (banner.buttonColor != null
                                      ? Color(int.parse(banner.buttonColor!.replaceFirst('#', '0xFF')))
                                      : Colors.amber).withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  banner.buttonText,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundImage(String imageUrl) {
    // Check if it's a base64 encoded image
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const SizedBox(),
        );
      } catch (e) {
        return const SizedBox();
      }
    } else {
      // It's a regular URL
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const SizedBox(),
      );
    }
  }
}
