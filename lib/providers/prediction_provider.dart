import 'package:flutter/foundation.dart';
import '../models/prediction_models.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/order_tracking.dart';
import '../services/ai_prediction_service.dart';
import 'product_provider.dart';
import 'order_provider.dart';

class PredictionProvider with ChangeNotifier {
  final AIPredictionService _predictionService = AIPredictionService();

  List<StockPrediction> _stockPredictions = [];
  List<DemandPrediction> _demandPredictions = [];
  PredictionAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;

  // Add references to data providers
  ProductProvider? _productProvider;
  OrderProvider? _orderProvider;

  // Getters
  List<StockPrediction> get stockPredictions => _stockPredictions;
  List<DemandPrediction> get demandPredictions => _demandPredictions;
  PredictionAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with data providers
  void initializeWithProviders(ProductProvider productProvider, OrderProvider orderProvider) {
    _productProvider = productProvider;
    _orderProvider = orderProvider;
    
    // Generate predictions when providers are set
    generatePredictionsFromRealData();
  }

  // Filter methods
  List<StockPrediction> get lowStockAlerts => _stockPredictions
      .where((p) => p.status == StockStatus.low || p.status == StockStatus.criticalLow)
      .toList();

  List<StockPrediction> get overStockAlerts => _stockPredictions
      .where((p) => p.status == StockStatus.overStock)
      .toList();

  List<StockPrediction> get criticalStockAlerts => _stockPredictions
      .where((p) => p.status == StockStatus.criticalLow)
      .toList();

  List<StockPrediction> getStockPredictionsByCategory(String category) {
    return _stockPredictions.where((p) {
      // You'd need to join with product data to get category
      return true; // Placeholder
    }).toList();
  }

  List<DemandPrediction> getHighDemandPredictions() {
    return _demandPredictions
        .where((p) => p.averageDailyDemand > 10) // Adjust threshold as needed
        .toList();
  }

  // Generate predictions using real data from providers
  Future<void> generatePredictionsFromRealData() async {
    if (_productProvider == null || _orderProvider == null) {
      debugPrint('Providers not initialized yet');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get real products and orders from providers
      List<Product> products = _productProvider!.products;
      List<Order> orders = _orderProvider!.allOrders;

      debugPrint('Generating predictions for ${products.length} products and ${orders.length} orders');

      if (products.isEmpty) {
        // Create sample products if none exist for demo purposes
        products = _createSampleProducts();
        debugPrint('No real products found, using ${products.length} sample products');
      }

      if (orders.isEmpty) {
        // Create sample orders if none exist for demo purposes  
        orders = _createSampleOrders(products);
        debugPrint('No real orders found, using ${orders.length} sample orders');
      }

      // Generate stock predictions
      _stockPredictions = await _predictionService.generateStockPredictions(
        products,
        orders,
      );

      // Generate demand predictions
      _demandPredictions = await _predictionService.generateDemandPredictions(
        products,
        orders,
      );

      // Generate analytics
      _analytics = await _predictionService.generateAnalytics(
        _stockPredictions,
        _demandPredictions,
      );

      debugPrint('Generated ${_stockPredictions.length} stock predictions and ${_demandPredictions.length} demand predictions');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error generating predictions: $e');
      notifyListeners();
    }
  }

  // Create sample products if store has no products yet
  List<Product> _createSampleProducts() {
    return [
      Product(
        id: 'sample_1',
        name: 'Sample iPhone Case',
        description: 'Protective case for iPhone',
        price: 25.99,
        category: 'Electronics',
        stock: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        imageUrls: ['https://example.com/case.jpg'],
      ),
      Product(
        id: 'sample_2', 
        name: 'Sample T-Shirt',
        description: 'Cotton t-shirt',
        price: 19.99,
        category: 'Clothing',
        stock: 120,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        imageUrls: ['https://example.com/tshirt.jpg'],
      ),
      Product(
        id: 'sample_3',
        name: 'Sample Coffee Mug',
        description: 'Ceramic coffee mug',
        price: 12.99,
        category: 'Home',
        stock: 80,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        imageUrls: ['https://example.com/mug.jpg'],
      ),
    ];
  }

