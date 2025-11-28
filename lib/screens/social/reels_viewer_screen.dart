import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class ReelsViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const ReelsViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<ReelsViewerScreen> createState() => _ReelsViewerScreenState();
}

class _ReelsViewerScreenState extends State<ReelsViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, bool> _likedStories = {};
  final Map<int, int> _likeCounts = {};
  final Map<int, VideoPlayerController?> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    // Initialize like counts
    for (int i = 0; i < widget.stories.length; i++) {
      final likesStr = widget.stories[i]['likes'].toString();
      int likes = 0;
      if (likesStr.contains('K')) {
        likes = (double.parse(likesStr.replaceAll('K', '')) * 1000).toInt();
      } else {
        likes = int.tryParse(likesStr) ?? 0;
      }
      _likeCounts[i] = likes;
      _likedStories[i] = false;
    }
    
    // Initialize first video if exists
    _initializeVideo(_currentIndex);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeVideo(int index) {
    final story = widget.stories[index];
    if (story['type'] == 'video' && story['videoUrl'] != null) {
      final videoController = VideoPlayerController.network(story['videoUrl']);
      videoController.initialize().then((_) {
        if (mounted && _currentIndex == index) {
          setState(() {});
          videoController.play();
          videoController.setLooping(true);
        }
      });
      _videoControllers[index] = videoController;
    }
  }

  void _toggleLike() {
    setState(() {
      _likedStories[_currentIndex] = !(_likedStories[_currentIndex] ?? false);
      if (_likedStories[_currentIndex] == true) {
        _likeCounts[_currentIndex] = (_likeCounts[_currentIndex] ?? 0) + 1;
      } else {
        _likeCounts[_currentIndex] = (_likeCounts[_currentIndex] ?? 1) - 1;
      }
    });
  }

  String _formatLikeCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1F26),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Comments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCommentItem('Alex', 'Amazing content! 🔥', '2m ago'),
                    _buildCommentItem('Sarah', 'Love this!', '5m ago'),
                    _buildCommentItem('Mike', 'Keep it up! 👏', '10m ago'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF13161B),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF6B73FF),
                      child: Text('Y', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF6B73FF)),
                      onPressed: () {},
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

  Widget _buildCommentItem(String name, String comment, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF6B73FF),
            child: Text(
              name[0],
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white54, size: 18),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.stories.length,
        onPageChanged: (index) {
          // Pause previous video
          _videoControllers[_currentIndex]?.pause();
          
          setState(() {
            _currentIndex = index;
          });
          
          // Initialize and play new video
          if (!_videoControllers.containsKey(index)) {
            _initializeVideo(index);
          } else {
            _videoControllers[index]?.play();
          }
        },
        itemBuilder: (context, index) {
          final story = widget.stories[index];
          final isLiked = _likedStories[index] ?? false;
          final likeCount = _likeCounts[index] ?? 0;
          
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background Content (Image or Video)
              if (story['type'] == 'video' && _videoControllers[index] != null)
                Center(
                  child: _videoControllers[index]!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoControllers[index]!.value.aspectRatio,
                          child: VideoPlayer(_videoControllers[index]!),
                        )
                      : const CircularProgressIndicator(color: Colors.white),
                )
              else
                Image.network(
                  story['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1C1F26),
                    child: const Icon(Icons.broken_image, color: Colors.white38, size: 80),
                  ),
                ),
              
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
              
              // Top Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(story['image'] ?? ''),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                story['name'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                story['time'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Right Side Action Buttons
              Positioned(
                right: 12,
                bottom: 80,
                child: Column(
                  children: [
                    // Like Button
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Column(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatLikeCount(likeCount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Comment Button
                    GestureDetector(
                      onTap: _showCommentSheet,
                      child: Column(
                        children: [
                          const Icon(Icons.comment, color: Colors.white, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            story['comments'] ?? '0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Share Button
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          const Icon(Icons.send, color: Colors.white, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            story['shares'] ?? '0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // More Button
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              // Bottom Caption
              if (story['caption'] != null && story['caption'].toString().isNotEmpty)
                Positioned(
                  left: 16,
                  right: 80,
                  bottom: 24,
                  child: Text(
                    story['caption'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
