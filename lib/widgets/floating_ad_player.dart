import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../providers/video_ad_provider.dart';


class FloatingAdPlayer extends StatefulWidget {
  const FloatingAdPlayer({super.key});

  @override
  State<FloatingAdPlayer> createState() => _FloatingAdPlayerState();
}

class _FloatingAdPlayerState extends State<FloatingAdPlayer> {
  Offset _position = const Offset(20, 500); // Initial position
  VideoPlayerController? _controller;
  int _currentAdIndex = 0;
  bool _isDragging = false;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideoAd();
    });
  }

  void _loadVideoAd() {
    final provider = Provider.of<VideoAdProvider>(context, listen: false);
    final ads = provider.activeVideoAds;
    
    if (ads.isEmpty) return;

    _currentAdIndex = _currentAdIndex % ads.length;
    final ad = ads[_currentAdIndex];

    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(ad.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller?.play();
          _controller?.setLooping(false);
          _controller?.addListener(_videoListener);
        }
      });
  }

  void _videoListener() {
    if (_controller != null && _controller!.value.position >= _controller!.value.duration) {
      _playNextAd();
    }
  }

  void _playNextAd() {
    final provider = Provider.of<VideoAdProvider>(context, listen: false);
    final ads = provider.activeVideoAds;
    
    if (ads.isEmpty) return;

    _currentAdIndex = (_currentAdIndex + 1) % ads.length;
    _loadVideoAd();
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoAdProvider>(
      builder: (context, provider, child) {
        if (!provider.isPlayerVisible || provider.activeVideoAds.isEmpty) {
          return const SizedBox.shrink();
        }

        final screenSize = MediaQuery.of(context).size;
        final playerWidth = _isMinimized ? 80.0 : 160.0;
        final playerHeight = _isMinimized ? 80.0 : 180.0;

        // Keep player within screen bounds
        _position = Offset(
          _position.dx.clamp(0, screenSize.width - playerWidth),
          _position.dy.clamp(0, screenSize.height - playerHeight - 100),
        );

        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  (_position.dx + details.delta.dx).clamp(0, screenSize.width - playerWidth),
                  (_position.dy + details.delta.dy).clamp(0, screenSize.height - playerHeight - 100),
                );
              });
            },
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
              });
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: playerWidth,
                height: playerHeight,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                child: Stack(
                  children: [
                    // Video Player
                    if (_controller != null && _controller!.value.isInitialized && !_isMinimized)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: playerWidth,
                          height: playerHeight,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        ),
                      )
                    else if (!_isMinimized)
                      Center(
                        child: CircularProgressIndicator(
                          color: Colors.purple,
                          strokeWidth: 2,
                        ),
                      ),

                    // Minimized state
                    if (_isMinimized)
                      Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.purple,
                          size: 40,
                        ),
                      ),

                    // Controls overlay (only when not minimized)
                    if (!_isMinimized)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_controller != null) {
                                    setState(() {
                                      _controller!.value.isPlaying
                                          ? _controller!.pause()
                                          : _controller!.play();
                                    });
                                  }
                                },
                                child: Icon(
                                  _controller?.value.isPlaying ?? false
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isMinimized = !_isMinimized;
                                  });
                                },
                                child: Icon(
                                  Icons.minimize,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Close button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          provider.hidePlayer();
                          _controller?.pause();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: _isMinimized ? 16 : 18,
                          ),
                        ),
                      ),
                    ),

                    // AD label
                    if (!_isMinimized)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AD',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Expand button when minimized
                    if (_isMinimized)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isMinimized = false;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
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
