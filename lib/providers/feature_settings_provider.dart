import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureSettingsProvider extends ChangeNotifier {
  bool _customerFeedEnabled = true;
  bool _isLoading = false;

  // Getters
  bool get customerFeedEnabled => _customerFeedEnabled;
  bool get isLoading => _isLoading;

  FeatureSettingsProvider() {
    _loadSettings();
  }

  // Load settings from local storage
  Future<void> _loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _customerFeedEnabled = prefs.getBool('customer_feed_enabled') ?? true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading feature settings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save settings to local storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('customer_feed_enabled', _customerFeedEnabled);
    } catch (e) {
      debugPrint('Error saving feature settings: $e');
    }
  }

  // Toggle customer feed feature
  Future<void> toggleCustomerFeed(bool enabled) async {
    _customerFeedEnabled = enabled;
    notifyListeners();
    await _saveSettings();
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    _customerFeedEnabled = true;
    notifyListeners();
    await _saveSettings();
  }
}