  // Create sample orders if store has no orders yet
  List<Order> _createSampleOrders(List<Product> products) {
    List<Order> orders = [];
    
    for (int i = 0; i < 20; i++) {
      final product = products[i % products.length];
      final order = Order(
        id: 'sample_order_$i',
        userId: 'sample_user_$i',
        customerName: 'Sample Customer $i',
        customerEmail: 'customer$i@example.com',
        customerPhone: '+1234567890',
        items: [
          CartItem(
            id: 'item_$i',
            product: product,
            quantity: (i % 5) + 1, // 1-5 quantity
          ),
        ],
        totalAmount: product.price * ((i % 5) + 1),
        status: OrderStatus.delivered,
        shippingAddress: 'Sample Address $i',
        createdAt: DateTime.now().subtract(Duration(days: i + 1)),
        deliveredAt: DateTime.now().subtract(Duration(days: i)),
      );
      orders.add(order);
    }
    
    return orders;
  }

  // Main prediction generation method (updated to use real data)
  Future<void> generatePredictions(List<Product> products, List<Order> orderHistory) async {
    // This method is kept for backward compatibility but now uses real data
    await generatePredictionsFromRealData();
  }

  // Refresh predictions
  Future<void> refreshPredictions(List<Product> products, List<Order> orderHistory) async {
    await generatePredictions(products, orderHistory);
  }

  // Get prediction for specific product
  StockPrediction? getStockPredictionForProduct(String productId) {
    try {
      return _stockPredictions.firstWhere((p) => p.productId == productId);
    } catch (e) {
      return null;
    }
  }

