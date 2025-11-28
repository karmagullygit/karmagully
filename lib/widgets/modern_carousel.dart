import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/carousel_banner.dart';
import '../utils/responsive_utils.dart';

class ModernCarousel extends StatefulWidget {
  final List<CarouselBanner> banners;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final EdgeInsets? margin;

  const ModernCarousel({
    super.key,
    required this.banners,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showIndicators = true,
    this.margin,
  });

  @override
  State<ModernCarousel> createState() => _ModernCarouselState();
}

class _ModernCarouselState extends State<ModernCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _autoPlayTimer;
  
  int _currentIndex = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.autoPlay && widget.banners.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (mounted && !_isDragging && widget.banners.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: ResponsiveUtils.getCarouselHeight(context),
      margin: widget.margin ?? EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
        vertical: ResponsiveUtils.getVerticalSpacing(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
        child: Stack(
          children: [
            // Main carousel with gesture detection
            GestureDetector(
              onPanStart: (_) {
                setState(() => _isDragging = true);
                _stopAutoPlay();
              },
              onPanEnd: (_) {
                setState(() => _isDragging = false);
                if (widget.autoPlay && widget.banners.length > 1) {
                  _startAutoPlay();
                }
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.banners.length,
                itemBuilder: (context, index) {
                  return _buildCarouselItem(widget.banners[index], index);
                },
              ),
            ),
            
            // Gradient overlay for better text visibility
            _buildGradientOverlay(),
            
            // Indicators
            if (widget.showIndicators && widget.banners.length > 1)
              _buildIndicators(),
            
            // Navigation arrows - Always visible on all devices
            if (widget.banners.length > 1)
              _buildNavigationArrows(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: ResponsiveUtils.getCarouselHeight(context),
      margin: widget.margin ?? EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
        vertical: ResponsiveUtils.getVerticalSpacing(context),
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: ResponsiveUtils.getIconSize(context) * 2,
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
            Text(
              'No banners available',
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(CarouselBanner banner, int index) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () => _onBannerTapped(banner),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              _buildBackgroundImage(banner),
              
              // Content overlay
              _buildContentOverlay(banner),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(CarouselBanner banner) {
    if (banner.imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: banner.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Icon(
            Icons.image_not_supported,
            size: ResponsiveUtils.getIconSize(context) * 2,
            color: Colors.grey[600],
          ),
        ),
      );
    } else {
      return Container(
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
      );
    }
  }

  Widget _buildContentOverlay(CarouselBanner banner) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (banner.title.isNotEmpty) ...[
            Text(
              banner.title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: _parseColor(banner.textColor),
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) / 2),
          ],
          if (banner.subtitle.isNotEmpty) ...[
            Text(
              banner.subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                color: _parseColor(banner.textColor).withOpacity(0.9),
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: ResponsiveUtils.getCarouselHeight(context) * 0.6,
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
          ),
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Positioned(
      bottom: ResponsiveUtils.getVerticalPadding(context),
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.banners.length,
          (index) => _buildIndicator(index),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentIndex;
    final indicatorSize = ResponsiveUtils.getIndicatorSize(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalSpacing(context) / 4,
      ),
      height: indicatorSize,
      width: isActive ? indicatorSize * 3 : indicatorSize,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(indicatorSize / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationArrows() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left arrow
            _buildArrow(
              icon: Icons.chevron_left,
              onTap: _previousPage,
            ),
            // Right arrow
            _buildArrow(
              icon: Icons.chevron_right,
              onTap: _nextPage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTapDown: (_) {
        // Visual feedback on tap
      },
      onTap: () {
        // Stop auto-play temporarily when user manually navigates
        _stopAutoPlay();
        setState(() => _isDragging = true);
        onTap();
        // Resume auto-play after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _isDragging = false);
            if (widget.autoPlay && widget.banners.length > 1) {
              _startAutoPlay();
            }
          }
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        widget.banners.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentIndex < widget.banners.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.isEmpty) return Colors.white;
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  void _onBannerTapped(CarouselBanner banner) {
    // Add haptic feedback for premium feel
    // HapticFeedback.lightImpact();
    
    if (banner.actionUrl != null && banner.actionUrl!.isNotEmpty) {
      _handleBannerAction(banner);
    }
  }

  void _handleBannerAction(CarouselBanner banner) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${banner.title}'),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
        ),
      ),
    );
  }
}