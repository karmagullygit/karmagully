import 'package:flutter/material.dart';

class SimpleBannerService {
  static final SimpleBannerService _instance = SimpleBannerService._internal();
  factory SimpleBannerService() => _instance;
  SimpleBannerService._internal();

  static SimpleBannerService get instance => _instance;

  OverlayEntry? _currentBanner;
  bool _isShowing = false;

  void showBanner({
    required BuildContext context,
    required String title,
    required String message,
    String? imageUrl,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Duration duration = const Duration(seconds: 8),
  }) {
    if (_isShowing) {
      hideBanner();
    }

    _isShowing = true;

    _currentBanner = OverlayEntry(
      builder: (context) => _SimpleBannerWidget(
        title: title,
        message: message,
        imageUrl: imageUrl,
        onTap: onTap,
        onClose: () {
          onClose?.call();
          hideBanner();
        },
        duration: duration,
      ),
    );

    Overlay.of(context).insert(_currentBanner!);

    // Auto-hide after duration
    Future.delayed(duration, () {
      if (_isShowing) {
        hideBanner();
      }
    });
  }

  void hideBanner() {
    if (_currentBanner != null) {
      _currentBanner!.remove();
      _currentBanner = null;
      _isShowing = false;
    }
  }
}

class _SimpleBannerWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final Duration duration;

  const _SimpleBannerWidget({
    required this.title,
    required this.message,
    this.imageUrl,
    this.onTap,
    this.onClose,
    required this.duration,
  });

  @override
  State<_SimpleBannerWidget> createState() => _SimpleBannerWidgetState();
}

class _SimpleBannerWidgetState extends State<_SimpleBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 16,
      left: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E2139),
                    Color(0xFF2A2D3A),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF6B73FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Left side - Image or Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B73FF), Color(0xFFEC4899)],
                      ),
                    ),
                    child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.campaign,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Middle - Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right side - Close button
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}