  DemandPrediction? getDemandPredictionForProduct(String productId) {
    try {
      return _demandPredictions.firstWhere((p) => p.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Filter predictions by confidence level
  List<StockPrediction> getHighConfidencePredictions({double threshold = 0.8}) {
    return _stockPredictions
        .where((p) => p.confidenceLevel >= threshold)
        .toList();
  }

  List<StockPrediction> getLowConfidencePredictions({double threshold = 0.5}) {
    return _stockPredictions
        .where((p) => p.confidenceLevel < threshold)
        .toList();
  }

  // Sort methods
  void sortStockPredictionsByConfidence({bool ascending = false}) {
    _stockPredictions.sort((a, b) => ascending 
        ? a.confidenceLevel.compareTo(b.confidenceLevel)
        : b.confidenceLevel.compareTo(a.confidenceLevel));
    notifyListeners();
  }

  void sortStockPredictionsByDemand({bool ascending = false}) {
    _stockPredictions.sort((a, b) => ascending 
        ? a.predictedDemand.compareTo(b.predictedDemand)
        : b.predictedDemand.compareTo(a.predictedDemand));
    notifyListeners();
  }

  void sortStockPredictionsByStatus() {
    _stockPredictions.sort((a, b) {
      // Priority order: Critical Low > Low > High > Overstock > Normal
      int getPriority(StockStatus status) {
        switch (status) {
          case StockStatus.criticalLow:
            return 1;
          case StockStatus.low:
            return 2;
          case StockStatus.high:
            return 3;
          case StockStatus.overStock:
            return 4;
          case StockStatus.normal:
            return 5;
        }
      }
      return getPriority(a.status).compareTo(getPriority(b.status));
    });
    notifyListeners();
  }

  // Clear data
  void clearPredictions() {
    _stockPredictions.clear();
    _demandPredictions.clear();
    _analytics = null;
    _error = null;
    notifyListeners();
  }

  // Export methods for admin reports
  Map<String, dynamic> exportPredictionsToJson() {
    return {
      'stockPredictions': _stockPredictions.map((p) => p.toJson()).toList(),
      'demandPredictions': _demandPredictions.map((p) => p.toJson()).toList(),
      'analytics': _analytics?.toJson(),
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Statistics methods
  int get totalProductsAnalyzed => _stockPredictions.length;
  
  double get averageConfidenceLevel {
    if (_stockPredictions.isEmpty) return 0.0;
    double total = _stockPredictions
        .map((p) => p.confidenceLevel)
        .reduce((a, b) => a + b);
    return total / _stockPredictions.length;
  }

  int get totalPredictedDemand {
    return _stockPredictions
        .map((p) => p.predictedDemand)
        .fold(0, (sum, demand) => sum + demand);
  }

  Map<StockStatus, int> get stockStatusCounts {
    Map<StockStatus, int> counts = {};
    for (var prediction in _stockPredictions) {
      counts[prediction.status] = (counts[prediction.status] ?? 0) + 1;
    }
    return counts;
  }

  // New detailed analytics methods
  double get totalRevenueProjection {
    if (_productProvider == null || _stockPredictions.isEmpty) return 0.0;
    
    double totalRevenue = 0.0;
    for (var prediction in _stockPredictions) {
      final product = _productProvider!.products.firstWhere(
        (p) => p.id == prediction.productId,
        orElse: () => Product(
          id: '', name: '', price: 0, category: '', 
          description: '', stock: 0, createdAt: DateTime.now()
        )
      );
      if (product.id.isNotEmpty) {
        totalRevenue += product.price * prediction.predictedDemand;
      }
    }
    return totalRevenue;
  }

  Map<String, Map<String, dynamic>> get categoryAnalytics {
    if (_productProvider == null) return {};
    
    Map<String, Map<String, dynamic>> analytics = {};
    
    for (var prediction in _stockPredictions) {
      final product = _productProvider!.products.firstWhere(
        (p) => p.id == prediction.productId,
        orElse: () => Product(
          id: '', name: '', price: 0, category: '', 
          description: '', stock: 0, createdAt: DateTime.now()
        )
      );
      
      if (product.id.isNotEmpty) {
        if (!analytics.containsKey(product.category)) {
          analytics[product.category] = {
            'totalProducts': 0,
            'totalDemand': 0,
            'averageConfidence': 0.0,
            'lowStockCount': 0,
            'projectedRevenue': 0.0,
          };
        }
        
        analytics[product.category]!['totalProducts'] += 1;
        analytics[product.category]!['totalDemand'] += prediction.predictedDemand;
        analytics[product.category]!['averageConfidence'] += prediction.confidenceLevel;
        if (prediction.status == StockStatus.low || prediction.status == StockStatus.criticalLow) {
          analytics[product.category]!['lowStockCount'] += 1;
        }
        analytics[product.category]!['projectedRevenue'] += product.price * prediction.predictedDemand;
      }
    }
    
    // Calculate averages
    analytics.forEach((category, data) {
      data['averageConfidence'] /= data['totalProducts'];
    });
    
    return analytics;
  }

  List<Map<String, dynamic>> get topPerformingProducts {
    if (_productProvider == null) return [];
    
    List<Map<String, dynamic>> topProducts = [];
    
    for (var prediction in _stockPredictions) {
      final product = _productProvider!.products.firstWhere(
        (p) => p.id == prediction.productId,
        orElse: () => Product(
          id: '', name: '', price: 0, category: '', 
          description: '', stock: 0, createdAt: DateTime.now()
        )
      );
      
      if (product.id.isNotEmpty) {
        topProducts.add({
          'productId': product.id,
          'productName': product.name,
          'category': product.category,
          'predictedDemand': prediction.predictedDemand,
          'projectedRevenue': product.price * prediction.predictedDemand,
          'confidenceLevel': prediction.confidenceLevel,
          'stockStatus': prediction.status.toString(),
        });
      }
    }
    
    // Sort by projected revenue
    topProducts.sort((a, b) => b['projectedRevenue'].compareTo(a['projectedRevenue']));
    return topProducts.take(10).toList();
  }

  Map<String, dynamic> get performanceMetrics {
    if (_stockPredictions.isEmpty) return {};
    
    int accuratePredictions = _stockPredictions.where((p) => p.confidenceLevel > 75).length;
    int mediumAccuracy = _stockPredictions.where((p) => p.confidenceLevel >= 50 && p.confidenceLevel <= 75).length;
    int lowAccuracy = _stockPredictions.where((p) => p.confidenceLevel < 50).length;
    
    return {
      'totalPredictions': _stockPredictions.length,
      'highAccuracy': accuratePredictions,
      'mediumAccuracy': mediumAccuracy,
      'lowAccuracy': lowAccuracy,
      'accuracyRate': (_stockPredictions.isNotEmpty) ? (accuratePredictions / _stockPredictions.length * 100) : 0.0,
      'riskFactor': (lowStockAlerts.length / _stockPredictions.length * 100),
      'overStockRisk': (overStockAlerts.length / _stockPredictions.length * 100),
    };
  }

  // Notification methods for real-time updates
  void checkForCriticalAlerts() {
    List<StockPrediction> critical = criticalStockAlerts;
    if (critical.isNotEmpty) {
      // You can implement push notifications here
      debugPrint('Critical stock alerts: ${critical.length} products need immediate attention');
    }
  }

  // Weekly/Monthly report generation
  Map<String, dynamic> generateWeeklyReport() {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(const Duration(days: 7));

    return {
      'reportType': 'weekly',
      'generatedAt': now.toIso8601String(),
      'period': {
        'start': weekAgo.toIso8601String(),
        'end': now.toIso8601String(),
      },
      'summary': {
        'totalProducts': totalProductsAnalyzed,
        'lowStockAlerts': lowStockAlerts.length,
        'overStockAlerts': overStockAlerts.length,
        'criticalAlerts': criticalStockAlerts.length,
        'averageConfidence': double.parse(averageConfidenceLevel.toStringAsFixed(2)),
        'totalPredictedDemand': totalPredictedDemand,
        'projectedRevenue': double.parse(totalRevenueProjection.toStringAsFixed(2)),
      },
      'performanceMetrics': performanceMetrics,
      'categoryAnalytics': categoryAnalytics,
      'topPerformers': topPerformingProducts.take(5).toList(),
      'stockStatusBreakdown': stockStatusCounts,
      'topConcerns': [
        ...criticalStockAlerts.take(5).map((p) => {
          'productId': p.productId,
          'productName': p.productName,
          'issue': 'Critical Low Stock',
          'currentStock': p.currentStock,
          'predictedDemand': p.predictedDemand,
          'urgency': 'HIGH',
        }),
        ...overStockAlerts.take(5).map((p) => {
          'productId': p.productId,
          'productName': p.productName,
          'issue': 'Overstock',
          'currentStock': p.currentStock,
          'recommendedStock': p.recommendedStock,
          'urgency': 'MEDIUM',
        }),
      ],
      'recommendations': _generateActionableRecommendations(),
    };
  }

  List<Map<String, dynamic>> _generateActionableRecommendations() {
    List<Map<String, dynamic>> recommendations = [];
    
    // Critical stock recommendations
    if (criticalStockAlerts.isNotEmpty) {
      recommendations.add({
        'type': 'urgent_restock',
        'priority': 'HIGH',
        'title': 'Urgent Restocking Required',
        'description': '${criticalStockAlerts.length} products need immediate restocking',
        'action': 'Review and place orders for critical items',
        'affectedProducts': criticalStockAlerts.length,
      });
    }
    
    // Overstock recommendations
    if (overStockAlerts.isNotEmpty) {
      recommendations.add({
        'type': 'reduce_inventory',
        'priority': 'MEDIUM',
        'title': 'Reduce Excess Inventory',
        'description': '${overStockAlerts.length} products are overstocked',
        'action': 'Consider promotional campaigns or reduce ordering',
        'affectedProducts': overStockAlerts.length,
      });
    }
    
    // High-confidence opportunities
    var highConfidenceProducts = _stockPredictions.where((p) => p.confidenceLevel > 85).toList();
    if (highConfidenceProducts.isNotEmpty) {
      recommendations.add({
        'type': 'high_confidence_opportunities',
        'priority': 'MEDIUM',
        'title': 'High-Confidence Growth Opportunities',
        'description': '${highConfidenceProducts.length} products show strong demand patterns',
        'action': 'Consider increasing stock levels for these items',
        'affectedProducts': highConfidenceProducts.length,
      });
    }
    
    return recommendations;
  }

  Map<String, dynamic> generateMonthlyReport() {
    DateTime now = DateTime.now();
    DateTime monthAgo = DateTime(now.year, now.month - 1, now.day);

    // Get top performing predictions by category
    Map<String, List<DemandPrediction>> byCategory = {};
    for (var prediction in _demandPredictions) {
      byCategory[prediction.categoryId] = byCategory[prediction.categoryId] ?? [];
      byCategory[prediction.categoryId]!.add(prediction);
    }

    return {
      'reportType': 'monthly',
      'generatedAt': now.toIso8601String(),
      'period': {
        'start': monthAgo.toIso8601String(),
        'end': now.toIso8601String(),
      },
      'summary': {
        'totalProducts': totalProductsAnalyzed,
        'categoriesAnalyzed': byCategory.keys.length,
        'averageConfidence': averageConfidenceLevel,
        'stockStatusBreakdown': stockStatusCounts,
      },
      'categoryInsights': byCategory.map((category, predictions) => MapEntry(
        category,
        {
          'productCount': predictions.length,
          'averageDemand': predictions.isNotEmpty 
              ? predictions.map((p) => p.averageDailyDemand).reduce((a, b) => a + b) / predictions.length
              : 0.0,
          'topProduct': predictions.isNotEmpty 
              ? predictions.reduce((a, b) => a.averageDailyDemand > b.averageDailyDemand ? a : b).productName
              : 'N/A',
        },
      )),
      'analytics': _analytics?.toJson(),
    };
  }
}