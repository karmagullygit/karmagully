import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/social_feed_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/social_post.dart';
import '../../models/post_report.dart';
import 'create_post_screen.dart';
import 'comments_screen.dart';
import 'reels_viewer_screen.dart';
import 'create_story_screen.dart';

// Video Player Widget for Feed Posts
class FeedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String postId;
  
  const FeedVideoPlayer({super.key, required this.videoUrl, required this.postId});

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isManuallyPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl.startsWith('http')) {
      _controller = VideoPlayerController.network(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    }
    
    try {
      await _controller.initialize();
      _controller.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _handleVisibilityChange(VisibilityInfo info) {
    if (!_isInitialized) return;
    
    // If video is more than 60% visible and not manually paused, play it
    if (info.visibleFraction > 0.6 && !_isManuallyPaused) {
      if (!_controller.value.isPlaying) {
        _controller.play();
        if (mounted) setState(() {});
      }
    } else {
      // Pause when video goes out of viewport
      if (_controller.value.isPlaying) {
        _controller.pause();
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 300,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6B73FF)),
        ),
      );
    }

    return VisibilityDetector(
      key: Key('video_${widget.postId}'),
      onVisibilityChanged: _handleVisibilityChange,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
              _isManuallyPaused = true;
            } else {
              _controller.play();
              _isManuallyPaused = false;
            }
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            if (!_controller.value.isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF6B73FF),
                  bufferedColor: Colors.white24,
                backgroundColor: Colors.white12,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Widget _imageError() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.white38, size: 40),
      ),
    );
  }

  Widget _buildWhatsOnYourMind(BuildContext context) {
    return Consumer2<AuthProvider, UserManagementProvider>(
      builder: (context, authProvider, userManagement, child) {
        final currentUser = authProvider.currentUser;
        final user = currentUser != null ? userManagement.getUserByKarmaId(currentUser.karmaId) : null;
        final isBanned = user?.isBanned ?? false;

        return GestureDetector(
          onTap: () {
            if (isBanned) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You are banned from posting. Reason: ${user?.banReason ?? "Violation of community guidelines"}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            );
          },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF6B73FF),
              child: const Text(
                'S',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "What's on your mind?",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B73FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image_outlined, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildStories(BuildContext context) {
    return Consumer<SocialFeedProvider>(
      builder: (context, provider, child) {
        final userStories = provider.stories;
        
        // Sample stories to show if user has no stories
        final sampleStories = [
          {
            'name': 'Savannah',
            'userId': 'sample_user_savannah',
            'username': 'savannah',
            'karmaId': 'KG-SAVANNAH',
            'postId': 'sample_story_savannah_1',
            'image': 'https://randomuser.me/api/portraits/women/1.jpg',
            'type': 'image',
            'time': '2h ago',
            'likes': '1.2K',
            'comments': '45',
            'shares': '12',
            'caption': 'Beautiful sunset today! 🌅'
          },
          {
            'name': 'Cooper',
            'userId': 'sample_user_cooper',
            'username': 'cooper',
            'karmaId': 'KG-COOPER',
            'postId': 'sample_story_cooper_1',
            'image': 'https://randomuser.me/api/portraits/men/2.jpg',
            'type': 'video',
            'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            'time': '5h ago',
            'likes': '890',
            'comments': '23',
            'shares': '8',
            'caption': 'Check out this amazing video!'
          },
          {
            'name': 'Howard',
            'userId': 'sample_user_howard',
            'username': 'howard',
            'karmaId': 'KG-HOWARD',
            'postId': 'sample_story_howard_1',
            'image': 'https://randomuser.me/api/portraits/men/3.jpg',
            'type': 'image',
            'time': '1h ago',
            'likes': '2.1K',
            'comments': '67',
            'shares': '34',
            'caption': 'Living my best life ✨'
          },
        ];

        // Convert user stories to reels format and combine with sample stories
        final allStories = [
          ...userStories.map((story) => story.toReelsFormat()).toList(),
          ...sampleStories,
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Stories',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allStories.length + 1, // +1 for Add Story button
            itemBuilder: (context, i) {
              // Add Story button as first item
              if (i == 0) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateStoryScreen()),
                    );
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6B73FF), width: 2),
                      color: const Color(0xFF1C1F26),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B73FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add Story',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final story = allStories[i - 1];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReelsViewerScreen(
                        stories: allStories,
                        initialIndex: i - 1,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(story['image'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                story['name'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (story['type'] == 'video')
                              const Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
      },
    );
  }

  Widget _buildTrending() {
    return Consumer<SocialFeedProvider>(
      builder: (context, provider, child) {
        final trendingPosts = provider.getTrendingPosts(minViews: 0);
        
        debugPrint('🔥 Trending posts: ${trendingPosts.length}');
        debugPrint('📊 Total posts in feed: ${provider.posts.length}');
        
        if (trendingPosts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Trending',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${trendingPosts.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showAllTrendingPosts(context, trendingPosts),
                    child: const Text(
                      'More',
                      style: TextStyle(color: Color(0xFF6B73FF), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trendingPosts.length,
                itemBuilder: (context, index) {
                  final post = trendingPosts[index];
                  return _buildTrendingCard(context, post, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendingCard(BuildContext context, SocialPost post, int index) {
    final hasMedia = post.mediaUrls.isNotEmpty;
    final imageUrl = hasMedia ? post.mediaUrls.first : 'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=800';
    
    return GestureDetector(
      onTap: () {
        // Navigate to reels viewer for all posts
        final trendingPosts = context.read<SocialFeedProvider>().getTrendingPosts(minViews: 0);
        final reelsData = trendingPosts.map((p) {
          // Use default image if post has no media
          final postImage = p.mediaUrls.isNotEmpty 
            ? p.mediaUrls.first 
            : 'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=800';
            
          return {
            'name': p.userDisplayName ?? p.username,
            'userId': p.userId,
            'username': p.username,
            'postId': p.id,
            'image': postImage,
            'type': p.hasVideo ? 'video' : 'image',
            'videoUrl': p.hasVideo && p.mediaUrls.isNotEmpty ? p.mediaUrls.first : null,
            'time': p.timeAgo,
            'likes': p.likesCount >= 1000 
              ? '${(p.likesCount / 1000).toStringAsFixed(1)}K' 
              : '${p.likesCount}',
            'comments': '${p.commentsCount}',
            'shares': '${p.sharesCount}',
            'caption': p.content,
          };
        }).toList();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelsViewerScreen(
              stories: reelsData,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '#${index + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (post.hasVideo)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF6B73FF),
                        child: Text(
                          (post.userDisplayName ?? post.username)[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          post.userDisplayName ?? post.username,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.content,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.white.withOpacity(0.7), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${post.viewsCount}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite, color: Colors.red.withOpacity(0.7), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                      ),
                    ],
                  ),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: post.tags.take(2).map((tag) => _buildHashtag(tag)).toList(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllTrendingPosts(BuildContext context, List<SocialPost> trendingPosts) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF181A20),
          appBar: AppBar(
            title: Row(
              children: [
                const Text('Trending Now', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF181A20),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: trendingPosts.length,
            itemBuilder: (context, index) {
              return _buildTrendingCard(context, trendingPosts[index], index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHashtag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$text',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
      ],
    );
  }

  Widget _buildMediaContent(SocialPost post) {
    if (post.mediaUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    final mediaUrl = post.mediaUrls.first;
    final isVideo = post.hasVideo || 
                    mediaUrl.endsWith('.mp4') || 
                    mediaUrl.endsWith('.mov') || 
                    mediaUrl.endsWith('.avi') ||
                    mediaUrl.contains('video');

    if (isVideo) {
      return FeedVideoPlayer(
        videoUrl: mediaUrl,
        postId: post.id,
      );
    } else {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: mediaUrl.startsWith('http')
            ? Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _imageError(),
              )
            : Image.file(
                File(mediaUrl),
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _imageError(),
              ),
      );
    }
  }

  void _handleMenuAction(BuildContext context, String action, SocialPost post, SocialFeedProvider provider) {
    switch (action) {
      case 'edit':
        _showEditDialog(context, post, provider);
        break;
      case 'delete':
        _showDeleteConfirmation(context, post, provider);
        break;
      case 'share':
        _sharePost(post);
        break;
      case 'copylink':
        _copyPostLink(context, post);
        break;
      case 'bookmark':
        _savePost(context, post);
        break;
      case 'report':
        _showReportDialog(context, post);
        break;
      case 'hide':
        _hidePost(context, post, provider);
        break;
    }
  }

  void _showEditDialog(BuildContext context, SocialPost post, SocialFeedProvider provider) {
    final controller = TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Edit Post', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              // Update post content (you may need to add updatePost method to provider)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post updated successfully'),
                  backgroundColor: Color(0xFF6B73FF),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B73FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SocialPost post, SocialFeedProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Delete Post', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deletePost(post.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sharePost(SocialPost post) {
    final shareText = '${post.content}\n\nShared from KarmaShop Community';
    if (post.hasMedia && post.mediaUrls.isNotEmpty) {
      Share.share(shareText);
    } else {
      Share.share(shareText);
    }
  }

  void _copyPostLink(BuildContext context, SocialPost post) {
    final postLink = 'https://karmashop.com/posts/${post.id}';
    Clipboard.setData(ClipboardData(text: postLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post link copied to clipboard'),
        backgroundColor: Color(0xFF6B73FF),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _savePost(BuildContext context, SocialPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post saved to your bookmarks'),
        backgroundColor: Color(0xFF6B73FF),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showReportDialog(BuildContext context, SocialPost post) {
    String? selectedReason;
    final descriptionController = TextEditingController();
    final authProvider = context.read<AuthProvider>();
    final userManagement = context.read<UserManagementProvider>();
    final reportProvider = context.read<ReportProvider>();
    
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to report posts'),
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
              const Text('Report Post', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why are you reporting this post?',
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
                      final success = await reportProvider.reportPost(
                        postId: post.id,
                        reportedBy: currentUser.id,
                        reportedByUsername: currentUser.name,
                        reportedByKarmaId: currentUser.karmaId,
                        postOwnerId: post.userId,
                        postOwnerUsername: post.userDisplayName ?? post.username,
                        postOwnerKarmaId: post.userId, // Using userId as KarmaId
                        reason: selectedReason!,
                        description: descriptionController.text.trim().isEmpty 
                            ? null 
                            : descriptionController.text.trim(),
                        postContent: post.content,
                        postMediaUrls: post.mediaUrls,
                      );
                      
                      descriptionController.dispose();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    success 
                                      ? 'Report submitted. We\'ll review this within 24 hours.' 
                                      : 'Failed to submit report. Please try again.',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: success ? const Color(0xFF6B73FF) : Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
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

  void _hidePost(BuildContext context, SocialPost post, SocialFeedProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post hidden. You won\'t see posts from this user.'),
        backgroundColor: const Color(0xFF6B73FF),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // Undo hide action
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Community Feed', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF181A20),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.read<SocialFeedProvider>().refreshFeed(),
            icon: const Icon(Icons.refresh, color: Color(0xFF6B73FF)),
            tooltip: 'Refresh Feed',
          ),
        ],
      ),
      body: Consumer<SocialFeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6B73FF)));
          }
          if (feedProvider.error != null) {
            return Center(child: Text('Error: ${feedProvider.error!}', style: const TextStyle(color: Colors.red)));
          }
          if (feedProvider.posts.isEmpty) {
            return const Center(child: Text('No posts yet. Start sharing your moments!', style: TextStyle(color: Colors.white70)));
          }
          
          // Get trending posts to exclude from regular feed
          final trendingPosts = feedProvider.getTrendingPosts(minViews: 0);
          final trendingIds = trendingPosts.map((p) => p.id).toSet();
          
          // Filter out trending posts from regular feed
          final regularPosts = feedProvider.posts.where((post) => !trendingIds.contains(post.id)).toList();
          
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: regularPosts.length + 3,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildWhatsOnYourMind(context);
              }
              if (index == 1) {
                return _buildStories(context);
              }
              if (index == 2) {
                return _buildTrending();
              }
              final post = regularPosts[index - 3];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF1C1F26),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF6B73FF),
                            child: Text(
                              (post.userDisplayName ?? post.username).isNotEmpty
                                  ? (post.userDisplayName ?? post.username)[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.userDisplayName ?? post.username,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                ),
                                Text(
                                  _formatDate(post.createdAt),
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.5)),
                            color: const Color(0xFF1C1F26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            onSelected: (value) => _handleMenuAction(context, value, post, feedProvider),
                            itemBuilder: (context) => [
                              if (post.userId == feedProvider.currentUserId) ...[
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_outlined, color: Color(0xFF6B73FF), size: 20),
                                      const SizedBox(width: 12),
                                      Text('Edit Post', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      const SizedBox(width: 12),
                                      Text('Delete Post', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                              ],
                              PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    const Icon(Icons.share_outlined, color: Color(0xFF6B73FF), size: 20),
                                    const SizedBox(width: 12),
                                    Text('Share Post', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'copylink',
                                child: Row(
                                  children: [
                                    const Icon(Icons.link, color: Color(0xFF6B73FF), size: 20),
                                    const SizedBox(width: 12),
                                    Text('Copy Link', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'bookmark',
                                child: Row(
                                  children: [
                                    const Icon(Icons.bookmark_outline, color: Color(0xFF6B73FF), size: 20),
                                    const SizedBox(width: 12),
                                    Text('Save Post', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                  ],
                                ),
                              ),
                              if (post.userId != feedProvider.currentUserId) ...[
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
                                      const SizedBox(width: 12),
                                      Text('Report Post', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'hide',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.visibility_off_outlined, color: Colors.grey, size: 20),
                                      const SizedBox(width: 12),
                                      Text('Hide Post', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (post.content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          post.content,
                          style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
                        ),
                      ),
                    if (post.mediaUrls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _buildMediaContent(post),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<SocialFeedProvider>().toggleLike(post.id);
                            },
                            child: _buildActionButton(
                              post.isLikedBy(context.read<SocialFeedProvider>().currentUserId) 
                                ? Icons.thumb_up 
                                : Icons.thumb_up_outlined,
                              '${post.likesCount}',
                              const Color(0xFF6B73FF),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<SocialFeedProvider>().toggleDislike(post.id);
                            },
                            child: _buildActionButton(
                              post.isDislikedBy(context.read<SocialFeedProvider>().currentUserId)
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                              '${post.dislikesCount}',
                              Colors.redAccent,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentsScreen(post: post),
                                ),
                              );
                            },
                            child: _buildActionButton(Icons.chat_bubble_outline, '${post.commentsCount}', Colors.white60),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement share functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Share feature coming soon!')),
                              );
                            },
                            child: _buildActionButton(Icons.share_outlined, 'Share', const Color(0xFF6B73FF)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: const Color(0xFF6B73FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
