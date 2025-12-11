import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post_report.dart';

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

  void _shareStory(Map<String, dynamic> story) {
    final shareText = '${story['caption'] ?? 'Check out this amazing content!'}\n\nShared from KarmaShop Community';
    Share.share(shareText);
  }

  void _showMoreOptions(BuildContext context, Map<String, dynamic> story) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1F26),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Color(0xFF6B73FF)),
                title: const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _shareStory(story);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Color(0xFF6B73FF)),
                title: const Text('Copy Link', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(const ClipboardData(text: 'https://karmashop.com/reels'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard'),
                      backgroundColor: Color(0xFF6B73FF),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_outline, color: Color(0xFF6B73FF)),
                title: const Text('Save', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved to bookmarks'),
                      backgroundColor: Color(0xFF6B73FF),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white12, height: 1),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.orange),
                title: const Text('Report', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined, color: Colors.red),
                title: const Text('Not Interested', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('We\'ll show you fewer posts like this'),
                      backgroundColor: Color(0xFF6B73FF),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    String? selectedReason;
    final descriptionController = TextEditingController();
    final authProvider = context.read<AuthProvider>();
    final currentStory = widget.stories[_currentIndex];
    
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to report content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final reasonOptions = [
      ReportReason.spam,
      ReportReason.harassment,
      ReportReason.hateSpeech,
      ReportReason.violence,
      ReportReason.nudity,
      ReportReason.misinformation,
      ReportReason.scam,
      ReportReason.other,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1F26),
          title: Row(
            children: [
              const Icon(Icons.flag_outlined, color: Colors.orange),
              const SizedBox(width: 12),
              const Text('Report Content', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why are you reporting this reel?',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ...reasonOptions.map((reason) => RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    reason.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  value: reason.value,
                  groupValue: selectedReason,
                  activeColor: const Color(0xFF6B73FF),
                  onChanged: (value) {
                    setState(() => selectedReason = value);
                  },
                )),
                const SizedBox(height: 16),
                const Text(
                  'Additional details (optional)',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  maxLength: 200,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Provide more context...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6B73FF)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                descriptionController.dispose();
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: selectedReason != null
                  ? () async {
                      debugPrint('');
                      debugPrint('🎬 REEL REPORT SUBMISSION STARTED');
                      debugPrint('=====================================');
                      
                      // Get reel information
                      final reelId = currentStory['postId'] ?? 'reel_${currentStory['name']}_${DateTime.now().millisecondsSinceEpoch}';
                      final reelOwnerId = currentStory['userId'] ?? 'unknown_user';
                      final reelOwnerUsername = currentStory['username'] ?? currentStory['name'] ?? 'Unknown';
                      final reelOwnerKarmaId = currentStory['karmaId'] ?? 'KG-${reelOwnerUsername.toUpperCase()}';
                      final reelContent = currentStory['caption'] ?? '[Video/Image Content]';
                      final reelMediaUrls = <String>[
                        if (currentStory['type'] == 'video' && currentStory['videoUrl'] != null)
                          currentStory['videoUrl'].toString()
                        else if (currentStory['image'] != null)
                          currentStory['image'].toString()
                      ];
                      
                      debugPrint('📹 Reel ID: $reelId');
                      debugPrint('👥 Owner: $reelOwnerUsername ($reelOwnerKarmaId)');
                      debugPrint('👤 Reporter: ${currentUser.name} (${currentUser.karmaId})');
                      debugPrint('📝 Reason: $selectedReason');
                      debugPrint('=====================================');
                      
                      try {
                        debugPrint('🔄 Calling ReportProvider.reportPost...');
                        final reportProvider = context.read<ReportProvider>();
                        final success = await reportProvider.reportPost(
                          postId: reelId,
                          reportedBy: currentUser.id,
                          reportedByUsername: currentUser.name,
                          reportedByKarmaId: currentUser.karmaId,
                          postOwnerId: reelOwnerId,
                          postOwnerUsername: reelOwnerUsername,
                          postOwnerKarmaId: reelOwnerKarmaId,
                          reason: selectedReason!,
                          description: descriptionController.text.trim().isEmpty 
                              ? null 
                              : descriptionController.text.trim(),
                          postContent: reelContent,
                          postMediaUrls: reelMediaUrls,
                        );
                        
                        debugPrint('');
                        debugPrint(success ? '✅ SUCCESS!' : '❌ FAILED!');
                        debugPrint('📊 Unresolved reports now: ${reportProvider.unresolvedReports.length}');
                        debugPrint('');
                        
                        descriptionController.dispose();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      success 
                                        ? 'Report submitted! Check Admin → Reports Management' 
                                        : 'Failed to submit report. Please try again.',
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: success ? Colors.green : Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      } catch (e, stackTrace) {
                        debugPrint('❌ EXCEPTION: $e');
                        debugPrint('Stack: $stackTrace');
                        descriptionController.dispose();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B73FF),
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Submit Report'),
            ),
          ],
        ),
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
                      onTap: () => _shareStory(story),
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
                      onPressed: () => _showMoreOptions(context, story),
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
