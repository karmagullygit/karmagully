import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_poster_bot_config.dart';
import '../services/anime_poster_bot_service.dart';
import 'product_provider.dart';

class AnimePosterBotProvider extends ChangeNotifier {
  late AnimePosterBotService _botService;
  AnimePosterBotConfig _config = AnimePosterBotConfig();
  bool _isInitialized = false;

  AnimePosterBotConfig get config => _config;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(ProductProvider productProvider) async {
    if (_isInitialized) return;
    
    _botService = AnimePosterBotService(productProvider);
    await loadConfig();
    _botService.updateConfig(_config);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('anime_poster_bot_config');
      
      if (configJson != null) {
        final Map<String, dynamic> data = {};
        configJson.split('&').forEach((pair) {
          final kv = pair.split('=');
          if (kv.length == 2) {
            data[kv[0]] = kv[1];
          }
        });
        
        _config = AnimePosterBotConfig(
          isEnabled: data['isEnabled'] == 'true',
          uploadIntervalSeconds: int.tryParse(data['uploadIntervalSeconds'] ?? '10') ?? 10,
          smallPosterPrice: double.tryParse(data['smallPosterPrice'] ?? '659.0') ?? 659.0,
          largePosterPrice: double.tryParse(data['largePosterPrice'] ?? '869.0') ?? 869.0,
          category: data['category'] ?? 'Anime Posters',
          totalProductsUploaded: int.tryParse(data['totalProductsUploaded'] ?? '0') ?? 0,
          lastUploadTime: data['lastUploadTime'] != null 
              ? DateTime.tryParse(data['lastUploadTime']!)
              : null,
          useGeminiGeneration: data['useGeminiGeneration'] == 'true',
        );
      }
    } catch (e) {
      print('Error loading anime bot config: $e');
    }
  }

  Future<void> saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configData = 'isEnabled=${_config.isEnabled}&'
          'uploadIntervalSeconds=${_config.uploadIntervalSeconds}&'
          'smallPosterPrice=${_config.smallPosterPrice}&'
          'largePosterPrice=${_config.largePosterPrice}&'
          'category=${_config.category}&'
          'totalProductsUploaded=${_config.totalProductsUploaded}&'
          'lastUploadTime=${_config.lastUploadTime?.toIso8601String() ?? ''}&'
          'useGeminiGeneration=${_config.useGeminiGeneration}';
      
      await prefs.setString('anime_poster_bot_config', configData);
    } catch (e) {
      print('Error saving anime bot config: $e');
    }
  }

  Future<void> toggleBot(bool enabled) async {
    _config = _config.copyWith(isEnabled: enabled);
    _botService.updateConfig(_config);
    await saveConfig();
    notifyListeners();
  }

  Future<void> updateInterval(int seconds) async {
    _config = _config.copyWith(uploadIntervalSeconds: seconds);
    if (_config.isEnabled) {
      _botService.updateConfig(_config);
    }
    await saveConfig();
    notifyListeners();
  }

  Future<void> updatePrices(double smallPrice, double largePrice) async {
    _config = _config.copyWith(
      smallPosterPrice: smallPrice,
      largePosterPrice: largePrice,
    );
    await saveConfig();
    notifyListeners();
  }

  Future<void> toggleGenerationMode(bool useGemini) async {
    _config = _config.copyWith(useGeminiGeneration: useGemini);
    _botService.updateConfig(_config);
    await saveConfig();
    notifyListeners();
  }

  void updateStats() {
    _config = _botService.config;
    notifyListeners();
  }

  @override
  void dispose() {
    _botService.dispose();
    super.dispose();
  }
}
