import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/social_post.dart';
import '../models/post_comment.dart';
import '../models/story.dart';

class SocialFeedProvider extends ChangeNotifier {
  List<SocialPost> _posts = [];
  List<Story> _stories = [];
  Map<String, List<CommentThread>> _postComments = {};
  bool _isLoading = false;
  String? _error;
  String _currentUserId = 'user_1';
  String _currentUsername = 'You';
  String _currentUserAvatar = '👤';


  // Getters
  List<SocialPost> get posts => _posts;
  List<Story> get stories {
    // Filter out expired stories
    return _stories.where((story) => !story.isExpired).toList();
  }
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentUserId => _currentUserId;
  String get currentUsername => _currentUsername;

  List<CommentThread> getPostComments(String postId) {
    return _postComments[postId] ?? [];
  }

  SocialFeedProvider() {
    _loadSampleData();
    loadPosts();
    loadStories();
  }

  // Load posts from local storage
  Future<void> loadPosts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getString('social_posts');
      final commentsJson = prefs.getString('post_comments');

      if (postsJson != null) {
        final List<dynamic> decoded = json.decode(postsJson);
        _posts = decoded.map((item) => SocialPost.fromJson(item)).toList();
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      if (commentsJson != null) {
        final Map<String, dynamic> decoded = json.decode(commentsJson);
        _postComments = decoded.map((key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((item) => CommentThread.fromJson(item))
              .toList(),
        ));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load posts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save posts to local storage
  Future<void> _savePosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = json.encode(_posts.map((post) => post.toJson()).toList());
      final commentsJson = json.encode(_postComments.map((key, value) => MapEntry(
        key,
        value.map((thread) => thread.toJson()).toList(),
      )));
      
      await prefs.setString('social_posts', postsJson);
      await prefs.setString('post_comments', commentsJson);
    } catch (e) {
      debugPrint('Error saving posts: $e');
    }
  }

  // Load stories from local storage
  Future<void> loadStories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storiesJson = prefs.getString('user_stories');

