class UserPreference {
  List<String> favoriteCategories;
  double minPrice;
  double maxPrice;
  List<String> preferredBrands;
  String shoppingStyle; // 'budget', 'premium', 'trendy', 'practical'
  List<String> recentSearches;
  Map<String, int> categoryInteractions;
  Map<String, DateTime> productViews;
  List<String> purchaseHistory;
  DateTime lastUpdated;

  UserPreference({
    required this.favoriteCategories,
    required this.minPrice,
    required this.maxPrice,
    required this.preferredBrands,
    required this.shoppingStyle,
    required this.recentSearches,
    required this.categoryInteractions,
    required this.productViews,
    required this.purchaseHistory,
    required this.lastUpdated,
  });

  // Create default preferences for new users
  factory UserPreference.defaultPreferences() {
    return UserPreference(
      favoriteCategories: ['Electronics', 'Fashion', 'Home & Garden'],
      minPrice: 0.0,
      maxPrice: 500.0,
      preferredBrands: [],
      shoppingStyle: 'practical',
      recentSearches: [],
      categoryInteractions: {},
      productViews: {},
      purchaseHistory: [],
      lastUpdated: DateTime.now(),
    );
  }

  // Create from JSON
  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 500.0,
      preferredBrands: List<String>.from(json['preferredBrands'] ?? []),
      shoppingStyle: json['shoppingStyle'] ?? 'practical',
      recentSearches: List<String>.from(json['recentSearches'] ?? []),
      categoryInteractions: Map<String, int>.from(json['categoryInteractions'] ?? {}),
      productViews: _parseProductViews(json['productViews']),
      purchaseHistory: List<String>.from(json['purchaseHistory'] ?? []),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'favoriteCategories': favoriteCategories,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'preferredBrands': preferredBrands,
      'shoppingStyle': shoppingStyle,
      'recentSearches': recentSearches,
      'categoryInteractions': categoryInteractions,
      'productViews': _productViewsToJson(),
      'purchaseHistory': purchaseHistory,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Helper method to parse product views from JSON
  static Map<String, DateTime> _parseProductViews(dynamic productViewsJson) {
    if (productViewsJson == null) return {};
    
    Map<String, DateTime> result = {};
    (productViewsJson as Map<String, dynamic>).forEach((key, value) {
      try {
        result[key] = DateTime.parse(value);
      } catch (e) {
        // Skip invalid dates
      }
    });
    return result;
  }

  // Helper method to convert product views to JSON
  Map<String, String> _productViewsToJson() {
    Map<String, String> result = {};
    productViews.forEach((key, value) {
      result[key] = value.toIso8601String();
    });
    return result;
  }

  // Track user interaction with products
  void trackInteraction(String productId, String interactionType) {
    lastUpdated = DateTime.now();

    switch (interactionType) {
      case 'view':
        productViews[productId] = DateTime.now();
        // Keep only recent 50 views
        if (productViews.length > 50) {
          var sortedEntries = productViews.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          productViews = Map.fromEntries(sortedEntries.take(50));
        }
        break;
      
      case 'purchase':
        purchaseHistory.add(productId);
        productViews[productId] = DateTime.now();
        break;
      
      case 'search':
        if (!recentSearches.contains(productId)) {
          recentSearches.insert(0, productId);
          // Keep only recent 20 searches
          if (recentSearches.length > 20) {
            recentSearches = recentSearches.take(20).toList();
          }
        }
        break;
    }
  }

  // Track category interaction
  void trackCategoryInteraction(String category) {
    categoryInteractions[category] = (categoryInteractions[category] ?? 0) + 1;
    lastUpdated = DateTime.now();
  }

  // Add to favorite categories
  void addFavoriteCategory(String category) {
    if (!favoriteCategories.contains(category)) {
      favoriteCategories.add(category);
      lastUpdated = DateTime.now();
    }
  }

  // Remove from favorite categories
  void removeFavoriteCategory(String category) {
    favoriteCategories.remove(category);
    lastUpdated = DateTime.now();
  }

  // Add preferred brand
  void addPreferredBrand(String brand) {
    if (!preferredBrands.contains(brand)) {
      preferredBrands.add(brand);
      lastUpdated = DateTime.now();
    }
  }

  // Remove preferred brand
  void removePreferredBrand(String brand) {
    preferredBrands.remove(brand);
    lastUpdated = DateTime.now();
  }

  // Update price range
  void updatePriceRange(double min, double max) {
    minPrice = min;
    maxPrice = max;
    lastUpdated = DateTime.now();
  }

  // Update shopping style
  void updateShoppingStyle(String style) {
    shoppingStyle = style;
    lastUpdated = DateTime.now();
  }

  // Get most viewed categories
  List<String> getMostViewedCategories({int limit = 5}) {
    var sortedCategories = categoryInteractions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  // Get recent product views
  List<String> getRecentProductViews({int limit = 10}) {
    var sortedViews = productViews.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedViews
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  // Check if user has any preferences set
  bool hasPreferences() {
    return favoriteCategories.isNotEmpty || 
           preferredBrands.isNotEmpty || 
           categoryInteractions.isNotEmpty ||
           productViews.isNotEmpty;
  }

  // Get preference score for a category (0.0 to 1.0)
  double getCategoryPreferenceScore(String category) {
    if (!categoryInteractions.containsKey(category)) return 0.0;
    
    int maxInteractions = categoryInteractions.values.isEmpty 
        ? 1 
        : categoryInteractions.values.reduce((a, b) => a > b ? a : b);
    
    return categoryInteractions[category]! / maxInteractions;
  }

  // Create a copy with updated values
  UserPreference copyWith({
    List<String>? favoriteCategories,
    double? minPrice,
    double? maxPrice,
    List<String>? preferredBrands,
    String? shoppingStyle,
    List<String>? recentSearches,
    Map<String, int>? categoryInteractions,
    Map<String, DateTime>? productViews,
    List<String>? purchaseHistory,
    DateTime? lastUpdated,
  }) {
    return UserPreference(
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      preferredBrands: preferredBrands ?? this.preferredBrands,
      shoppingStyle: shoppingStyle ?? this.shoppingStyle,
      recentSearches: recentSearches ?? this.recentSearches,
      categoryInteractions: categoryInteractions ?? this.categoryInteractions,
      productViews: productViews ?? this.productViews,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}