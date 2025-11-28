import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/advertisement.dart';
import '../providers/advertisement_provider.dart';
import '../utils/responsive_utils.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final Advertisement advertisement;
  final VoidCallback? onClose;

  const SimpleVideoPlayer({
    super.key,
    required this.advertisement,
    this.onClose,
  });

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  Offset _position = const Offset(20, 100);
  bool _isMinimized = true;
  bool _isDismissed = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
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
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    final expandedWidth = ResponsiveUtils.getVideoPlayerExpandedWidth(context);
    final expandedHeight = ResponsiveUtils.getVideoPlayerExpandedHeight(context);
    final minimizedSize = ResponsiveUtils.getVideoPlayerMinimizedSize(context);
    final screenSize = ResponsiveUtils.getScreenSize(context);

    return Positioned(
      left: _position.dx.clamp(0, screenSize.width - (_isMinimized ? minimizedSize : expandedWidth)),
      top: _position.dy.clamp(0, screenSize.height - (_isMinimized ? minimizedSize : expandedHeight)),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onTap: _onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isMinimized ? minimizedSize : expandedWidth,
            height: _isMinimized ? minimizedSize : expandedHeight,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(_isMinimized ? minimizedSize / 2 : 12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: _isDragging ? 8 : 4,
                  offset: const Offset(0, 2),
                  spreadRadius: _isDragging ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isMinimized ? minimizedSize / 2 : 12),
              child: Stack(
                children: [
                  // Video placeholder content
                  _buildVideoContent(),
                  
                  // Close button - always visible and prominent
                  _buildCloseButton(),
                  
                  // Play/info overlay when minimized
                  if (_isMinimized) _buildMinimizedOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade800,
            Colors.purple.shade800,
          ],
        ),
      ),
      child: _isMinimized
          ? const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.video_library,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.advertisement.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.advertisement.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: _onClose,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: _isMinimized ? 12 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMinimizedOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  void _onTap() {
    if (!_isDragging) {
      setState(() {
        _isMinimized = !_isMinimized;
      });
    }
  }

  void _onClose() {
    print('Simple video player close button tapped!');
    
    // Immediately hide the widget
    setState(() {
      _isDismissed = true;
    });

    // Dismiss from provider
    try {
      Provider.of<AdvertisementProvider>(context, listen: false)
          .dismissFloatingVideoAd(widget.advertisement.id);
      print('Successfully dismissed video ad: ${widget.advertisement.id}');
    } catch (e) {
      print('Error dismissing video ad: $e');
    }

    // Call the onClose callback
    widget.onClose?.call();
  }
}