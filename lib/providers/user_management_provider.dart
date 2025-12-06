import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserManagementProvider with ChangeNotifier {
  List<User> _users = [];
  Map<String, List<String>> _userPosts = {}; // karmaId -> list of post IDs

  List<User> get users => _users;
  List<User> get bannedUsers => _users.where((u) => u.isBanned).toList();
  List<User> get activeUsers => _users.where((u) => !u.isBanned).toList();

  UserManagementProvider() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('all_users');
    final postsJson = prefs.getString('user_posts_map');
    
    if (usersJson != null) {
      final List<dynamic> usersList = json.decode(usersJson);
      _users = usersList.map((json) => User.fromJson(json)).toList();
    } else {
      // Load sample users
      _loadSampleUsers();
    }
    
    if (postsJson != null) {
      final Map<String, dynamic> decoded = json.decode(postsJson);
      _userPosts = decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
    }
    
    notifyListeners();
  }

  void _loadSampleUsers() {
    _users = [
      User(
        id: '1',
        name: 'Admin User',
        email: 'admin@karma.com',
        phone: '+1234567890',
        address: 'Admin Address',
        role: UserRole.admin,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        karmaId: 'karma10000001',
      ),
      User(
        id: '2',
        name: 'Customer User',
        email: 'user@karma.com',
        phone: '+1234567890',
        address: 'Customer Address',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        karmaId: 'karma19812938',
      ),
      User(
        id: 'user_1',
        name: 'John Martinez',
        email: 'john@example.com',
        phone: '+1234567891',
        address: '123 Main St',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        karmaId: 'karma23847561',
      ),
      User(
        id: 'user_2',
        name: 'Emma Wilson',
        email: 'emma@example.com',
        phone: '+1234567892',
        address: '456 Oak Ave',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        karmaId: 'karma45612398',
      ),
      User(
        id: 'user_3',
        name: 'David Chen',
        email: 'david@example.com',
        phone: '+1234567893',
        address: '789 Pine Rd',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        karmaId: 'karma78934562',
      ),
      User(
        id: 'user_4',
        name: 'Lisa Anderson',
        email: 'lisa@example.com',
        phone: '+1234567894',
        address: '321 Elm St',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        karmaId: 'karma12398745',
      ),
      User(
        id: 'user_5',
        name: 'Maria Garcia',
        email: 'maria@example.com',
        phone: '+1234567895',
        address: '654 Maple Dr',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        karmaId: 'karma56789321',
      ),
    ];
    _saveUsers();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(_users.map((u) => u.toJson()).toList());
    await prefs.setString('all_users', usersJson);
    
    final postsJson = json.encode(_userPosts);
    await prefs.setString('user_posts_map', postsJson);
  }

  // Search users by Karma ID or name
  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    final lowerQuery = query.toLowerCase();
    return _users.where((user) {
      return user.karmaId.toLowerCase().contains(lowerQuery) ||
             user.name.toLowerCase().contains(lowerQuery) ||
             user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get user by Karma ID
  User? getUserByKarmaId(String karmaId) {
    try {
      return _users.firstWhere((u) => u.karmaId == karmaId);
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  User? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Ban user
  Future<void> banUser(String karmaId, String reason) async {
    final userIndex = _users.indexWhere((u) => u.karmaId == karmaId);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(
        isBanned: true,
        banReason: reason,
        bannedAt: DateTime.now(),
      );
      await _saveUsers();
      notifyListeners();
    }
  }

  // Unban user
  Future<void> unbanUser(String karmaId) async {
    final userIndex = _users.indexWhere((u) => u.karmaId == karmaId);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(
        isBanned: false,
        banReason: null,
        bannedAt: null,
      );
      await _saveUsers();
      notifyListeners();
    }
  }

  // Track user's posts
  void registerUserPost(String karmaId, String postId) {
    if (!_userPosts.containsKey(karmaId)) {
      _userPosts[karmaId] = [];
    }
    if (!_userPosts[karmaId]!.contains(postId)) {
      _userPosts[karmaId]!.add(postId);
      _saveUsers();
    }
  }

  // Get user's post IDs
  List<String> getUserPostIds(String karmaId) {
    return _userPosts[karmaId] ?? [];
  }

  // Remove post from user's tracking
  void removeUserPost(String karmaId, String postId) {
    if (_userPosts.containsKey(karmaId)) {
      _userPosts[karmaId]!.remove(postId);
      _saveUsers();
    }
  }

  // Get user statistics
  Map<String, dynamic> getUserStats(String karmaId) {
    final user = getUserByKarmaId(karmaId);
    if (user == null) return {};

    final postIds = getUserPostIds(karmaId);
    final daysSinceJoined = DateTime.now().difference(user.createdAt).inDays;

    return {
      'totalPosts': postIds.length,
      'daysSinceJoined': daysSinceJoined,
      'status': user.isBanned ? 'Banned' : 'Active',
      'banReason': user.banReason,
      'bannedAt': user.bannedAt,
    };
  }

  // Add new user (for registration)
  Future<void> addUser(User user) async {
    _users.add(user);
    await _saveUsers();
    notifyListeners();
  }

  // Update user
  Future<void> updateUser(User updatedUser) async {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      await _saveUsers();
      notifyListeners();
    }
  }
}
