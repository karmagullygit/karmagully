import 'dart:math' as math;
import '../models/prediction_models.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class AIPredictionService {
  static final AIPredictionService _instance = AIPredictionService._internal();
  factory AIPredictionService() => _instance;
  AIPredictionService._internal();

  // AI prediction algorithms
  Future<List<StockPrediction>> generateStockPredictions(
    List<Product> products,
    List<Order> orderHistory,
  ) async {
    List<StockPrediction> predictions = [];

    for (Product product in products) {
      // Analyze historical sales data
      List<CartItem> productOrders = _getProductOrderHistory(product.id, orderHistory);
      
      // Calculate demand trends
      List<StockTrend> trends = _calculateStockTrends(product.id, orderHistory);
      
      // AI prediction algorithm
      int predictedDemand = _predictDemandUsingML(productOrders, trends);
      int recommendedStock = _calculateRecommendedStock(
        predictedDemand, 
        product.stock,
        trends,
      );
      
      double confidence = _calculateConfidenceLevel(trends, productOrders);
      StockStatus status = _determineStockStatus(
        product.stock,
        predictedDemand,
        recommendedStock,
      );

      predictions.add(
        StockPrediction(
          productId: product.id,
          productName: product.name,
          currentStock: product.stock,
          predictedDemand: predictedDemand,
          recommendedStock: recommendedStock,
          confidenceLevel: confidence,
          predictionDate: DateTime.now(),
          trends: trends,
          status: status,
        ),
      );
    }

    return predictions;
  }

  Future<List<DemandPrediction>> generateDemandPredictions(
    List<Product> products,
    List<Order> orderHistory,
  ) async {
    List<DemandPrediction> predictions = [];

    for (Product product in products) {
      // Generate weekly and monthly forecasts
      List<DemandForecast> weeklyForecast = _generateWeeklyForecast(product.id, orderHistory);
      List<DemandForecast> monthlyForecast = _generateMonthlyForecast(product.id, orderHistory);
      
      // Analyze seasonal patterns
      List<SeasonalPattern> seasonalPatterns = _analyzeSeasonalPatterns(product.category, orderHistory);
      
      // Calculate demand metrics
      double avgDailyDemand = _calculateAverageDailyDemand(product.id, orderHistory);
      double peakFactor = _calculatePeakDemandFactor(product.id, orderHistory);

      predictions.add(
        DemandPrediction(
          productId: product.id,
          productName: product.name,
          categoryId: product.category,
          weeklyForecast: weeklyForecast,
          monthlyForecast: monthlyForecast,
          seasonalPatterns: seasonalPatterns,
          averageDailyDemand: avgDailyDemand,
          peakDemandFactor: peakFactor,
          lastUpdated: DateTime.now(),
        ),
      );
    }

    return predictions;
  }

  Future<PredictionAnalytics> generateAnalytics(
    List<StockPrediction> stockPredictions,
    List<DemandPrediction> demandPredictions,
  ) async {
    int lowStockAlerts = stockPredictions
        .where((p) => p.status == StockStatus.low || p.status == StockStatus.criticalLow)
        .length;

    int overStockAlerts = stockPredictions
        .where((p) => p.status == StockStatus.overStock)
        .length;

    double averageAccuracy = stockPredictions.isNotEmpty
        ? stockPredictions.map((p) => p.confidenceLevel).reduce((a, b) => a + b) / stockPredictions.length
        : 0.0;

    Map<String, int> categoryDemand = {};
    for (var prediction in demandPredictions) {
      categoryDemand[prediction.categoryId] = 
          (categoryDemand[prediction.categoryId] ?? 0) + prediction.averageDailyDemand.round();
    }

    List<TopSellingPrediction> topSelling = _generateTopSellingPredictions(demandPredictions);

    return PredictionAnalytics(
      totalProducts: stockPredictions.length,
      lowStockAlerts: lowStockAlerts,
      overStockAlerts: overStockAlerts,
      averageAccuracy: averageAccuracy,
      categoryDemand: categoryDemand,
      topSellingPredictions: topSelling,
      lastAnalysisDate: DateTime.now(),
    );
  }

  // Private helper methods for AI algorithms

  List<CartItem> _getProductOrderHistory(String productId, List<Order> orders) {
    List<CartItem> productOrders = [];
    
    for (Order order in orders) {
      for (CartItem item in order.items) {
        if (item.product.id == productId) {
          productOrders.add(item);
        }
      }
    }
    
    return productOrders;
  }

  List<StockTrend> _calculateStockTrends(String productId, List<Order> orders) {
    List<StockTrend> trends = [];
    Map<DateTime, int> dailySales = {};

    // Group sales by day
    for (Order order in orders) {
      DateTime day = DateTime(order.createdAt.year, order.createdAt.month, order.createdAt.day);
      
      for (CartItem item in order.items) {
        if (item.product.id == productId) {
          dailySales[day] = (dailySales[day] ?? 0) + item.quantity;
        }
      }
    }

    // Convert to trends with direction analysis
    List<DateTime> sortedDates = dailySales.keys.toList()..sort();
    
    for (int i = 0; i < sortedDates.length; i++) {
      DateTime date = sortedDates[i];
      int sales = dailySales[date] ?? 0;
      
      TrendDirection direction = TrendDirection.stable;
      if (i > 0) {
        int previousSales = dailySales[sortedDates[i - 1]] ?? 0;
        if (sales > previousSales * 1.2) {
          direction = TrendDirection.increasing;
        } else if (sales < previousSales * 0.8) {
          direction = TrendDirection.decreasing;
        } else if ((sales - previousSales).abs() > previousSales * 0.5) {
          direction = TrendDirection.volatile;
        }
      }

      trends.add(StockTrend(
        date: date,
        stock: 0, // This would come from actual stock tracking
        sales: sales,
        direction: direction,
      ));
    }

    return trends;
  }

  int _predictDemandUsingML(List<CartItem> productOrders, List<StockTrend> trends) {
    if (productOrders.isEmpty || trends.isEmpty) return 0;

    // Simple moving average with trend analysis
    List<int> recentSales = trends.take(30).map((t) => t.sales).toList();
    double average = recentSales.isNotEmpty 
        ? recentSales.reduce((a, b) => a + b) / recentSales.length 
        : 0;

    // Apply trend factor
    double trendFactor = 1.0;
    if (trends.isNotEmpty) {
      TrendDirection lastTrend = trends.last.direction;
      switch (lastTrend) {
        case TrendDirection.increasing:
          trendFactor = 1.3;
          break;
        case TrendDirection.decreasing:
          trendFactor = 0.7;
          break;
        case TrendDirection.volatile:
          trendFactor = 1.1;
          break;
        case TrendDirection.stable:
          trendFactor = 1.0;
          break;
      }
    }

    // Seasonal adjustment (simplified)
    double seasonalFactor = _getSeasonalFactor();

    return (average * trendFactor * seasonalFactor).round();
  }

  int _calculateRecommendedStock(int predictedDemand, int currentStock, List<StockTrend> trends) {
    // Safety stock calculation
    double safetyStock = predictedDemand * 0.3; // 30% safety buffer
    
    // Lead time consideration (assume 7 days)
    int leadTimeDemand = (predictedDemand * 7 / 30).round();
    
    // Trend adjustment
    double trendMultiplier = 1.0;
    if (trends.isNotEmpty) {
      int increasingTrends = trends.where((t) => t.direction == TrendDirection.increasing).length;
      int decreasingTrends = trends.where((t) => t.direction == TrendDirection.decreasing).length;
      
      if (increasingTrends > decreasingTrends) {
        trendMultiplier = 1.2;
      } else if (decreasingTrends > increasingTrends) {
        trendMultiplier = 0.8;
      }
    }

    int recommendedStock = ((predictedDemand + safetyStock + leadTimeDemand) * trendMultiplier).round();
    
    return math.max(recommendedStock, predictedDemand); // Minimum is predicted demand
  }

  double _calculateConfidenceLevel(List<StockTrend> trends, List<CartItem> orders) {
    if (trends.isEmpty || orders.isEmpty) return 0.5;

    // Base confidence on data availability
    double dataConfidence = math.min(trends.length / 30.0, 1.0); // 30 days optimal
    
    // Reduce confidence for volatile trends
    int volatileTrends = trends.where((t) => t.direction == TrendDirection.volatile).length;
    double volatilityPenalty = volatileTrends / trends.length * 0.3;
    
    // Increase confidence for stable patterns
    int stableTrends = trends.where((t) => t.direction == TrendDirection.stable).length;
    double stabilityBonus = stableTrends / trends.length * 0.2;

    return math.max(0.1, math.min(1.0, dataConfidence - volatilityPenalty + stabilityBonus));
  }

  StockStatus _determineStockStatus(int currentStock, int predictedDemand, int recommendedStock) {
    double stockRatio = currentStock / math.max(predictedDemand, 1);

    if (stockRatio < 0.2) {
      return StockStatus.criticalLow;
    } else if (stockRatio < 0.5) {
      return StockStatus.low;
    } else if (stockRatio > 3.0) {
      return StockStatus.overStock;
    } else if (stockRatio > 2.0) {
      return StockStatus.high;
    } else {
      return StockStatus.normal;
    }
  }

  List<DemandForecast> _generateWeeklyForecast(String productId, List<Order> orders) {
    List<DemandForecast> forecasts = [];
    DateTime today = DateTime.now();

    for (int week = 1; week <= 4; week++) {
      DateTime forecastDate = today.add(Duration(days: week * 7));
      
      // Simplified prediction based on historical patterns
      double baseDemand = _calculateAverageDailyDemand(productId, orders) * 7;
      double seasonalFactor = _getSeasonalFactor();
      double randomVariation = (math.Random().nextDouble() - 0.5) * 0.2; // ±10% variation
      
      double predictedDemand = baseDemand * seasonalFactor * (1 + randomVariation);
      double confidence = 0.85 - (week * 0.1); // Confidence decreases with time

      forecasts.add(DemandForecast(
        date: forecastDate,
        predictedDemand: math.max(0, predictedDemand),
        confidence: confidence,
        influencingFactors: _getInfluencingFactors(week),
      ));
    }

    return forecasts;
  }

  List<DemandForecast> _generateMonthlyForecast(String productId, List<Order> orders) {
    List<DemandForecast> forecasts = [];
    DateTime today = DateTime.now();

    for (int month = 1; month <= 6; month++) {
      DateTime forecastDate = DateTime(today.year, today.month + month, 1);
      
      double baseDemand = _calculateAverageDailyDemand(productId, orders) * 30;
      double seasonalFactor = _getMonthlySeasonalFactor(forecastDate.month);
      double trendFactor = 1.0 + (month * 0.05); // 5% growth assumption
      
      double predictedDemand = baseDemand * seasonalFactor * trendFactor;
      double confidence = 0.75 - (month * 0.05);

      forecasts.add(DemandForecast(
        date: forecastDate,
        predictedDemand: math.max(0, predictedDemand),
        confidence: confidence,
        influencingFactors: _getMonthlyInfluencingFactors(forecastDate.month),
      ));
    }

    return forecasts;
  }

  List<SeasonalPattern> _analyzeSeasonalPatterns(String categoryId, List<Order> orders) {
    return [
      SeasonalPattern(
        season: 'Holiday Season',
        demandMultiplier: 1.8,
        peakMonths: ['November', 'December'],
        description: 'High demand during holiday shopping',
      ),
      SeasonalPattern(
        season: 'Summer',
        demandMultiplier: 1.2,
        peakMonths: ['June', 'July', 'August'],
        description: 'Increased summer activity',
      ),
      SeasonalPattern(
        season: 'Back to School',
        demandMultiplier: 1.4,
        peakMonths: ['August', 'September'],
        description: 'School and college preparation period',
      ),
    ];
  }

  double _calculateAverageDailyDemand(String productId, List<Order> orders) {
    List<CartItem> productOrders = _getProductOrderHistory(productId, orders);
    
    if (productOrders.isEmpty) return 0.0;

    int totalQuantity = productOrders.map((item) => item.quantity).reduce((a, b) => a + b);
    
    // Calculate days span
    List<DateTime> orderDates = orders.map((o) => o.createdAt).toList()..sort();
    if (orderDates.isEmpty) return 0.0;
    
    int daySpan = orderDates.last.difference(orderDates.first).inDays;
    daySpan = math.max(daySpan, 1);

    return totalQuantity / daySpan;
  }

  double _calculatePeakDemandFactor(String productId, List<Order> orders) {
    List<CartItem> productOrders = _getProductOrderHistory(productId, orders);
    
    if (productOrders.isEmpty) return 1.0;

    // Group by day and find peak
    Map<DateTime, int> dailyDemand = {};
    for (Order order in orders) {
      DateTime day = DateTime(order.createdAt.year, order.createdAt.month, order.createdAt.day);
      for (CartItem item in order.items) {
        if (item.product.id == productId) {
          dailyDemand[day] = (dailyDemand[day] ?? 0) + item.quantity;
        }
      }
    }

    if (dailyDemand.isEmpty) return 1.0;

    int maxDailyDemand = dailyDemand.values.reduce(math.max);
    double avgDailyDemand = _calculateAverageDailyDemand(productId, orders);

    return avgDailyDemand > 0 ? maxDailyDemand / avgDailyDemand : 1.0;
  }

  List<TopSellingPrediction> _generateTopSellingPredictions(List<DemandPrediction> predictions) {
    List<TopSellingPrediction> topSelling = predictions.map((p) {
      double predictedSales = p.averageDailyDemand * 30; // Monthly sales
      double revenueImpact = predictedSales * 50; // Assuming average price $50
      
      return TopSellingPrediction(
        productId: p.productId,
        productName: p.productName,
        predictedSales: predictedSales,
        revenueImpact: revenueImpact,
      );
    }).toList();

    // Sort by predicted sales and take top 10
    topSelling.sort((a, b) => b.predictedSales.compareTo(a.predictedSales));
    return topSelling.take(10).toList();
  }

  double _getSeasonalFactor() {
    DateTime now = DateTime.now();
    int month = now.month;
    
    // Holiday season boost
    if (month == 11 || month == 12) return 1.5;
    // Summer boost
    if (month >= 6 && month <= 8) return 1.2;
    // Back to school
    if (month == 8 || month == 9) return 1.3;
    
    return 1.0;
  }

  double _getMonthlySeasonalFactor(int month) {
    switch (month) {
      case 1: return 0.8; // January (post-holiday drop)
      case 2: return 0.9; // February
      case 3: return 1.0; // March
      case 4: return 1.1; // April (spring)
      case 5: return 1.1; // May
      case 6: return 1.2; // June (summer start)
      case 7: return 1.2; // July
      case 8: return 1.3; // August (back to school)
      case 9: return 1.2; // September
      case 10: return 1.1; // October
      case 11: return 1.5; // November (holiday prep)
      case 12: return 1.8; // December (holidays)
      default: return 1.0;
    }
  }

  List<String> _getInfluencingFactors(int week) {
    List<String> factors = ['Historical trends', 'Seasonal patterns'];
    
    if (week == 1) {
      factors.addAll(['Recent sales data', 'Current inventory']);
    } else if (week <= 2) {
      factors.addAll(['Market trends', 'Promotional activities']);
    } else {
      factors.addAll(['Long-term patterns', 'Economic indicators']);
    }
    
    return factors;
  }

  List<String> _getMonthlyInfluencingFactors(int month) {
    List<String> factors = ['Seasonal trends', 'Historical data', 'Market analysis'];
    
    if (month == 11 || month == 12) {
      factors.addAll(['Holiday shopping', 'Gift-giving trends']);
    } else if (month >= 6 && month <= 8) {
      factors.addAll(['Summer activities', 'Vacation patterns']);
    } else if (month == 8 || month == 9) {
      factors.addAll(['Back-to-school', 'Educational needs']);
    }
    
    return factors;
  }
}