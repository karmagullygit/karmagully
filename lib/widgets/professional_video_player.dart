import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/advertisement.dart';
import '../providers/advertisement_provider.dart';

class ProfessionalVideoPlayer extends StatefulWidget {
  final Advertisement advertisement;
  final VoidCallback? onClose;

  const ProfessionalVideoPlayer({
    super.key,
    required this.advertisement,
    this.onClose,
  });

  @override
  State<ProfessionalVideoPlayer> createState() => _ProfessionalVideoPlayerState();
}

class _ProfessionalVideoPlayerState extends State<ProfessionalVideoPlayer>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  late AnimationController _entryController;
  late AnimationController _dragController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _entryAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  
  Offset _position = const Offset(20, 100);
  bool _isMinimized = true; // Start minimized
  bool _isLoading = true;
  bool _hasError = false;
  bool _isDragging = false;
  bool _showControls = false;
  bool _isDismissed = false; // Track dismissal state
  
  // Remove old static methods - using helper methods instead

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeVideo();
  }

  void _setupAnimations() {
    // Entry animation for the video player
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _entryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    // Drag interaction animations
    _dragController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _dragController, curve: Curves.easeInOut),
    );

    // Pulse animation for attention
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer for loading state
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _entryController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  void _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.network(widget.advertisement.videoUrl ?? '');
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        aspectRatio: 16 / 9,
        placeholder: _buildThumbnailPlaceholder(),
        autoInitialize: true,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _dragController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // Responsive sizing based on screen size - SMALLER SIZES
  double _getExpandedWidth(Size screenSize) => screenSize.width * 0.5; // Reduced from 70% to 50%
  double _getExpandedHeight(Size screenSize) => screenSize.height * 0.2; // Reduced from 25% to 20%
  double _getMinimizedSize(Size screenSize) => screenSize.width * 0.12; // Reduced from 15% to 12%
  
  @override
  Widget build(BuildContext context) {
    // If dismissed, return empty container
    if (_isDismissed) {
      return const SizedBox.shrink();
    }
    
    final screenSize = MediaQuery.of(context).size;
    final expandedWidth = _getExpandedWidth(screenSize);
    final expandedHeight = _getExpandedHeight(screenSize);
    final minimizedSize = _getMinimizedSize(screenSize).clamp(40.0, 60.0); // Smaller clamp range
    
    return Positioned(
      left: _position.dx.clamp(0, screenSize.width - ((_isMinimized ? minimizedSize : expandedWidth))),
      top: _position.dy.clamp(0, screenSize.height - ((_isMinimized ? minimizedSize : expandedHeight))),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _entryAnimation,
          child: _buildVideoPlayerWidget(screenSize, expandedWidth, expandedHeight, minimizedSize),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerWidget(Size screenSize, double expandedWidth, double expandedHeight, double minimizedSize) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: (details) => _onPanUpdate(details, screenSize, expandedWidth, expandedHeight, minimizedSize),
        onPanEnd: _onPanEnd,
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isMinimized ? minimizedSize : expandedWidth,
          height: _isMinimized ? minimizedSize : expandedHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_isMinimized ? minimizedSize / 2 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: _isDragging ? 3 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_isMinimized ? minimizedSize / 2 : 12),
            child: Stack(
              children: [
                // Video content
                _buildVideoContent(),
                
                // Overlay with controls
                _buildOverlay(),
                
                // Loading/Error states
                if (_isLoading) _buildLoadingState(minimizedSize),
                if (_hasError) _buildErrorState(minimizedSize),
                
                // Close button
                _buildCloseButton(),
                
                // Minimize/Expand button
                if (!_isMinimized) _buildMinimizeButton(),
                
                // Professional border effect
                _buildBorderEffect(minimizedSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: _isMinimized 
          ? _buildMinimizedThumbnail()
          : _buildExpandedVideo(),
    );
  }

  Widget _buildMinimizedThumbnail() {
    return Stack(
      children: [
        // Thumbnail image
        CachedNetworkImage(
          imageUrl: widget.advertisement.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorThumbnail(),
        ),
        
        // Play icon overlay with pulse animation
        Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedVideo() {
    if (_chewieController == null) {
      return _buildThumbnailPlaceholder();
    }
    
    return Chewie(controller: _chewieController!);
  }

  Widget _buildThumbnailPlaceholder() {
    return CachedNetworkImage(
      imageUrl: widget.advertisement.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorThumbnail(),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorThumbnail() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    if (_isMinimized) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            children: [
              // Top bar with title
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.advertisement.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Bottom bar with action button
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onActionButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Learn More'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(double minimizedSize) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(_isMinimized ? minimizedSize / 2 : 12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(double minimizedSize) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.circular(_isMinimized ? minimizedSize / 2 : 12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'Video Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 2,
      right: 2,
      child: GestureDetector(
        onTap: () {
          print('Close button area tapped!'); // Debug
          // Immediately hide the widget
          if (mounted) {
            setState(() {
              _isDismissed = true; // Hide immediately
            });
          }
          _onClose();
        },
        child: Container(
          padding: const EdgeInsets.all(8), // Increased padding
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.95), // More opaque red
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2), // Thicker border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: _isMinimized ? 16 : 20, // Bigger icons
          ),
        ),
      ),
    );
  }

  Widget _buildMinimizeButton() {
    return Positioned(
      top: 8,
      left: 8,
      child: GestureDetector(
        onTap: _toggleMinimize,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.minimize,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBorderEffect(double minimizedSize) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_isMinimized ? minimizedSize / 2 : 12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _dragController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details, Size screenSize, double expandedWidth, double expandedHeight, double minimizedSize) {
    setState(() {
      final newX = (_position.dx + details.delta.dx).clamp(
        0.0,
        screenSize.width - (_isMinimized ? minimizedSize : expandedWidth),
      );
      final newY = (_position.dy + details.delta.dy).clamp(
        0.0,
        screenSize.height - (_isMinimized ? minimizedSize : expandedHeight),
      );
      _position = Offset(newX, newY);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    _dragController.reverse();
  }

  void _onTap() {
    if (_isMinimized) {
      _toggleMinimize();
    } else {
      setState(() {
        _showControls = !_showControls;
      });
      
      // Hide controls after 3 seconds
      if (_showControls) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    }
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
      _showControls = false;
    });
  }

  void _onClose() {
    print('Video player close button tapped!'); // Debug
    
    // Dismiss the ad
    try {
      Provider.of<AdvertisementProvider>(context, listen: false)
          .dismissFloatingVideoAd(widget.advertisement.id);
      print('Successfully dismissed video ad: ${widget.advertisement.id}'); // Debug
    } catch (e) {
      print('Error dismissing video ad: $e'); // Debug
    }
    
    // Call the onClose callback
    widget.onClose?.call();
  }

  void _onActionButtonPressed() {
    // Handle action button press (e.g., navigate to product page)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${widget.advertisement.title}'),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}