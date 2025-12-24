class AnimePosterBotConfig {
  final bool isEnabled;
  final int uploadIntervalSeconds;
  final double smallPosterPrice;
  final double largePosterPrice;
  final String category;
  final int totalProductsUploaded;
  final DateTime? lastUploadTime;
  final bool useGeminiGeneration; // true = generate with Gemini, false = fetch from web

  AnimePosterBotConfig({
    this.isEnabled = false,
    this.uploadIntervalSeconds = 10,
    this.smallPosterPrice = 659.0,
    this.largePosterPrice = 869.0,
    this.category = 'Anime Posters',
    this.totalProductsUploaded = 0,
    this.lastUploadTime,
    this.useGeminiGeneration = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'uploadIntervalSeconds': uploadIntervalSeconds,
      'smallPosterPrice': smallPosterPrice,
      'largePosterPrice': largePosterPrice,
      'category': category,
      'totalProductsUploaded': totalProductsUploaded,
      'lastUploadTime': lastUploadTime?.toIso8601String(),
      'useGeminiGeneration': useGeminiGeneration,
    };
  }

  factory AnimePosterBotConfig.fromJson(Map<String, dynamic> json) {
    return AnimePosterBotConfig(
      isEnabled: json['isEnabled'] ?? false,
      uploadIntervalSeconds: json['uploadIntervalSeconds'] ?? 10,
      smallPosterPrice: (json['smallPosterPrice'] ?? 659.0).toDouble(),
      largePosterPrice: (json['largePosterPrice'] ?? 869.0).toDouble(),
      category: json['category'] ?? 'Anime Posters',
      totalProductsUploaded: json['totalProductsUploaded'] ?? 0,
      lastUploadTime: json['lastUploadTime'] != null
          ? DateTime.parse(json['lastUploadTime'])
          : null,
      useGeminiGeneration: json['useGeminiGeneration'] ?? true,
    );
  }

  AnimePosterBotConfig copyWith({
    bool? isEnabled,
    int? uploadIntervalSeconds,
    double? smallPosterPrice,
    double? largePosterPrice,
    String? category,
    int? totalProductsUploaded,
    DateTime? lastUploadTime,
    bool? useGeminiGeneration,
  }) {
    return AnimePosterBotConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      uploadIntervalSeconds: uploadIntervalSeconds ?? this.uploadIntervalSeconds,
      smallPosterPrice: smallPosterPrice ?? this.smallPosterPrice,
      largePosterPrice: largePosterPrice ?? this.largePosterPrice,
      category: category ?? this.category,
      totalProductsUploaded: totalProductsUploaded ?? this.totalProductsUploaded,
      lastUploadTime: lastUploadTime ?? this.lastUploadTime,
      useGeminiGeneration: useGeminiGeneration ?? this.useGeminiGeneration,
    );
  }
}
