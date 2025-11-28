class StockPrediction {
  final String productId;
  final String productName;
  final int currentStock;
  final int predictedDemand;
  final int recommendedStock;
  final double confidenceLevel;
  final DateTime predictionDate;
  final List<StockTrend> trends;
  final StockStatus status;

  StockPrediction({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.predictedDemand,
    required this.recommendedStock,
    required this.confidenceLevel,
    required this.predictionDate,
    required this.trends,
    required this.status,
  });

  factory StockPrediction.fromJson(Map<String, dynamic> json) {
    return StockPrediction(
      productId: json['productId'],
      productName: json['productName'],
      currentStock: json['currentStock'],
      predictedDemand: json['predictedDemand'],
      recommendedStock: json['recommendedStock'],
      confidenceLevel: json['confidenceLevel'].toDouble(),
      predictionDate: DateTime.parse(json['predictionDate']),
      trends: (json['trends'] as List)
          .map((trend) => StockTrend.fromJson(trend))
          .toList(),
      status: StockStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockStatus.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'currentStock': currentStock,
      'predictedDemand': predictedDemand,
      'recommendedStock': recommendedStock,
      'confidenceLevel': confidenceLevel,
      'predictionDate': predictionDate.toIso8601String(),
      'trends': trends.map((trend) => trend.toJson()).toList(),
      'status': status.name,
    };
  }
}

class DemandPrediction {
  final String productId;
  final String productName;
  final String categoryId;
  final List<DemandForecast> weeklyForecast;
  final List<DemandForecast> monthlyForecast;
  final List<SeasonalPattern> seasonalPatterns;
  final double averageDailyDemand;
  final double peakDemandFactor;
  final DateTime lastUpdated;

  DemandPrediction({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.weeklyForecast,
    required this.monthlyForecast,
    required this.seasonalPatterns,
    required this.averageDailyDemand,
    required this.peakDemandFactor,
    required this.lastUpdated,
  });

