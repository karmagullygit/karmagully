import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/user_preference.dart';
import '../models/ai_recommendation_config.dart';

class RecommendationProvider extends ChangeNotifier {
  List<Product> _recommendedProducts = [];
  List<Product> _trendingProducts = [];
  List<Product> _personalizedProducts = [];
  UserPreference? _userPreference;
  AIRecommendationConfig _config = AIRecommendationConfig.defaultConfig();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get recommendedProducts => _recommendedProducts;
  List<Product> get trendingProducts => _trendingProducts;
  List<Product> get personalizedProducts => _personalizedProducts;
  UserPreference? get userPreference => _userPreference;
  AIRecommendationConfig get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RecommendationProvider() {
    loadUserPreferences();
    loadAIConfig();
  }

  // Load user preferences from local storage
  Future<void> loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefJson = prefs.getString('user_preferences');
      
      if (prefJson != null) {
        _userPreference = UserPreference.fromJson(json.decode(prefJson));
      } else {
        // Initialize with default preferences
        _userPreference = UserPreference.defaultPreferences();
        await saveUserPreferences();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  // Save user preferences to local storage
  Future<void> saveUserPreferences() async {
    try {
      if (_userPreference != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_preferences', json.encode(_userPreference!.toJson()));
      }
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
    }
  }

  // Load AI recommendation configuration
  Future<void> loadAIConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('ai_recommendation_config');
      
      if (configJson != null) {
        _config = AIRecommendationConfig.fromJson(json.decode(configJson));
      } else {
        // Initialize with default config
        _config = AIRecommendationConfig.defaultConfig();
        await saveAIConfig();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading AI config: $e');
    }
  }

