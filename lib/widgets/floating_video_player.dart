import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../models/advertisement.dart';
import '../providers/advertisement_provider.dart';

class FloatingVideoPlayer extends StatefulWidget {
  final Advertisement advertisement;

  const FloatingVideoPlayer({
    super.key,
    required this.advertisement,
  });

  @override
  State<FloatingVideoPlayer> createState() => _FloatingVideoPlayerState();
}

class _FloatingVideoPlayerState extends State<FloatingVideoPlayer>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isInitialized = false;
  bool _isDragging = false;
  bool _isMinimized = false;
  Offset _position = const Offset(20, 100); // Initial position
  final double _playerWidth = 160;
  final double _playerHeight = 90;
  final double _minimizedWidth = 120;
  final double _minimizedHeight = 67;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start entrance animation
    _scaleController.forward();
    _slideController.forward();
  }

  void _initializeVideo() {
    if (widget.advertisement.videoUrl != null) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.advertisement.videoUrl!),
      );

      _videoController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          
          // Auto-play if enabled in metadata
          final autoplay = widget.advertisement.metadata['autoplay'] ?? false;
          if (autoplay) {
            _videoController.play();
            _videoController.setLooping(true);
          }
        }
      }).catchError((error) {
        debugPrint('Video initialization error: $error');
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.advertisement.hasVideo) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final width = _isMinimized ? _minimizedWidth : _playerWidth;
    final height = _isMinimized ? _minimizedHeight : _playerHeight;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onPanStart: (_) {
              setState(() {
                _isDragging = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  (_position.dx + details.delta.dx).clamp(
                    0.0,
                    screenSize.width - width,
                  ),
                  (_position.dy + details.delta.dy).clamp(
                    0.0,
                    screenSize.height - height - 100, // Account for bottom nav
                  ),
                );
              });
            },
            onPanEnd: (_) {
              setState(() {
                _isDragging = false;
              });
              _snapToEdge(screenSize, width);
            },
            onTap: _isMinimized ? _expandPlayer : _togglePlayPause,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isDragging ? 0.3 : 0.2),
                    blurRadius: _isDragging ? 15 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Video Player
                    if (_isInitialized)
                      AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      )
                    else
                      Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),

                    // Controls Overlay
                    if (!_isMinimized) _buildControlsOverlay(),

                    // Close Button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _closePlayer,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    // Minimize/Expand Button
                    if (!_isMinimized)
                      Positioned(
                        top: 4,
                        right: 32,
                        child: GestureDetector(
                          onTap: _minimizePlayer,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.minimize,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),

                    // Title overlay for minimized state
                    if (_isMinimized)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        right: 4,
                        child: Text(
                          widget.advertisement.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.4),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Play/Pause Button
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _videoController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Title
                  Expanded(
                    child: Text(
                      widget.advertisement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  void _togglePlayPause() {
    if (!_isInitialized) return;

    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
    });
  }

  void _minimizePlayer() {
    setState(() {
      _isMinimized = true;
    });
  }

  void _expandPlayer() {
    setState(() {
      _isMinimized = false;
    });
  }

  void _closePlayer() {
    // Animate out
    _scaleController.reverse().then((_) {
      // Mark as dismissed in the provider
      Provider.of<AdvertisementProvider>(context, listen: false)
          .dismissFloatingVideoAd(widget.advertisement.id);
    });
  }

  void _snapToEdge(Size screenSize, double width) {
    final centerX = screenSize.width / 2;
    final newX = _position.dx < centerX ? 10.0 : screenSize.width - width - 10;
    
    setState(() {
      _position = Offset(newX, _position.dy);
    });
  }
}