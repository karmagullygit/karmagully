import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/carousel_banner.dart';
import '../providers/advertisement_provider.dart';
import '../utils/navigation_helper.dart';

class AdvancedCarousel extends StatefulWidget {
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final BorderRadius borderRadius;

  const AdvancedCarousel({
    super.key,
    this.height = 200.0,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showIndicators = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<AdvancedCarousel> createState() => _AdvancedCarouselState();
}

class _AdvancedCarouselState extends State<AdvancedCarousel>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementProvider>(
      builder: (context, adProvider, child) {
        final banners = adProvider.getActiveCarouselBanners();
        print('Active carousel banners count: ${banners.length}'); // Debug print

        if (banners.isEmpty) {
          // Show a placeholder while loading or if no banners
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: widget.borderRadius,
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.view_carousel, size: 48, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    'Loading banners...',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: FlutterCarousel(
                      options: FlutterCarouselOptions(
                        height: widget.height,
                        viewportFraction: 1.0,
                        autoPlay: widget.autoPlay,
                        autoPlayInterval: widget.autoPlayInterval,
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: false,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      items: banners.map((banner) {
                        return Builder(
                          builder: (BuildContext context) {
                            return _buildCarouselItem(banner);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (widget.showIndicators && banners.length > 1) ...[
                  const SizedBox(height: 12),
                  _buildIndicators(banners.length),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(CarouselBanner banner) {
    return GestureDetector(
      onTap: () => _handleBannerTap(banner),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _parseColor(banner.backgroundColor),
              _parseColor(banner.backgroundColor).withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: _parseColor(banner.backgroundColor).withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: _parseColor(banner.backgroundColor),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner.title,
                    style: TextStyle(
                      color: _parseColor(banner.textColor),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  if (banner.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle,
                      style: TextStyle(
                        color: _parseColor(banner.textColor).withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shop Now',
                          style: TextStyle(
                            color: _parseColor(banner.textColor),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: _parseColor(banner.textColor),
                          size: 16,
                        ),
                      ],
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

  Widget _buildIndicators(int count) {
    return AnimatedSmoothIndicator(
      activeIndex: _currentIndex,
      count: count,
      effect: ExpandingDotsEffect(
        dotWidth: 8,
        dotHeight: 8,
        activeDotColor: Colors.blue,
        dotColor: Colors.blue.withOpacity(0.3),
        expansionFactor: 3,
        spacing: 6,
      ),
      onDotClicked: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  void _handleBannerTap(CarouselBanner banner) {
    if (banner.actionUrl != null) {
      // Handle navigation based on action URL
      if (banner.actionUrl!.startsWith('/product/') && banner.productId != null) {
        // Navigate to product detail
        NavigationHelper.navigateToProductDetail(context, banner.productId!);
      } else {
        // Handle other navigation types
        _handleCustomNavigation(banner.actionUrl!);
      }
    }
  }

  void _handleCustomNavigation(String actionUrl) {
    // Handle custom navigation based on action URL
    switch (actionUrl) {
      case '/sale':
      case '/new-arrivals':
      case '/free-shipping':
      case '/promotions/special':
        // For now, show a snackbar. Later can implement specific navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigating to: $actionUrl'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      default:
        debugPrint('Unknown action URL: $actionUrl');
    }
  }
}