  // Save AI recommendation configuration
  Future<void> saveAIConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_recommendation_config', json.encode(_config.toJson()));
    } catch (e) {
      debugPrint('Error saving AI config: $e');
    }
  }

  // Update AI recommendation configuration
  Future<void> updateAIConfig(AIRecommendationConfig newConfig) async {
    _config = newConfig.copyWith(lastUpdated: DateTime.now());
    await saveAIConfig();
    notifyListeners();
  }

  // Initialize recommendations with real product data
  void initializeWithProducts(List<Product> products, {List<String>? userOrderHistory}) {
    if (products.isNotEmpty) {
      generateRecommendationsFromRealProducts(products, userOrderHistory: userOrderHistory);
    }
  }

  // Generate recommendations from real products in the store
  void generateRecommendationsFromRealProducts(List<Product> products, {List<String>? userOrderHistory}) {
    if (products.isEmpty) {
      debugPrint('No products available for recommendations');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Generate trending products (based on ratings and popularity)
      _trendingProducts = _generateTrendingProducts(products);

      // Generate recommended products based on user behavior and orders
      _recommendedProducts = _generateBehaviorBasedRecommendations(products, userOrderHistory ?? []);

      // Generate personalized recommendations
      _personalizedProducts = _generatePersonalizedRecommendations(products, userOrderHistory ?? []);

      debugPrint('Generated recommendations from ${products.length} real products');
      debugPrint('User order history: ${userOrderHistory?.length ?? 0} products');
      debugPrint('Trending: ${_trendingProducts.length}, Recommended: ${_recommendedProducts.length}, Personalized: ${_personalizedProducts.length}');

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to generate recommendations: $e';
      _isLoading = false;
      debugPrint('Error generating recommendations: $e');
      notifyListeners();
    }
  }

  // Generate trending products based on stock and newness
  List<Product> _generateTrendingProducts(List<Product> products) {
    // Sort by newest first and filter available products
    var sortedProducts = products.where((p) => p.stock > 0 && p.isActive).toList();
    sortedProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedProducts.take(10).toList();
  }

  // Generate behavior-based recommendations using order history
  List<Product> _generateBehaviorBasedRecommendations(List<Product> products, List<String> userOrderHistory) {
    List<Product> recommendations = [];
    
    debugPrint('=== AI Recommendation Debug ===');
    debugPrint('Total products: ${products.length}');
    debugPrint('User order history: ${userOrderHistory.length} items');
    debugPrint('Order history products: ${userOrderHistory.join(", ")}');
    
    if (userOrderHistory.isEmpty) {
      debugPrint('No order history - showing category-based recommendations');
      // For new users, recommend products from different categories
      Map<String, List<Product>> categoryGroups = {};
      for (var product in products.where((p) => p.stock > 0 && p.isActive)) {
        categoryGroups[product.category] = categoryGroups[product.category] ?? [];
        categoryGroups[product.category]!.add(product);
      }

      // Add newest products from each category
      for (var categoryProducts in categoryGroups.values) {
        categoryProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        recommendations.addAll(categoryProducts.take(2));
      }
    } else {
      debugPrint('Has order history - generating behavior-based recommendations');
      // Get categories from user's purchase history
      Set<String> purchasedCategories = {};
      for (String productId in userOrderHistory) {
        var purchasedProduct = products.firstWhere(
          (p) => p.id == productId, 
          orElse: () => Product(
            id: '', name: '', price: 0, category: '', 
            description: '', stock: 0, createdAt: DateTime.now()
          )
        );
        if (purchasedProduct.id.isNotEmpty) {
          purchasedCategories.add(purchasedProduct.category);
          debugPrint('Found purchased product: ${purchasedProduct.name} in category: ${purchasedProduct.category}');
        } else {
          debugPrint('Product not found for ID: $productId');
        }
      }

      debugPrint('Purchased categories: ${purchasedCategories.join(", ")}');

      // Recommend similar products from purchased categories
      for (String category in purchasedCategories) {
        var categoryProducts = products
            .where((p) => p.category == category && 
                         !userOrderHistory.contains(p.id) && 
                         p.stock > 0 && p.isActive)
            .toList();
        categoryProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        debugPrint('Found ${categoryProducts.length} products in category: $category');
        recommendations.addAll(categoryProducts.take(3));
      }

      debugPrint('Recommendations from purchased categories: ${recommendations.length}');

      // Add complementary products (different categories)
      if (recommendations.length < 8) {
        var otherCategories = products
            .where((p) => !purchasedCategories.contains(p.category) && 
                         !userOrderHistory.contains(p.id) && 
                         p.stock > 0 && p.isActive)
            .toList();
        otherCategories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        int needed = 8 - recommendations.length;
        recommendations.addAll(otherCategories.take(needed));
        debugPrint('Added ${otherCategories.take(needed).length} complementary products');
      }

      debugPrint('Total recommendations after adding complementary: ${recommendations.length}');

      // If still not enough, include some "buy again" suggestions
      if (recommendations.length < 5) {
        var buyAgainProducts = products
            .where((p) => userOrderHistory.contains(p.id) && 
                         p.stock > 0 && p.isActive)
            .toList();
        buyAgainProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        int needed = 5 - recommendations.length;
        recommendations.addAll(buyAgainProducts.take(needed));
        debugPrint('Added ${buyAgainProducts.take(needed).length} "buy again" products');
      }
    }

    final finalRecommendations = recommendations.take(10).toList();
    debugPrint('Final recommendations: ${finalRecommendations.map((p) => '${p.name} (${p.category})').join(", ")}');
    debugPrint('=== End AI Recommendation Debug ===');
    
    return finalRecommendations;
  }

  // Generate personalized recommendations based on user preferences and order history
  List<Product> _generatePersonalizedRecommendations(List<Product> products, List<String> userOrderHistory) {
    if (_userPreference == null) {
      // For users without preferences, recommend newest available products
      var availableProducts = products.where((p) => p.stock > 0 && p.isActive).toList();
      availableProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return availableProducts.take(8).toList();
    }

    List<Product> personalized = [];

    // Filter by preferred categories, excluding already purchased items
    for (String category in _userPreference!.favoriteCategories) {
      var categoryProducts = products.where((p) => 
        p.category.toLowerCase().contains(category.toLowerCase()) &&
        !userOrderHistory.contains(p.id) &&
        p.stock > 0 && p.isActive).toList();
      categoryProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      personalized.addAll(categoryProducts.take(2));
    }

    // Add products within preferred price range, excluding purchased items
    var priceFilteredProducts = products.where((p) => 
      p.price >= _userPreference!.minPrice && 
      p.price <= _userPreference!.maxPrice &&
      !userOrderHistory.contains(p.id) &&
      p.stock > 0 && p.isActive).toList();
    priceFilteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    personalized.addAll(priceFilteredProducts.take(3));

    // Remove duplicates and limit to 8 products
    personalized = personalized.toSet().toList();
    return personalized.take(8).toList();
  }

  // Update product tracking with actual behavior
  void updateProductInteraction(String productId, String category) {
    if (_userPreference != null) {
      // Update category interactions
      _userPreference!.categoryInteractions[category] = 
          (_userPreference!.categoryInteractions[category] ?? 0) + 1;
      
      // Track product view
      _userPreference!.productViews[productId] = DateTime.now();
      
      // Update last updated time
      _userPreference!.lastUpdated = DateTime.now();
      
      saveUserPreferences();
      notifyListeners();
    }
  }

  // Add to purchase history when user actually makes a purchase
  void addToPurchaseHistory(String productId) {
    if (_userPreference != null) {
      _userPreference!.purchaseHistory.add(productId);
      _userPreference!.lastUpdated = DateTime.now();
      saveUserPreferences();
      notifyListeners();
    }
  }

  // Generate recommendations without external AI calls
  Future<void> generatePersonalizedRecommendations(List<Product> allProducts, {List<String>? userOrderHistory}) async {
    if (allProducts.isEmpty) {
      debugPrint('No products available for personalized recommendations');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _personalizedProducts = _generatePersonalizedRecommendations(allProducts, userOrderHistory ?? []);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to generate personalized recommendations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user has made any orders (for showing AI recommendations)
  bool hasUserMadeOrders(List<String> userOrderHistory) {
    return userOrderHistory.isNotEmpty;
  }

  // Get user's ordered product IDs from their purchase history
  List<String> getUserOrderHistory() {
    return _userPreference?.purchaseHistory ?? [];
  }

  // Update user preferences
  void updateUserPreferences(UserPreference newPreferences) {
    _userPreference = newPreferences;
    saveUserPreferences();
    notifyListeners();
  }

  // Add to recent searches
  void addToRecentSearches(String searchTerm) {
    if (_userPreference != null && searchTerm.isNotEmpty) {
      _userPreference!.recentSearches.remove(searchTerm); // Remove if exists
      _userPreference!.recentSearches.insert(0, searchTerm); // Add to front
      
      // Keep only last 10 searches
      if (_userPreference!.recentSearches.length > 10) {
        _userPreference!.recentSearches = _userPreference!.recentSearches.take(10).toList();
      }
      
      _userPreference!.lastUpdated = DateTime.now();
      saveUserPreferences();
      notifyListeners();
    }
  }

  // Clear all recommendations
  void clearRecommendations() {
    _recommendedProducts.clear();
    _trendingProducts.clear();
    _personalizedProducts.clear();
    _error = null;
    notifyListeners();
  }

  // Refresh recommendations with new product data
  void refreshRecommendations(List<Product> products) {
    generateRecommendationsFromRealProducts(products);
  }

  // Generate initial recommendations - for backward compatibility
  void generateInitialRecommendations() {
    // This method can be called when products are not yet available
    // The actual recommendations will be generated when products are loaded
    debugPrint('Initial recommendations will be generated when products are loaded');
  }

  // Track user interaction with products
  void trackUserInteraction(String productId, String interactionType) {
    if (_userPreference != null) {
      // Update interaction count
      String key = '${productId}_$interactionType';
      _userPreference!.categoryInteractions[key] = 
          (_userPreference!.categoryInteractions[key] ?? 0) + 1;
      
      // Track product view with timestamp
      _userPreference!.productViews[productId] = DateTime.now();
      
      // Update last updated time
      _userPreference!.lastUpdated = DateTime.now();
      
      saveUserPreferences();
      notifyListeners();
      
      debugPrint('Tracked $interactionType interaction for product $productId');
    }
  }
}