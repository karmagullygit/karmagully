import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/user_management_provider.dart';
import '../../providers/social_feed_provider.dart';
import '../../models/user.dart';
import '../../models/social_post.dart';

class AdminUserManagementScreen extends StatefulWidget {
  final String? searchKarmaId;
  
  const AdminUserManagementScreen({super.key, this.searchKarmaId});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Pre-fill search if Karma ID is provided
    if (widget.searchKarmaId != null) {
      _searchController.text = widget.searchKarmaId!;
      _searchQuery = widget.searchKarmaId!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C1F26),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Active'),
            Tab(text: 'Banned'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(null),
                _buildUserList(false), // Not banned = active
                _buildUserList(true),  // Banned users
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by Karma ID or name...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.purple),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF0A0E21),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildUserList(bool? bannedFilter) {
    return Consumer2<UserManagementProvider, SocialFeedProvider>(
      builder: (context, userProvider, feedProvider, child) {
        List<User> users;
        
        if (_searchQuery.isNotEmpty) {
          users = userProvider.searchUsers(_searchQuery);
        } else {
          users = userProvider.users;
        }

        // Apply banned filter
        if (bannedFilter != null) {
          users = users.where((u) => u.isBanned == bannedFilter).toList();
        }

        // Sort: most recent first
        users.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty ? 'No users found' : 'No users yet',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final stats = userProvider.getUserStats(user.karmaId);
            final userPosts = feedProvider.posts.where((p) => p.userId == user.id).toList();
            
            return _buildUserCard(user, stats, userPosts.length, feedProvider);
          },
        );
      },
    );
  }

  Widget _buildUserCard(User user, Map<String, dynamic> stats, int postCount, SocialFeedProvider feedProvider) {
    final isAdmin = user.role == UserRole.admin;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1C1F26),
        border: Border.all(
          color: user.isBanned 
              ? Colors.red.withOpacity(0.3) 
              : Colors.white.withOpacity(0.1),
          width: user.isBanned ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isAdmin ? Colors.purple : Colors.blue,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (user.isBanned)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.block,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: user.karmaId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied ${user.karmaId}'),
                        backgroundColor: Colors.purple,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint, size: 14, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        user.karmaId,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip(Icons.article, '$postCount posts', Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.calendar_today,
                      '${stats['daysSinceJoined']} days',
                      Colors.green,
                    ),
                  ],
                ),
                if (user.isBanned) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BANNED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              if (user.banReason != null)
                                Text(
                                  user.banReason!,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isAdmin)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showUserPostsDialog(context, user, feedProvider),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Posts'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showDeletePostsDialog(context, user, feedProvider),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete Posts'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showBanDialog(context, user),
                      icon: Icon(
                        user.isBanned ? Icons.check_circle : Icons.block,
                        size: 18,
                      ),
                      label: Text(user.isBanned ? 'Unban' : 'Ban'),
                      style: TextButton.styleFrom(
                        foregroundColor: user.isBanned ? Colors.green : Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserPostsDialog(BuildContext context, User user, SocialFeedProvider feedProvider) {
    final userPosts = feedProvider.posts.where((p) => p.userId == user.id).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: Row(
          children: [
            const Icon(Icons.article, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${user.name}\'s Posts',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: userPosts.isEmpty
              ? const Center(
                  child: Text(
                    'No posts yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: userPosts.length,
                  itemBuilder: (context, index) {
                    final post = userPosts[index];
                    return Card(
                      color: const Color(0xFF0A0E21),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          post.type == PostType.video 
                              ? Icons.video_library 
                              : post.type == PostType.image 
                                  ? Icons.image 
                                  : Icons.text_fields,
                          color: Colors.purple,
                        ),
                        title: Text(
                          post.content.length > 50 
                              ? '${post.content.substring(0, 50)}...' 
                              : post.content,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        subtitle: Text(
                          '${post.likesCount} likes • ${post.commentsCount} comments',
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () {
                            Navigator.pop(context);
                            _deletePost(context, post.id, feedProvider);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _showDeletePostsDialog(BuildContext context, User user, SocialFeedProvider feedProvider) {
    final userPosts = feedProvider.posts.where((p) => p.userId == user.id).toList();
    
    if (userPosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User has no posts to delete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete User Posts', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete all posts from ${user.name}?',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Karma ID: ${user.karmaId}',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${userPosts.length} post(s) will be permanently deleted',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllUserPosts(context, user, feedProvider);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Delete All Posts'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(BuildContext context, User user) {
    final TextEditingController reasonController = TextEditingController();
    final userProvider = Provider.of<UserManagementProvider>(context, listen: false);

    if (user.isBanned) {
      // Unban user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C1F26),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Unban User', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unban ${user.name}?',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karma ID: ${user.karmaId}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'User will regain access to community feed',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                await userProvider.unbanUser(user.karmaId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.name} has been unbanned'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Unban User'),
            ),
          ],
        ),
      );
    } else {
      // Ban user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C1F26),
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Text('Ban User', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ban ${user.name}?',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karma ID: ${user.karmaId}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'User will be blocked from community feed',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ban Reason *',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Enter reason for banning...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF0A0E21),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a ban reason'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                await userProvider.banUser(user.karmaId, reasonController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.name} has been banned'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ban User'),
            ),
          ],
        ),
      );
    }
  }

  void _deletePost(BuildContext context, String postId, SocialFeedProvider feedProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Delete Post', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this post?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await feedProvider.deletePost(postId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAllUserPosts(BuildContext context, User user, SocialFeedProvider feedProvider) async {
    final userPosts = feedProvider.posts.where((p) => p.userId == user.id).toList();
    
    for (final post in userPosts) {
      await feedProvider.deletePost(post.id);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${userPosts.length} post(s) from ${user.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
