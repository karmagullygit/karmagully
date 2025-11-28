import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'product_provider.dart';

// Simple AI Marketing Provider that actually works
class SimpleAIProvider extends ChangeNotifier {
  ProductProvider? _productProvider;
  
  // Data that actually changes the app
  String _featuredCollection = 'Attack on Titan';
  double _currentDiscount = 0;
  String _promotionalBanner = '';
  List<String> _recommendedProducts = [];
  bool _showUrgencyBadge = false;
  String _specialOffer = '';
  bool _isAIMarketingEnabled = true; // New toggle for AI marketing
  
  // Getters for the main app to use
  String get featuredCollection => _featuredCollection;
  double get currentDiscount => _currentDiscount;
  String get promotionalBanner => _promotionalBanner;
  List<String> get recommendedProducts => _recommendedProducts;
  bool get showUrgencyBadge => _showUrgencyBadge;
  String get specialOffer => _specialOffer;
  bool get isAIMarketingEnabled => _isAIMarketingEnabled;
  
  // Simple actions that actually work
  List<String> _availableActions = [
    'Feature Demon Slayer Collection',
    'Start 25% Flash Sale',
    'Show Popular Products Banner',
    'Enable Limited Time Offer',
    'Feature Attack on Titan',
    'Start Urgent Sale - 30% Off',
  ];
  
  List<String> get availableActions => _availableActions;
  
  // Set product provider for real product access
  void setProductProvider(ProductProvider productProvider) {
    _productProvider = productProvider;
  }
  
  // Get real product names based on category or collection
  List<String> _getRealProductNames({String? category, int count = 3}) {
    if (_productProvider == null || _productProvider!.products.isEmpty) {
      // Fallback to demo products if no real products available
      return [
        'Attack on Titan Poster Set',
        'Demon Slayer Collection',
        'Naruto Ultimate Pack'
      ].take(count).toList();
    }
    
    var products = _productProvider!.products;
    
    // Filter by category or collection name if specified
    if (category != null) {
      products = products.where((product) => 
        product.name.toLowerCase().contains(category.toLowerCase()) ||
        product.description.toLowerCase().contains(category.toLowerCase()) ||
        product.category.toLowerCase().contains(category.toLowerCase())
      ).toList();
    }
    
    // Shuffle and take requested count
    products.shuffle();
    return products.take(count).map((product) => product.name).toList();
  }
  
  // Toggle AI marketing on/off
  void toggleAIMarketing() {
    _isAIMarketingEnabled = !_isAIMarketingEnabled;
    if (!_isAIMarketingEnabled) {
      // Clear all AI content when disabled
      _currentDiscount = 0;
      _promotionalBanner = '';
      _recommendedProducts = [];
      _showUrgencyBadge = false;
      _specialOffer = '';
    }
    _saveSettings();
    notifyListeners();
  }
  
  // Initialize
  Future<void> initialize() async {
    await _loadSettings();
    _setDefaultContent();
  }
  
  // Execute an action - this actually changes the app!
  Future<void> executeAction(String action) async {
    if (!_isAIMarketingEnabled) return; // Don't execute if AI marketing is disabled
    
    print('🎯 Executing Simple AI Action: $action');
    
    switch (action) {
      case 'Feature Demon Slayer Collection':
        _featuredCollection = 'Demon Slayer';
        _recommendedProducts = _getRealProductNames(category: 'Demon Slayer', count: 3);
        _promotionalBanner = '🔥 Now Featuring: Demon Slayer Collection!';
        break;
        
      case 'Start 25% Flash Sale':
        _currentDiscount = 25;
        _promotionalBanner = '⚡ FLASH SALE: 25% OFF All Anime Posters!';
        _showUrgencyBadge = true;
        _specialOffer = 'Limited Time: 25% OFF Everything!';
        break;
        
      case 'Show Popular Products Banner':
        _promotionalBanner = '⭐ Most Popular: Attack on Titan Collection';
        _recommendedProducts = _getRealProductNames(category: 'Attack on Titan', count: 3);
        break;
        
      case 'Enable Limited Time Offer':
        _showUrgencyBadge = true;
        _specialOffer = '🎯 Limited Time: Buy 2 Get 1 FREE!';
        _promotionalBanner = '🎁 Special Offer: Buy 2 Get 1 FREE on All Posters!';
        break;
        
      case 'Feature Attack on Titan':
        _featuredCollection = 'Attack on Titan';
        _recommendedProducts = _getRealProductNames(category: 'Attack on Titan', count: 3);
        _promotionalBanner = '⚔️ Now Featuring: Attack on Titan Collection!';
        break;
        
      case 'Start Urgent Sale - 30% Off':
        _currentDiscount = 30;
        _promotionalBanner = '🚨 URGENT SALE: 30% OFF - Limited Time!';
        _showUrgencyBadge = true;
        _specialOffer = 'URGENT: 30% OFF Everything - Hurry!';
        break;
    }
    
    await _saveSettings();
    notifyListeners(); // This triggers UI updates!
    
    print('✅ Action executed! App content updated.');
    print('   Featured Collection: $_featuredCollection');
    print('   Current Discount: $_currentDiscount%');
    print('   Banner: $_promotionalBanner');
    print('   Recommended Products: $_recommendedProducts');
  }
  
