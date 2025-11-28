import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_item.dart';

class PersonalizedFeedProvider extends ChangeNotifier {
  List<FeedItem> _userFeed = [];
  List<FeedItem> _adminFeed = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _userBehavior = {};
  Map<String, dynamic> _feedAnalytics = {};
  
  // OpenRouter AI Configuration
  static const String _openRouterApiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  // TODO: Move this to environment variables or secure configuration
  static const String _apiKey = '';
  static const String _selectedModel = 'mistralai/mistral-7b-instruct:free';

  // Getters
  List<FeedItem> get userFeed => _userFeed;
  List<FeedItem> get adminFeed => _adminFeed;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get userBehavior => _userBehavior;
  Map<String, dynamic> get feedAnalytics => _feedAnalytics;

  PersonalizedFeedProvider() {
    loadUserBehavior();
    generateUserFeed();
    generateAdminFeed();
  }

  // Generate AI response for feed content
  Future<String> _getAIResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_openRouterApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': _selectedModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an AI assistant that generates personalized feed content for e-commerce platforms. Create engaging, relevant content in JSON format.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
          'stream': false
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'].toString().trim();
        }
      }
    } catch (e) {
      debugPrint('AI Feed API Exception: $e');
    }
    return '';
  }

  // Load user behavior data
  Future<void> loadUserBehavior() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final behaviorJson = prefs.getString('user_behavior');
      
      if (behaviorJson != null) {
        _userBehavior = json.decode(behaviorJson);
      } else {
        _userBehavior = _getDefaultUserBehavior();
        await saveUserBehavior();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user behavior: $e');
    }
  }

  // Save user behavior data
  Future<void> saveUserBehavior() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_behavior', json.encode(_userBehavior));
    } catch (e) {
      debugPrint('Error saving user behavior: $e');
    }
  }

  // Generate personalized user feed
  Future<void> generateUserFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userPrompt = '''
Based on this user behavior data, generate a personalized feed of 10 items for a shopping app user:

User Behavior:
- Browse Categories: ${_userBehavior['browseCategories'] ?? 'Electronics, Fashion'}
- Purchase History: ${_userBehavior['purchaseHistory'] ?? 'Smartphones, Clothing'}
- Wishlist Items: ${_userBehavior['wishlistItems'] ?? 'Laptops, Shoes'}
- Time of Day: ${DateTime.now().hour < 12 ? 'Morning' : DateTime.now().hour < 18 ? 'Afternoon' : 'Evening'}
- Recent Searches: ${_userBehavior['recentSearches'] ?? 'Gaming laptop, Winter jacket'}
- Price Range: \$${_userBehavior['minPrice'] ?? 10} - \$${_userBehavior['maxPrice'] ?? 500}

Generate a JSON array of personalized feed items with different types:
{
  "id": "unique_id",
  "type": "product_recommendation|trending_deal|personalized_offer|category_spotlight|seasonal_content|flash_sale|new_arrival|review_prompt|wishlist_reminder|restock_alert",
  "title": "engaging_title",
  "description": "personalized_description",
  "imageUrl": "https://example.com/image.jpg",
  "actionText": "button_text",
  "priority": 1-10,
  "data": {
    "productId": "optional_product_id",
    "discount": "optional_discount_percentage",
    "category": "relevant_category",
    "price": "optional_price"
  },
  "timestamp": "${DateTime.now().toIso8601String()}"
}

Make sure the content is highly personalized and engaging for this specific user profile.
''';

      final aiResponse = await _getAIResponse(userPrompt);
      
      if (aiResponse.isNotEmpty) {
        _userFeed = _parseFeedItems(aiResponse);
      } else {
        _userFeed = _getFallbackUserFeed();
      }

      // Update analytics
      _updateFeedAnalytics('user_feed_generated', _userFeed.length);
      
    } catch (e) {
      _error = 'Failed to generate user feed: $e';
      debugPrint(_error);
      _userFeed = _getFallbackUserFeed();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate AI-powered admin feed
  Future<void> generateAdminFeed() async {
    try {
      final adminPrompt = '''
Generate an admin dashboard feed with 15 AI-powered insights for an e-commerce platform:

Current Date: ${DateTime.now().toIso8601String()}
Platform Metrics:
- Total Users: ${_getRandomMetric(1000, 10000)}
- Daily Active Users: ${_getRandomMetric(500, 5000)}
- Total Products: ${_getRandomMetric(100, 1000)}
- Today's Orders: ${_getRandomMetric(50, 500)}
- Revenue Today: \$${_getRandomMetric(1000, 10000)}

Generate a JSON array of admin feed items:
{
  "id": "unique_id",
  "type": "sales_insight|user_behavior_alert|inventory_warning|performance_metric|trend_analysis|security_alert|system_status|recommendation_success|customer_feedback|revenue_spike|marketing_opportunity|competitor_analysis|seasonal_prediction|ai_suggestion|urgent_action",
  "title": "admin_focused_title",
  "description": "detailed_business_insight",
  "severity": "low|medium|high|critical",
  "category": "sales|inventory|users|security|performance|marketing|ai_insights",
  "value": "metric_value_or_percentage",
  "trend": "up|down|stable",
  "actionRequired": true/false,
  "timestamp": "${DateTime.now().toIso8601String()}",
  "data": {
    "metric": "specific_metric_name",
    "change": "percentage_change",
    "recommendation": "ai_recommendation"
  }
}

Focus on actionable insights, performance metrics, and AI-powered business recommendations.
''';

      final aiResponse = await _getAIResponse(adminPrompt);
      
      if (aiResponse.isNotEmpty) {
        _adminFeed = _parseFeedItems(aiResponse);
      } else {
        _adminFeed = _getFallbackAdminFeed();
      }

      // Update analytics
      _updateFeedAnalytics('admin_feed_generated', _adminFeed.length);
      
    } catch (e) {
      debugPrint('Error generating admin feed: $e');
      _adminFeed = _getFallbackAdminFeed();
    }
  }

  // Parse feed items from AI response
  List<FeedItem> _parseFeedItems(String aiResponse) {
    try {
      // Extract JSON from AI response
      String jsonStr = aiResponse;
      
      // Find JSON array in the response
      int startIndex = jsonStr.indexOf('[');
      int endIndex = jsonStr.lastIndexOf(']');
      
      if (startIndex != -1 && endIndex != -1) {
        jsonStr = jsonStr.substring(startIndex, endIndex + 1);
        
        final List<dynamic> jsonList = json.decode(jsonStr);
        
        return jsonList.map((item) {
          return FeedItem.fromJson(item);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error parsing feed items: $e');
    }
    
    return [];
  }

  // Track user interaction with feed items
  Future<void> trackFeedInteraction(String feedItemId, String action) async {
    try {
      // Update user behavior based on interaction
      _userBehavior['feedInteractions'] = _userBehavior['feedInteractions'] ?? [];
      _userBehavior['feedInteractions'].add({
        'feedItemId': feedItemId,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update analytics
      _updateFeedAnalytics('interaction_$action', 1);
      
      await saveUserBehavior();
      
      // Regenerate feed based on new behavior
      if (action == 'liked' || action == 'purchased' || action == 'shared') {
        await generateUserFeed();
      }
      
    } catch (e) {
      debugPrint('Error tracking feed interaction: $e');
    }
  }

  // Update user behavior based on app usage
  Future<void> updateUserBehavior(Map<String, dynamic> newBehavior) async {
    _userBehavior.addAll(newBehavior);
    await saveUserBehavior();
    
    // Regenerate personalized feed with new behavior
    await generateUserFeed();
  }

  // Refresh both feeds
  Future<void> refreshFeeds() async {
    await Future.wait([
      generateUserFeed(),
      generateAdminFeed(),
    ]);
  }

  // Get feed item by ID
  FeedItem? getFeedItemById(String id) {
    try {
      return _userFeed.firstWhere((item) => item.id == id);
    } catch (e) {
      try {
        return _adminFeed.firstWhere((item) => item.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Update feed analytics
  void _updateFeedAnalytics(String metric, dynamic value) {
    _feedAnalytics[metric] = (_feedAnalytics[metric] ?? 0) + value;
    _feedAnalytics['lastUpdated'] = DateTime.now().toIso8601String();
  }

  // Get random metric for demo purposes
  int _getRandomMetric(int min, int max) {
    return min + DateTime.now().millisecond % (max - min);
  }

  // Default user behavior for new users
  Map<String, dynamic> _getDefaultUserBehavior() {
    return {
      'browseCategories': ['Electronics', 'Fashion', 'Home'],
      'purchaseHistory': [],
      'wishlistItems': [],
      'recentSearches': [],
      'feedInteractions': [],
      'minPrice': 0,
      'maxPrice': 500,
      'preferredBrands': [],
      'lastActive': DateTime.now().toIso8601String(),
    };
  }

  // Fallback user feed
  List<FeedItem> _getFallbackUserFeed() {
    return [
      FeedItem(
        id: 'user_fallback_1',
        type: 'product_recommendation',
        title: '🔥 Hot Deal: Wireless Earbuds',
        description: 'Based on your interest in electronics, check out these trending wireless earbuds with 50% off!',
        imageUrl: 'https://via.placeholder.com/300x200',
        actionText: 'View Deal',
        priority: 9,
        timestamp: DateTime.now(),
        data: {
          'productId': 'earbuds_001',
          'discount': '50',
          'category': 'Electronics',
          'price': '49.99'
        },
      ),
      FeedItem(
        id: 'user_fallback_2',
        type: 'personalized_offer',
        title: '💝 Special Offer Just for You',
        description: 'Get 20% off your next purchase in your favorite categories!',
        imageUrl: 'https://via.placeholder.com/300x200',
        actionText: 'Claim Offer',
        priority: 8,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        data: {
          'discount': '20',
          'category': 'All',
          'validUntil': DateTime.now().add(const Duration(days: 3)).toIso8601String()
        },
      ),
    ];
  }

  // Fallback admin feed
  List<FeedItem> _getFallbackAdminFeed() {
    return [
      FeedItem(
        id: 'admin_fallback_1',
        type: 'sales_insight',
        title: '📈 Sales Spike Detected',
        description: 'Electronics category showing 25% increase in sales compared to last week',
        imageUrl: 'https://via.placeholder.com/300x200',
        actionText: 'View Details',
        priority: 8,
        timestamp: DateTime.now(),
        severity: 'medium',
        category: 'sales',
        value: '+25%',
        trend: 'up',
        actionRequired: false,
        data: {
          'metric': 'category_sales',
          'change': '+25%',
          'recommendation': 'Consider increasing inventory for electronics'
        },
      ),
      FeedItem(
        id: 'admin_fallback_2',
        type: 'user_behavior_alert',
        title: '👥 User Engagement Up',
        description: 'Daily active users increased by 15% - AI recommendations working well',
        imageUrl: 'https://via.placeholder.com/300x200',
        actionText: 'Analyze',
        priority: 7,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        severity: 'low',
        category: 'users',
        value: '+15%',
        trend: 'up',
        actionRequired: false,
        data: {
          'metric': 'daily_active_users',
          'change': '+15%',
          'recommendation': 'Continue current AI recommendation strategy'
        },
      ),
    ];
  }
}