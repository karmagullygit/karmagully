import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/social_feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/social_post.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String displayName;
  final String avatar;
  final bool isVerified;
  final String? profilePictureUrl;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.avatar,
    this.isVerified = false,
    this.profilePictureUrl,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhoto = false;

  String get karmaId {
    // Generate unique Karma ID using username
    final cleanUsername = widget.username.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final hash = cleanUsername.hashCode.abs();
    return 'karma$hash';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _changeProfilePicture() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    // Check if viewing own profile
    if (currentUser?.id != widget.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only edit your own profile picture'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (picked != null) {
      setState(() => _isUploadingPhoto = true);
      
      try {
        // Update user profile with new picture
        final updatedUser = currentUser!.copyWith(
          profilePicture: picked.path,
        );
        
        await authProvider.updateProfile(updatedUser);
        
        // Update all posts with new profile picture
        final socialProvider = Provider.of<SocialFeedProvider>(context, listen: false);
        await socialProvider.updateUserAvatar(widget.userId, picked.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Color(0xFF818CF8),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile picture: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingPhoto = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Consumer<SocialFeedProvider>(
        builder: (context, socialProvider, child) {
          // Get all posts by this user
          final userPosts = socialProvider.posts
              .where((post) => post.userId == widget.userId)
              .toList();

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: const Color(0xFF0A0E27),
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF818CF8).withOpacity(0.3),
                          const Color(0xFF0A0E27),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Avatar with profile picture and edit button
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF818CF8),
                                      Color(0xFF6366F1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF818CF8).withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: widget.profilePictureUrl != null && widget.profilePictureUrl!.isNotEmpty && (widget.profilePictureUrl!.startsWith('http') || widget.profilePictureUrl!.contains('/'))
                                      ? Builder(builder: (context) {
                                          final pic = widget.profilePictureUrl!;
                                          try {
                                            if (pic.startsWith('http')) {
                                              return Image.network(
                                                pic,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stack) {
                                                  return Center(
                                                    child: Text(
                                                      widget.avatar,
                                                      style: const TextStyle(fontSize: 48),
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                            return Image.file(
                                              File(pic),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stack) {
                                                return Center(
                                                  child: Text(
                                                    widget.avatar,
                                                    style: const TextStyle(fontSize: 48),
                                                  ),
                                                );
                                              },
                                            );
                                          } catch (e) {
                                            return Center(
                                              child: Text(
                                                widget.avatar,
                                                style: const TextStyle(fontSize: 48),
                                              ),
                                            );
                                          }
                                        })
                                      : Center(
                                          child: Text(
                                            widget.avatar,
                                            style: const TextStyle(fontSize: 48),
                                          ),
                                        ),
                                ),
                              ),
                              // Edit button (only for own profile)
                              Consumer<AuthProvider>(
                                builder: (context, auth, child) {
                                  if (auth.currentUser?.id == widget.userId) {
                                    return Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _isUploadingPhoto ? null : _changeProfilePicture,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF818CF8),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: _isUploadingPhoto
                                              ? const Padding(
                                                  padding: EdgeInsets.all(6),
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // User Info Section
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Display Name with verification badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF1D9BF0),
                            size: 24,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Username
                    Text(
                      '@${widget.username}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Karma ID with copy button
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: karmaId));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Karma ID copied to clipboard'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color(0xFF818CF8),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F3A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF818CF8).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fingerprint,
                              color: Color(0xFF818CF8),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              karmaId,
                              style: const TextStyle(
                                color: Color(0xFF818CF8),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.copy,
                              color: Color(0xFF818CF8),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F3A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Posts',
                            userPosts.length.toString(),
                            Icons.article,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24,
                          ),
                          _buildStatItem(
                            'Likes',
                            userPosts
                                .fold(0, (sum, post) => sum + post.likesCount)
                                .toString(),
                            Icons.favorite,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24,
                          ),
                          _buildStatItem(
                            'Views',
                            userPosts
                                .fold(0, (sum, post) => sum + post.viewsCount)
                                .toString(),
                            Icons.visibility,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tabs Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F3A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        indicatorColor: const Color(0xFF818CF8),
                        indicatorWeight: 3,
                        tabs: [
                          Tab(
                            icon: Icon(Icons.grid_on),
                            text: 'All Posts',
                          ),
                          Tab(
                            icon: Icon(Icons.image),
                            text: 'Images',
                          ),
                          Tab(
                            icon: Icon(Icons.video_library),
                            text: 'Videos',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Posts Grid - filtered by tab
              _buildFilteredPosts(userPosts),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilteredPosts(List<SocialPost> allPosts) {
    List<SocialPost> filteredPosts;
    
    switch (_selectedTabIndex) {
      case 0: // All Posts
        filteredPosts = allPosts;
        break;
      case 1: // Images only
        filteredPosts = allPosts.where((post) => 
          post.type == PostType.image || post.type == PostType.mixed
        ).toList();
        break;
      case 2: // Videos only
        filteredPosts = allPosts.where((post) => 
          post.type == PostType.video
        ).toList();
        break;
      default:
        filteredPosts = allPosts;
    }

    if (filteredPosts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedTabIndex == 0 ? Icons.post_add : 
                _selectedTabIndex == 1 ? Icons.image : Icons.video_library,
                size: 64,
                color: Colors.white24,
              ),
              const SizedBox(height: 16),
              Text(
                _selectedTabIndex == 0 ? 'No posts yet' :
                _selectedTabIndex == 1 ? 'No images yet' : 'No videos yet',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = filteredPosts[index];
            return _buildPostCard(post);
          },
          childCount: filteredPosts.length,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF818CF8),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(SocialPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF818CF8).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post date
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.white54,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                post.formattedDate,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (post.isPinned)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.push_pin,
                        size: 12,
                        color: Color(0xFF818CF8),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Pinned',
                        style: TextStyle(
                          color: Color(0xFF818CF8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Post content
          Text(
            post.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Post stats
          Row(
            children: [
              _buildPostStat(Icons.favorite, post.likesCount, Colors.red),
              const SizedBox(width: 16),
              _buildPostStat(Icons.comment, post.commentsCount, Colors.blue),
              const SizedBox(width: 16),
              _buildPostStat(Icons.share, post.sharesCount, Colors.green),
              const SizedBox(width: 16),
              _buildPostStat(Icons.visibility, post.viewsCount, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostStat(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