  factory DemandPrediction.fromJson(Map<String, dynamic> json) {
    return DemandPrediction(
      productId: json['productId'],
      productName: json['productName'],
      categoryId: json['categoryId'],
      weeklyForecast: (json['weeklyForecast'] as List)
          .map((forecast) => DemandForecast.fromJson(forecast))
          .toList(),
      monthlyForecast: (json['monthlyForecast'] as List)
          .map((forecast) => DemandForecast.fromJson(forecast))
          .toList(),
      seasonalPatterns: (json['seasonalPatterns'] as List)
          .map((pattern) => SeasonalPattern.fromJson(pattern))
          .toList(),
      averageDailyDemand: json['averageDailyDemand'].toDouble(),
      peakDemandFactor: json['peakDemandFactor'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'categoryId': categoryId,
      'weeklyForecast': weeklyForecast.map((f) => f.toJson()).toList(),
      'monthlyForecast': monthlyForecast.map((f) => f.toJson()).toList(),
      'seasonalPatterns': seasonalPatterns.map((p) => p.toJson()).toList(),
      'averageDailyDemand': averageDailyDemand,
      'peakDemandFactor': peakDemandFactor,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class StockTrend {
  final DateTime date;
  final int stock;
  final int sales;
  final TrendDirection direction;

  StockTrend({
    required this.date,
    required this.stock,
    required this.sales,
    required this.direction,
  });

  factory StockTrend.fromJson(Map<String, dynamic> json) {
    return StockTrend(
      date: DateTime.parse(json['date']),
      stock: json['stock'],
      sales: json['sales'],
      direction: TrendDirection.values.firstWhere(
        (e) => e.name == json['direction'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'stock': stock,
      'sales': sales,
      'direction': direction.name,
    };
  }
}

class DemandForecast {
  final DateTime date;
  final double predictedDemand;
  final double confidence;
  final List<String> influencingFactors;

  DemandForecast({
    required this.date,
    required this.predictedDemand,
    required this.confidence,
    required this.influencingFactors,
  });

  factory DemandForecast.fromJson(Map<String, dynamic> json) {
    return DemandForecast(
      date: DateTime.parse(json['date']),
      predictedDemand: json['predictedDemand'].toDouble(),
      confidence: json['confidence'].toDouble(),
      influencingFactors: List<String>.from(json['influencingFactors']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'predictedDemand': predictedDemand,
      'confidence': confidence,
      'influencingFactors': influencingFactors,
    };
  }
}

class SeasonalPattern {
  final String season;
  final double demandMultiplier;
  final List<String> peakMonths;
  final String description;

  SeasonalPattern({
    required this.season,
    required this.demandMultiplier,
    required this.peakMonths,
    required this.description,
  });

  factory SeasonalPattern.fromJson(Map<String, dynamic> json) {
    return SeasonalPattern(
      season: json['season'],
      demandMultiplier: json['demandMultiplier'].toDouble(),
      peakMonths: List<String>.from(json['peakMonths']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'demandMultiplier': demandMultiplier,
      'peakMonths': peakMonths,
      'description': description,
    };
  }
}

class PredictionAnalytics {
  final int totalProducts;
  final int lowStockAlerts;
  final int overStockAlerts;
  final double averageAccuracy;
  final Map<String, int> categoryDemand;
  final List<TopSellingPrediction> topSellingPredictions;
  final DateTime lastAnalysisDate;

  PredictionAnalytics({
    required this.totalProducts,
    required this.lowStockAlerts,
    required this.overStockAlerts,
    required this.averageAccuracy,
    required this.categoryDemand,
    required this.topSellingPredictions,
    required this.lastAnalysisDate,
  });

  factory PredictionAnalytics.fromJson(Map<String, dynamic> json) {
    return PredictionAnalytics(
      totalProducts: json['totalProducts'],
      lowStockAlerts: json['lowStockAlerts'],
      overStockAlerts: json['overStockAlerts'],
      averageAccuracy: json['averageAccuracy'].toDouble(),
      categoryDemand: Map<String, int>.from(json['categoryDemand']),
      topSellingPredictions: (json['topSellingPredictions'] as List)
          .map((item) => TopSellingPrediction.fromJson(item))
          .toList(),
      lastAnalysisDate: DateTime.parse(json['lastAnalysisDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'lowStockAlerts': lowStockAlerts,
      'overStockAlerts': overStockAlerts,
      'averageAccuracy': averageAccuracy,
      'categoryDemand': categoryDemand,
      'topSellingPredictions': 
          topSellingPredictions.map((item) => item.toJson()).toList(),
      'lastAnalysisDate': lastAnalysisDate.toIso8601String(),
    };
  }
}

class TopSellingPrediction {
  final String productId;
  final String productName;
  final double predictedSales;
  final double revenueImpact;

  TopSellingPrediction({
    required this.productId,
    required this.productName,
    required this.predictedSales,
    required this.revenueImpact,
  });

  factory TopSellingPrediction.fromJson(Map<String, dynamic> json) {
    return TopSellingPrediction(
      productId: json['productId'],
      productName: json['productName'],
      predictedSales: json['predictedSales'].toDouble(),
      revenueImpact: json['revenueImpact'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'predictedSales': predictedSales,
      'revenueImpact': revenueImpact,
    };
  }
}

enum StockStatus {
  criticalLow,
  low,
  normal,
  high,
  overStock,
}

enum TrendDirection {
  increasing,
  decreasing,
  stable,
  volatile,
}

// Extension methods for better UI display
extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.criticalLow:
        return 'Critical Low';
      case StockStatus.low:
        return 'Low Stock';
      case StockStatus.normal:
        return 'Normal';
      case StockStatus.high:
        return 'High Stock';
      case StockStatus.overStock:
        return 'Overstock';
    }
  }

  String get colorCode {
    switch (this) {
      case StockStatus.criticalLow:
        return '#FF0000'; // Red
      case StockStatus.low:
        return '#FF8C00'; // Orange
      case StockStatus.normal:
        return '#32CD32'; // Green
      case StockStatus.high:
        return '#1E90FF'; // Blue
      case StockStatus.overStock:
        return '#8A2BE2'; // Purple
    }
  }
}

extension TrendDirectionExtension on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.decreasing:
        return 'Decreasing';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.volatile:
        return 'Volatile';
    }
  }

  String get icon {
    switch (this) {
      case TrendDirection.increasing:
        return '📈';
      case TrendDirection.decreasing:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
      case TrendDirection.volatile:
        return '📊';
    }
  }
}