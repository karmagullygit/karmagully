import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import '../models/carousel_banner.dart';

class PremiumAnimatedCarousel extends StatefulWidget {
  final List<CarouselBanner> banners;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Function(CarouselBanner)? onBannerTap;

  const PremiumAnimatedCarousel({
    Key? key,
    required this.banners,
    this.height = 200,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.onBannerTap,
  }) : super(key: key);

  @override
  _PremiumAnimatedCarouselState createState() => _PremiumAnimatedCarouselState();
}

class _PremiumAnimatedCarouselState extends State<PremiumAnimatedCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _progressController;
  late AnimationController _indicatorController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: widget.autoPlayInterval,
      vsync: this,
    );
    
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_progressController);
    
    _animationController.forward();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.autoPlay && widget.banners.length > 1) {
      _progressController.forward();
      _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
        if (!_isUserInteracting && mounted) {
          _nextPage();
        }
      });
    }
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _progressController.stop();
  }

  void _nextPage() {
    if (_currentIndex < widget.banners.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _animateToPage(_currentIndex);
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
    _progressController.reset();
    _progressController.forward();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _indicatorController.forward().then((_) {
      _indicatorController.reverse();
    });
  }

  Widget _buildBannerImage(CarouselBanner banner) {
    // Check if banner has local image file first
    if (banner.imageUrl.startsWith('/') || banner.imageUrl.contains('\\')) {
      final file = File(banner.imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: widget.height,
        );
      }
    }

    // Fallback to network image
    return CachedNetworkImage(
      imageUrl: banner.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: widget.height,
      placeholder: (context, url) => _CarouselShimmer(height: widget.height),
      errorWidget: (context, url, error) => Container(
        height: widget.height,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return Container(
        height: widget.height,
        color: Colors.grey[300],
        child: Center(
          child: Text(
            'No banners available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.height,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Carousel content
                    GestureDetector(
                      onPanStart: (_) {
                        setState(() {
                          _isUserInteracting = true;
                        });
                        _stopAutoPlay();
                      },
                      onPanEnd: (_) {
                        setState(() {
                          _isUserInteracting = false;
                        });
                        _startAutoPlay();
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: widget.banners.length,
                        itemBuilder: (context, index) {
                          final banner = widget.banners[index];
                          return GestureDetector(
                            onTap: () => widget.onBannerTap?.call(banner),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Banner image
                                _buildBannerImage(banner),
                                
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Banner content
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (banner.title.isNotEmpty)
                                        Text(
                                          banner.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (banner.subtitle.isNotEmpty)
                                        const SizedBox(height: 8),
                                      if (banner.subtitle.isNotEmpty)
                                        Text(
                                          banner.subtitle,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Progress indicator
                    if (widget.autoPlay && widget.banners.length > 1)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _progressAnimation.value,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                              minHeight: 3,
                            );
                          },
                        ),
                      ),
                    
                    // Navigation arrows
                    if (widget.banners.length > 1)
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _NavigationButton(
                            icon: Icons.chevron_left,
                            onTap: () {
                              final prevIndex = _currentIndex > 0 
                                  ? _currentIndex - 1 
                                  : widget.banners.length - 1;
                              _animateToPage(prevIndex);
                            },
                          ),
                        ),
                      ),
                    
                    if (widget.banners.length > 1)
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _NavigationButton(
                            icon: Icons.chevron_right,
                            onTap: () {
                              final nextIndex = _currentIndex < widget.banners.length - 1 
                                  ? _currentIndex + 1 
                                  : 0;
                              _animateToPage(nextIndex);
                            },
                          ),
                        ),
                      ),
                    
                    // Page indicators
                    if (widget.banners.length > 1)
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        child: _PageIndicators(
                          count: widget.banners.length,
                          currentIndex: _currentIndex,
                          animation: _indicatorController,
                          onTap: _animateToPage,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.icon,
    required this.onTap,
  });

  @override
  _NavigationButtonState createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered 
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  final int count;
  final int currentIndex;
  final AnimationController animation;
  final Function(int) onTap;

  const _PageIndicators({
    required this.count,
    required this.currentIndex,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final isSelected = index == currentIndex;
              final scale = isSelected ? 1.0 + (animation.value * 0.2) : 1.0;
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _CarouselShimmer extends StatefulWidget {
  final double height;

  const _CarouselShimmer({required this.height});

  @override
  _CarouselShimmerState createState() => _CarouselShimmerState();
}

class _CarouselShimmerState extends State<_CarouselShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                math.max(0.0, _animation.value - 0.3),
                _animation.value,
                math.min(1.0, _animation.value + 0.3),
              ],
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}