      if (storiesJson != null) {
        final List<dynamic> decoded = json.decode(storiesJson);
        _stories = decoded.map((item) => Story.fromJson(item)).toList();
        // Remove expired stories
        _stories.removeWhere((story) => story.isExpired);
        await _saveStories(); // Clean up expired stories from storage
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stories: $e');
    }
  }

  // Save stories to local storage
  Future<void> _saveStories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storiesJson = json.encode(_stories.map((story) => story.toJson()).toList());
      await prefs.setString('user_stories', storiesJson);
    } catch (e) {
      debugPrint('Error saving stories: $e');
    }
  }

  // Create a new story
  Future<void> createStory({
    required String mediaUrl,
    required String type,
    String caption = '',
  }) async {
    try {
      final now = DateTime.now();
      final newStory = Story(
        id: 'story_${now.millisecondsSinceEpoch}',
        userId: _currentUserId,
        userName: _currentUsername,
        userAvatar: _currentUserAvatar,
        mediaUrl: mediaUrl,
        type: type,
        caption: caption,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );

      _stories.insert(0, newStory);
      await _saveStories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating story: $e');
      throw Exception('Failed to create story');
    }
  }

  // Create a new post
  Future<void> createPost({
    required String content,
    PostType type = PostType.text,
    List<String> mediaUrls = const [],
    List<String> tags = const [],
    String? location,
    PostPrivacy privacy = PostPrivacy.public,
  }) async {
    try {
      final newPost = SocialPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId,
        username: _currentUsername,
        userAvatar: _currentUserAvatar,
        userDisplayName: 'Your Name',
        content: content,
        type: type,
        mediaUrls: mediaUrls,
        tags: tags,
        location: location,
        privacy: privacy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _posts.insert(0, newPost);
      notifyListeners();
      await _savePosts();
    } catch (e) {
      _error = 'Failed to create post: $e';
      notifyListeners();
    }
  }

  // Like/unlike a post
  Future<void> toggleLike(String postId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final isLiked = post.isLikedBy(_currentUserId);
    final isDisliked = post.isDislikedBy(_currentUserId);

    List<String> newLikedBy = List.from(post.likedBy);
    List<String> newDislikedBy = List.from(post.dislikedBy);
    int newLikesCount = post.likesCount;
    int newDislikesCount = post.dislikesCount;

    if (isLiked) {
      // Unlike
      newLikedBy.remove(_currentUserId);
      newLikesCount--;
    } else {
      // Like
      newLikedBy.add(_currentUserId);
      newLikesCount++;
      
      // Remove dislike if present
      if (isDisliked) {
        newDislikedBy.remove(_currentUserId);
        newDislikesCount--;
      }
    }

    _posts[postIndex] = post.copyWith(
      likedBy: newLikedBy,
      dislikedBy: newDislikedBy,
      likesCount: newLikesCount,
      dislikesCount: newDislikesCount,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
    await _savePosts();
  }

  // Dislike/undislike a post
  Future<void> toggleDislike(String postId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final isLiked = post.isLikedBy(_currentUserId);
    final isDisliked = post.isDislikedBy(_currentUserId);

    List<String> newLikedBy = List.from(post.likedBy);
    List<String> newDislikedBy = List.from(post.dislikedBy);
    int newLikesCount = post.likesCount;
    int newDislikesCount = post.dislikesCount;

    if (isDisliked) {
      // Undislike
      newDislikedBy.remove(_currentUserId);
      newDislikesCount--;
    } else {
      // Dislike
      newDislikedBy.add(_currentUserId);
      newDislikesCount++;
      
      // Remove like if present
      if (isLiked) {
        newLikedBy.remove(_currentUserId);
        newLikesCount--;
      }
    }

    _posts[postIndex] = post.copyWith(
      likedBy: newLikedBy,
      dislikedBy: newDislikedBy,
      likesCount: newLikesCount,
      dislikesCount: newDislikesCount,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
    await _savePosts();
  }

  // Add a comment to a post
  Future<void> addComment(String postId, String content, {String? parentCommentId}) async {
    try {
      final newComment = PostComment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        userId: _currentUserId,
        username: _currentUsername,
        userAvatar: _currentUserAvatar,
        userDisplayName: 'Your Name',
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentCommentId: parentCommentId,
      );

      if (!_postComments.containsKey(postId)) {
        _postComments[postId] = [];
      }

      if (parentCommentId == null) {
        // Main comment
        _postComments[postId]!.add(CommentThread(comment: newComment));
      } else {
        // Reply to existing comment
        final threadIndex = _postComments[postId]!.indexWhere(
          (thread) => thread.comment.id == parentCommentId,
        );
        if (threadIndex != -1) {
          final thread = _postComments[postId]![threadIndex];
          _postComments[postId]![threadIndex] = thread.copyWith(
            replies: [...thread.replies, newComment],
          );
          
          // Update parent comment reply count
          _postComments[postId]![threadIndex] = thread.copyWith(
            comment: thread.comment.copyWith(
              repliesCount: thread.comment.repliesCount + 1,
            ),
          );
        }
      }

      // Update post comment count
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          commentsCount: _posts[postIndex].commentsCount + 1,
        );
      }

      notifyListeners();
      await _savePosts();
    } catch (e) {
      _error = 'Failed to add comment: $e';
      notifyListeners();
    }
  }

  // Like/unlike a comment
  Future<void> toggleCommentLike(String postId, String commentId) async {
    if (!_postComments.containsKey(postId)) return;

    bool updated = false;
    
    for (int i = 0; i < _postComments[postId]!.length; i++) {
      final thread = _postComments[postId]![i];
      
      // Check main comment
      if (thread.comment.id == commentId) {
        final comment = thread.comment;
        final isLiked = comment.isLikedBy(_currentUserId);
        
        List<String> newLikedBy = List.from(comment.likedBy);
        int newLikesCount = comment.likesCount;
        
        if (isLiked) {
          newLikedBy.remove(_currentUserId);
          newLikesCount--;
        } else {
          newLikedBy.add(_currentUserId);
          newLikesCount++;
        }
        
        _postComments[postId]![i] = thread.copyWith(
          comment: comment.copyWith(
            likedBy: newLikedBy,
            likesCount: newLikesCount,
          ),
        );
        updated = true;
        break;
      }
      
      // Check replies
      for (int j = 0; j < thread.replies.length; j++) {
        if (thread.replies[j].id == commentId) {
          final reply = thread.replies[j];
          final isLiked = reply.isLikedBy(_currentUserId);
          
          List<String> newLikedBy = List.from(reply.likedBy);
          int newLikesCount = reply.likesCount;
          
          if (isLiked) {
            newLikedBy.remove(_currentUserId);
            newLikesCount--;
          } else {
            newLikedBy.add(_currentUserId);
            newLikesCount++;
          }
          
          List<PostComment> newReplies = List.from(thread.replies);
          newReplies[j] = reply.copyWith(
            likedBy: newLikedBy,
            likesCount: newLikesCount,
          );
          
          _postComments[postId]![i] = thread.copyWith(replies: newReplies);
          updated = true;
          break;
        }
      }
      
      if (updated) break;
    }

    if (updated) {
      notifyListeners();
      await _savePosts();
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String postId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    _posts[postIndex] = _posts[postIndex].copyWith(
      viewsCount: _posts[postIndex].viewsCount + 1,
    );

    // Save without notifying listeners to avoid unnecessary rebuilds
    await _savePosts();
  }

  // Refresh feed
  Future<void> refreshFeed() async {
    _generateRandomPost();
    await loadPosts();
  }

  // Generate a random sample post
  void _generateRandomPost() {
    // No sample users or demo posts. This method is now a no-op.
  }

  // Load sample data
  void _loadSampleData() {
    if (_posts.isEmpty) {
      final now = DateTime.now();
      
      _posts = [
        SocialPost(
          id: 'post_1',
          userId: 'user_2',
          username: 'alex_photographer',
          userAvatar: '📸',
          userDisplayName: 'Alex Chen',
          content: 'Just captured this incredible moment! Photography is all about timing and patience. What do you think? 📷✨ #photography #nature #moment',
          type: PostType.text,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
          likesCount: 23,
          commentsCount: 5,
          viewsCount: 156,
          likedBy: ['user_1', 'user_3', 'user_4'],
          tags: ['photography', 'nature', 'moment'],
        ),
        SocialPost(
          id: 'post_2',
          userId: 'user_3',
          username: 'sarah_foodie',
          userAvatar: '🍕',
          userDisplayName: 'Sarah Johnson',
          content: 'Made this delicious homemade pizza tonight! 🍕 The secret is in the dough - let it rise for at least 24 hours. Recipe in comments! #cooking #pizza #homemade',
          type: PostType.text,
          createdAt: now.subtract(const Duration(hours: 4)),
          updatedAt: now.subtract(const Duration(hours: 4)),
          likesCount: 45,
          commentsCount: 12,
          viewsCount: 234,
          likedBy: ['user_1', 'user_2', 'user_4', 'user_5'],
          tags: ['cooking', 'pizza', 'homemade'],
        ),
        SocialPost(
          id: 'post_3',
          userId: 'user_4',
          username: 'mike_traveler',
          userAvatar: '✈️',
          userDisplayName: 'Mike Wilson',
          content: 'Just landed in Tokyo! 🗾 The city is absolutely amazing. Can\'t wait to explore more tomorrow. Any recommendations for must-visit places? #travel #tokyo #japan',
          type: PostType.text,
          createdAt: now.subtract(const Duration(hours: 6)),
          updatedAt: now.subtract(const Duration(hours: 6)),
          likesCount: 67,
          commentsCount: 18,
          viewsCount: 423,
          likedBy: ['user_1', 'user_2', 'user_3', 'user_5', 'user_6'],
          tags: ['travel', 'tokyo', 'japan'],
        ),
      ];

      // Add sample comments
      _postComments = {
        'post_1': [
          CommentThread(
            comment: PostComment(
              id: 'comment_1',
              postId: 'post_1',
              userId: 'user_1',
              username: 'You',
              userAvatar: '👤',
              userDisplayName: 'Your Name',
              content: 'Absolutely stunning! What camera did you use?',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
              updatedAt: now.subtract(const Duration(hours: 1, minutes: 30)),
              likesCount: 3,
              likedBy: ['user_2', 'user_3', 'user_4'],
            ),
            replies: [
              PostComment(
                id: 'comment_1_reply_1',
                postId: 'post_1',
                userId: 'user_2',
                username: 'alex_photographer',
                userAvatar: '📸',
                userDisplayName: 'Alex Chen',
                content: 'Thanks! I used my Canon EOS R5 with a 70-200mm lens 📸',
                createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
                updatedAt: now.subtract(const Duration(hours: 1, minutes: 15)),
                parentCommentId: 'comment_1',
                likesCount: 2,
                likedBy: ['user_1', 'user_3'],
              ),
            ],
          ),
        ],
        'post_2': [
          CommentThread(
            comment: PostComment(
              id: 'comment_2',
              postId: 'post_2',
              userId: 'user_5',
              username: 'emma_artist',
              userAvatar: '🎨',
              userDisplayName: 'Emma Davis',
              content: 'This looks incredible! Could you share the recipe? 😍',
              createdAt: now.subtract(const Duration(hours: 3, minutes: 45)),
              updatedAt: now.subtract(const Duration(hours: 3, minutes: 45)),
              likesCount: 5,
              likedBy: ['user_1', 'user_3', 'user_4', 'user_6', 'user_7'],
            ),
          ),
        ],
      };
    }
  }

  // Set current user (for demo purposes)
  void setCurrentUser(String userId, String username, String avatar) {
    _currentUserId = userId;
    _currentUsername = username;
    _currentUserAvatar = avatar;
    notifyListeners();
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    _posts.removeWhere((post) => post.id == postId);
    _postComments.remove(postId);
    notifyListeners();
    await _savePosts();
  }
}