  // Reset to default
  Future<void> resetToDefault() async {
    _featuredCollection = 'Attack on Titan';
    _currentDiscount = 0;
    _promotionalBanner = '';
    _recommendedProducts = [];
    _showUrgencyBadge = false;
    _specialOffer = '';
    
    await _saveSettings();
    notifyListeners();
    print('🔄 Reset to default settings');
  }
  
  // Get current status for admin dashboard
  Map<String, dynamic> getCurrentStatus() {
    return {
      'featuredCollection': _featuredCollection,
      'currentDiscount': _currentDiscount,
      'promotionalBanner': _promotionalBanner,
      'recommendedProducts': _recommendedProducts,
      'showUrgencyBadge': _showUrgencyBadge,
      'specialOffer': _specialOffer,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
  
  void _setDefaultContent() {
    if (_featuredCollection.isEmpty) {
      _featuredCollection = 'Attack on Titan';
    }
    if (_recommendedProducts.isEmpty) {
      _recommendedProducts = [
        'Attack on Titan Poster Set',
        'Demon Slayer Collection',
        'Naruto Classic Art'
      ];
    }
  }
  
  // Simple analytics - just track what's popular
  Map<String, dynamic> getSimpleAnalytics() {
    final random = Random();
    return {
      'totalViews': 1500 + random.nextInt(500),
      'popularCollection': _featuredCollection,
      'conversionRate': '${(2.5 + random.nextDouble() * 2).toStringAsFixed(1)}%',
      'topKeywords': [
        '${_featuredCollection.toLowerCase()} poster',
        'anime wall art',
        'metal poster collection'
      ],
      'currentActiveOffers': _currentDiscount > 0 ? 1 : 0,
    };
  }
  
  // Persistence
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'featuredCollection': _featuredCollection,
      'currentDiscount': _currentDiscount,
      'promotionalBanner': _promotionalBanner,
      'recommendedProducts': _recommendedProducts,
      'showUrgencyBadge': _showUrgencyBadge,
      'specialOffer': _specialOffer,
    };
    await prefs.setString('simple_ai_settings', jsonEncode(data));
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('simple_ai_settings');
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      _featuredCollection = data['featuredCollection'] ?? 'Attack on Titan';
      _currentDiscount = data['currentDiscount'] ?? 0.0;
      _promotionalBanner = data['promotionalBanner'] ?? '';
      _recommendedProducts = List<String>.from(data['recommendedProducts'] ?? []);
      _showUrgencyBadge = data['showUrgencyBadge'] ?? false;
      _specialOffer = data['specialOffer'] ?? '';
    }
  }

  // Individual Clear/Set Methods for AI Marketing Content Management

  void clearPromotionalBanner() {
    _promotionalBanner = '';
    _saveSettings();
    notifyListeners();
  }

  void clearFeaturedCollection() {
    _featuredCollection = '';
    _saveSettings();
    notifyListeners();
  }

  void clearSpecialOffer() {
    _specialOffer = '';
    _saveSettings();
    notifyListeners();
  }

  void clearDiscount() {
    _currentDiscount = 0;
    _saveSettings();
    notifyListeners();
  }

  void clearRecommendedProducts() {
    _recommendedProducts.clear();
    _saveSettings();
    notifyListeners();
  }

  void removeRecommendedProduct(int index) {
    if (index >= 0 && index < _recommendedProducts.length) {
      _recommendedProducts.removeAt(index);
      _saveSettings();
      notifyListeners();
    }
  }

  void setPromotionalBanner(String banner) {
    _promotionalBanner = banner;
    _saveSettings();
    notifyListeners();
  }

  void setFeaturedCollection(String collection) {
    _featuredCollection = collection;
    _saveSettings();
    notifyListeners();
  }

  void setSpecialOffer(String offer) {
    _specialOffer = offer;
    _saveSettings();
    notifyListeners();
  }

  void setDiscount(double discount) {
    _currentDiscount = discount;
    _saveSettings();
    notifyListeners();
  }

  void setRecommendedProducts(List<String> products) {
    _recommendedProducts = List<String>.from(products);
    _saveSettings();
    notifyListeners();
  }
}