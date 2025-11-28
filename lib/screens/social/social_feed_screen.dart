import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../providers/social_feed_provider.dart';
import '../../models/social_post.dart';
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
    return GestureDetector(
      onTap: () {
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
  }

  Widget _buildStories(BuildContext context) {
    return Consumer<SocialFeedProvider>(
      builder: (context, provider, child) {
        final userStories = provider.stories;
        
        // Sample stories to show if user has no stories
        final sampleStories = [
          {
            'name': 'Savannah',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'More',
                  style: TextStyle(color: Color(0xFF6B73FF), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=800'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up, color: Colors.black, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Like',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/4.jpg'),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Annette',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hello My Friends, Today I Did Studying For The First Time It Was A Great Experience',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildHashtag('travel'),
                    const SizedBox(width: 8),
                    _buildHashtag('smile'),
                    const SizedBox(width: 8),
                    _buildHashtag('studying'),
                    const SizedBox(width: 8),
                    _buildHashtag('sickness'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: feedProvider.posts.length + 3,
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
              final post = feedProvider.posts[index - 3];
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
                          Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.5)),
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
