import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/promotional_banner.dart';

class PromotionalBannerProvider with ChangeNotifier {
  List<PromotionalBanner> _banners = [];
  bool _isLoading = false;

  List<PromotionalBanner> get banners => _banners;
  List<PromotionalBanner> get activeBanners => 
      _banners.where((b) => b.isCurrentlyActive).toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
  bool get isLoading => _isLoading;

  PromotionalBannerProvider() {
    loadBanners();
  }

  Future<void> loadBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final bannersJson = prefs.getString('promotional_banners');
      
      if (bannersJson != null && bannersJson.isNotEmpty) {
        final List<dynamic> bannersList = jsonDecode(bannersJson);
        _banners = bannersList
            .map((json) => PromotionalBanner.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        _banners = [];
      }
    } catch (e) {
      debugPrint('Error loading promotional banners: $e');
      _banners = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> _saveBanners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bannersList = _banners.map((banner) => banner.toJson()).toList();
      final bannersJson = jsonEncode(bannersList);
      return await prefs.setString('promotional_banners', bannersJson);
    } catch (e) {
      debugPrint('Error saving promotional banners: $e');
      return false;
    }
  }

  Future<bool> addBanner(PromotionalBanner banner) async {
    try {
      _banners.add(banner);
      final saved = await _saveBanners();
      if (saved) {
        notifyListeners();
        return true;
      } else {
        _banners.removeLast();
        return false;
      }
    } catch (e) {
      debugPrint('Error adding banner: $e');
      return false;
    }
  }

  Future<bool> updateBanner(PromotionalBanner banner) async {
    try {
      final index = _banners.indexWhere((b) => b.id == banner.id);
      if (index == -1) return false;

      _banners[index] = banner;
      final saved = await _saveBanners();
      if (saved) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating banner: $e');
      return false;
    }
  }

  Future<bool> deleteBanner(String bannerId) async {
    try {
      _banners.removeWhere((b) => b.id == bannerId);
      final saved = await _saveBanners();
      if (saved) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting banner: $e');
      return false;
    }
  }

  Future<bool> toggleBannerStatus(String bannerId) async {
    try {
      final index = _banners.indexWhere((b) => b.id == bannerId);
      if (index == -1) return false;

      _banners[index] = _banners[index].copyWith(
        isActive: !_banners[index].isActive,
      );
      
      final saved = await _saveBanners();
      if (saved) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling banner status: $e');
      return false;
    }
  }

  List<PromotionalBanner> getBannersForPage(String page, {String? category}) {
    return activeBanners
        .where((banner) => banner.shouldShowOnPage(page, category: category))
        .toList();
  }
}
