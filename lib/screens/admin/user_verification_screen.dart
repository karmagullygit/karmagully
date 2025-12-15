import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/social_feed_provider.dart';

class UserVerificationScreen extends StatefulWidget {
  const UserVerificationScreen({super.key});

  @override
  State<UserVerificationScreen> createState() => _UserVerificationScreenState();
}

class _UserVerificationScreenState extends State<UserVerificationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserInfo> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    // Get unique users from social feed posts
    final socialProvider = Provider.of<SocialFeedProvider>(context, listen: false);
    final Map<String, UserInfo> uniqueUsers = {};

    for (var post in socialProvider.posts) {
      if (!uniqueUsers.containsKey(post.userId)) {
        uniqueUsers[post.userId] = UserInfo(
          userId: post.userId,
          username: post.username,
          displayName: post.userDisplayName ?? post.username,
          avatar: post.userAvatar,
          isVerified: post.isVerified,
          karmaId: 'KM${post.userId.length >= 8 ? post.userId.substring(0, 8).toUpperCase() : post.userId.toUpperCase()}',
        );
      }
    }

    if (!mounted) return;
    
    setState(() {
      _users = uniqueUsers.values.toList();
      _isLoading = false;
    });
  }

  List<UserInfo> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;

    return _users.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.username.toLowerCase().contains(query) ||
          user.displayName.toLowerCase().contains(query) ||
          user.karmaId.toLowerCase().contains(query) ||
          user.userId.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleVerification(UserInfo user) async {
    final socialProvider = Provider.of<SocialFeedProvider>(context, listen: false);
    
    // Update verification status for all posts by this user
    socialProvider.toggleUserVerification(user.userId, !user.isVerified);

    // Update local user list
    if (!mounted) return;
    
    setState(() {
      final index = _users.indexWhere((u) => u.userId == user.userId);
      if (index != -1) {
        _users[index] = user.copyWith(isVerified: !user.isVerified);
      }
    });

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user.isVerified 
            ? '${user.displayName} unverified' 
            : '${user.displayName} verified ✓',
        ),
        backgroundColor: user.isVerified ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27),
        title: const Text('User Verification'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name, username, or Karma ID...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1F3A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filteredUsers.length} users',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_filteredUsers.where((u) => u.isVerified).length} verified',
                  style: const TextStyle(
                    color: Color(0xFF1D9BF0),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF818CF8),
                    ),
                  )
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No users found'
                                  : 'No users match "$_searchQuery"',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserInfo user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.isVerified 
            ? const Color(0xFF1D9BF0).withOpacity(0.3)
            : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF818CF8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              user.avatar,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                user.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified,
                color: Color(0xFF1D9BF0),
                size: 18,
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${user.username}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Karma ID: ${user.karmaId}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: user.isVerified,
          onChanged: (value) => _toggleVerification(user),
          activeColor: const Color(0xFF1D9BF0),
          activeTrackColor: const Color(0xFF1D9BF0).withOpacity(0.5),
        ),
      ),
    );
  }
}

class UserInfo {
  final String userId;
  final String username;
  final String displayName;
  final String avatar;
  final bool isVerified;
  final String karmaId;

  UserInfo({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.avatar,
    required this.isVerified,
    required this.karmaId,
  });

  UserInfo copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? avatar,
    bool? isVerified,
    String? karmaId,
  }) {
    return UserInfo(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      karmaId: karmaId ?? this.karmaId,
    );
  }
}
