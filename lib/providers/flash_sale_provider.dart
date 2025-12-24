import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flash_sale.dart';
import '../models/product.dart';

class FlashSaleProvider extends ChangeNotifier {
  List<FlashSale> _flashSales = [];
  bool _isLoading = false;
  Timer? _countdownTimer;

  // Getters
  List<FlashSale> get flashSales => _flashSales;
  bool get isLoading => _isLoading;

  // Get active flash sales
  List<FlashSale> get activeFlashSales {
    return _flashSales.where((sale) => sale.isLive).toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  // Get upcoming flash sales
  List<FlashSale> get upcomingFlashSales {
    return _flashSales.where((sale) => sale.isUpcoming).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get expired flash sales
  List<FlashSale> get expiredFlashSales {
    return _flashSales.where((sale) => sale.isExpired).toList()
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
  }

  FlashSaleProvider() {
    _initializeTimer();
    loadFlashSales();
  }

  void _initializeTimer() {
    // Update every second for countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Load flash sales from storage
  Future<void> loadFlashSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final flashSalesJson = prefs.getString('flash_sales');
      
      if (flashSalesJson != null) {
        final List<dynamic> decoded = json.decode(flashSalesJson);
        _flashSales = decoded.map((item) => FlashSale.fromJson(item)).toList();
      } else {
        // Initialize with sample flash sales
        _initializeSampleFlashSales();
      }
    } catch (e) {
      debugPrint('Error loading flash sales: $e');
      _initializeSampleFlashSales();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save flash sales to storage
  Future<void> _saveFlashSales() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final flashSalesJson = json.encode(_flashSales.map((sale) => sale.toJson()).toList());
      await prefs.setString('flash_sales', flashSalesJson);
    } catch (e) {
      debugPrint('Error saving flash sales: $e');
    }
  }

  // Initialize sample flash sales
  void _initializeSampleFlashSales() {
    final now = DateTime.now();
    _flashSales = [
      FlashSale(
        id: 'flash_1',
        title: 'Weekend Mega Sale',
        description: 'Get up to 50% off on electronics and gadgets!',
        imageUrl: 'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=800&h=400&fit=crop',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 22)),
        discountPercentage: 50,
        maxDiscountAmount: 500.0,
        productIds: ['1', '2', '3'],
        categoryIds: ['Electronics'],
        createdAt: now,
        updatedAt: now,
        maxItems: 100,
        soldItems: 25,
        bannerColor: '#FF6B6B',
        type: 'percentage',
      ),
      FlashSale(
        id: 'flash_2',
        title: 'Fashion Flash Sale',
        description: 'Trendy clothes at unbeatable prices!',
        imageUrl: 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=800&h=400&fit=crop',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 26)),
        discountPercentage: 30,
        productIds: ['3', '4'],
        categoryIds: ['Fashion'],
        createdAt: now,
        updatedAt: now,
        maxItems: 200,
        soldItems: 15,
        bannerColor: '#4ECDC4',
        type: 'percentage',
      ),
      FlashSale(
        id: 'flash_3',
        title: 'Early Bird Special',
        description: 'Limited time offer for early shoppers!',
        imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 6)),
        discountPercentage: 40,
        maxDiscountAmount: 300.0,
        productIds: ['1', '4', '5'],
        categoryIds: ['Home'],
        createdAt: now,
        updatedAt: now,
        maxItems: 50,
        soldItems: 0,
        bannerColor: '#FFE66D',
        type: 'percentage',
      ),
    ];
    _saveFlashSales();
  }

  // Create new flash sale
  Future<bool> createFlashSale(FlashSale flashSale) async {
    try {
      _flashSales.add(flashSale);
      await _saveFlashSales();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating flash sale: $e');
      return false;
    }
  }

  // Update flash sale
  Future<bool> updateFlashSale(FlashSale updatedFlashSale) async {
    try {
      final index = _flashSales.indexWhere((sale) => sale.id == updatedFlashSale.id);
      if (index != -1) {
        _flashSales[index] = updatedFlashSale;
        await _saveFlashSales();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating flash sale: $e');
      return false;
    }
  }

  // Delete flash sale
  Future<bool> deleteFlashSale(String flashSaleId) async {
    try {
      _flashSales.removeWhere((sale) => sale.id == flashSaleId);
      await _saveFlashSales();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting flash sale: $e');
      return false;
    }
  }

  // Toggle flash sale status
  Future<bool> toggleFlashSaleStatus(String flashSaleId) async {
    try {
      final index = _flashSales.indexWhere((sale) => sale.id == flashSaleId);
      if (index != -1) {
        _flashSales[index] = _flashSales[index].copyWith(
          isActive: !_flashSales[index].isActive,
          updatedAt: DateTime.now(),
        );
        await _saveFlashSales();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling flash sale status: $e');
      return false;
    }
  }

  // Get flash sale by ID
  FlashSale? getFlashSaleById(String id) {
    try {
      return _flashSales.firstWhere((sale) => sale.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if product is on flash sale
  FlashSale? getActiveFlashSaleForProduct(String productId) {
    for (final sale in activeFlashSales) {
      if (sale.productIds.contains(productId)) {
        return sale;
      }
    }
    return null;
  }

  // Check if category is on flash sale
  FlashSale? getActiveFlashSaleForCategory(String categoryId) {
    for (final sale in activeFlashSales) {
      if (sale.categoryIds.contains(categoryId)) {
        return sale;
      }
    }
    return null;
  }

  // Calculate discounted price for product
  double calculateDiscountedPrice(Product product) {
    // Check for product-specific flash sale
    final productFlashSale = getActiveFlashSaleForProduct(product.id);
    if (productFlashSale != null && productFlashSale.hasItemsAvailable) {
      return _applyFlashSaleDiscount(product.price, productFlashSale);
    }

    // Check for category flash sale
    final categoryFlashSale = getActiveFlashSaleForCategory(product.category);
    if (categoryFlashSale != null && categoryFlashSale.hasItemsAvailable) {
      return _applyFlashSaleDiscount(product.price, categoryFlashSale);
    }

    return product.price;
  }

  // Apply flash sale discount
  double _applyFlashSaleDiscount(double originalPrice, FlashSale flashSale) {
    double discount = 0.0;
    
    switch (flashSale.type) {
      case 'percentage':
        discount = originalPrice * (flashSale.discountPercentage / 100);
        break;
      case 'fixed_amount':
        discount = flashSale.discountPercentage.toDouble(); // Using discountPercentage as fixed amount
        break;
    }

    // Apply maximum discount limit
    if (flashSale.maxDiscountAmount != null && discount > flashSale.maxDiscountAmount!) {
      discount = flashSale.maxDiscountAmount!;
    }

    return originalPrice - discount;
  }

  // Get discount amount for product
  double getDiscountAmount(Product product) {
    final originalPrice = product.price;
    final discountedPrice = calculateDiscountedPrice(product);
    return originalPrice - discountedPrice;
  }

  // Record flash sale purchase
  Future<void> recordFlashSalePurchase(String flashSaleId, int quantity) async {
    try {
      final index = _flashSales.indexWhere((sale) => sale.id == flashSaleId);
      if (index != -1) {
        _flashSales[index] = _flashSales[index].copyWith(
          soldItems: _flashSales[index].soldItems + quantity,
          updatedAt: DateTime.now(),
        );
        await _saveFlashSales();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error recording flash sale purchase: $e');
    }
  }

  // Get flash sales by status
  List<FlashSale> getFlashSalesByStatus(String status) {
    switch (status) {
      case 'active':
        return activeFlashSales;
      case 'upcoming':
        return upcomingFlashSales;
      case 'expired':
        return expiredFlashSales;
      default:
        return [];
    }
  }

  // Get flash sale statistics
  Map<String, dynamic> getFlashSaleStats() {
    final total = _flashSales.length;
    final active = activeFlashSales.length;
    final upcoming = upcomingFlashSales.length;
    final expired = expiredFlashSales.length;
    
    int totalSoldItems = 0;
    double totalRevenue = 0.0;
    
    for (final sale in _flashSales) {
      totalSoldItems += sale.soldItems;
      // Note: Revenue calculation would need product prices
    }

    return {
      'total': total,
      'active': active,
      'upcoming': upcoming,
      'expired': expired,
      'totalSoldItems': totalSoldItems,
      'totalRevenue': totalRevenue,
    };
  }

  // Format countdown time
  String formatCountdown(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) {
      return 'Expired';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Reset flash sales data (for debugging)
  Future<void> resetFlashSalesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('flash_sales');
      _flashSales.clear();
      _initializeSampleFlashSales();
      notifyListeners();
      debugPrint('Flash sales data reset successfully');
    } catch (e) {
      debugPrint('Error resetting flash sales data: $e');
    }
  }
}