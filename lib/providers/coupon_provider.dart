import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coupon.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CouponProvider extends ChangeNotifier {
  List<Coupon> _coupons = [];
  bool _isLoading = false;
  Coupon? _appliedCoupon;

  // Getters
  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;
  Coupon? get appliedCoupon => _appliedCoupon;

  // Get valid coupons
  List<Coupon> get validCoupons {
    return _coupons.where((coupon) => coupon.isValid).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  // Get expired coupons
  List<Coupon> get expiredCoupons {
    return _coupons.where((coupon) => coupon.isExpired).toList()
      ..sort((a, b) => b.expiryDate!.compareTo(a.expiryDate!));
  }

  // Get active coupons
  List<Coupon> get activeCoupons {
    return _coupons.where((coupon) => coupon.isActive && !coupon.isExpired).toList();
  }

  // Get inactive coupons
  List<Coupon> get inactiveCoupons {
    return _coupons.where((coupon) => !coupon.isActive).toList();
  }

  // Get all coupons
  List<Coupon> get allCoupons => _coupons;

  CouponProvider() {
    loadCoupons();
  }

  // Load coupons from storage
  Future<void> loadCoupons() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final couponsJson = prefs.getString('coupons');
      
      if (couponsJson != null) {
        final List<dynamic> decoded = json.decode(couponsJson);
        _coupons = decoded.map((item) => Coupon.fromJson(item)).toList();
      } else {
        // Initialize with sample coupons
        _initializeSampleCoupons();
      }
    } catch (e) {
      debugPrint('Error loading coupons: $e');
      _initializeSampleCoupons();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save coupons to storage
  Future<void> _saveCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final couponsJson = json.encode(_coupons.map((coupon) => coupon.toJson()).toList());
      await prefs.setString('coupons', couponsJson);
    } catch (e) {
      debugPrint('Error saving coupons: $e');
    }
  }

  // Initialize sample coupons
  void _initializeSampleCoupons() {
    final now = DateTime.now();
    _coupons = [
      Coupon(
        id: 'coupon_1',
        code: 'WELCOME20',
        title: 'Welcome Discount',
        description: 'Get 20% off on your first order!',
        type: 'percentage',
        value: 20.0,
        minimumOrderAmount: 50.0,
        maximumDiscountAmount: 100.0,
        expiryDate: now.add(const Duration(days: 30)),
        usageLimit: 1000,
        usedCount: 245,
        isFirstTimeOnly: true,
        createdAt: now,
        updatedAt: now,
        bannerColor: '#4CAF50',
      ),
      Coupon(
        id: 'coupon_2',
        code: 'SAVE50',
        title: 'Fixed ₹50 Off',
        description: 'Get ₹50 off on orders above ₹200',
        type: 'fixed_amount',
        value: 50.0,
        minimumOrderAmount: 200.0,
        expiryDate: now.add(const Duration(days: 15)),
        usageLimit: 500,
        usedCount: 123,
        createdAt: now,
        updatedAt: now,
        bannerColor: '#FF9800',
      ),
      Coupon(
        id: 'coupon_3',
        code: 'FREESHIP',
        title: 'Free Shipping',
        description: 'Free shipping on all orders!',
        type: 'free_shipping',
        value: 0.0,
        minimumOrderAmount: 100.0,
        expiryDate: now.add(const Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
        bannerColor: '#2196F3',
      ),
      Coupon(
        id: 'coupon_4',
        code: 'MEGA30',
        title: 'Mega Sale 30%',
        description: 'Huge discount on electronics!',
        type: 'percentage',
        value: 30.0,
        minimumOrderAmount: 300.0,
        maximumDiscountAmount: 500.0,
        expiryDate: now.add(const Duration(days: 3)),
        usageLimit: 100,
        usedCount: 67,
        applicableCategoryIds: ['electronics'],
        createdAt: now,
        updatedAt: now,
        bannerColor: '#E91E63',
      ),
      Coupon(
        id: 'coupon_5',
        code: 'EXPIRED10',
        title: 'Expired Coupon',
        description: 'This coupon has expired',
        type: 'percentage',
        value: 10.0,
        expiryDate: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
        bannerColor: '#757575',
      ),
    ];
    _saveCoupons();
  }

  // Create new coupon
  Future<bool> createCoupon(Coupon coupon) async {
    try {
      // Check if coupon code already exists
      if (_coupons.any((c) => c.code.toUpperCase() == coupon.code.toUpperCase())) {
        return false; // Duplicate code
      }
      
      _coupons.add(coupon);
      await _saveCoupons();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating coupon: $e');
      return false;
    }
  }

  // Add coupon (alias for createCoupon for compatibility)
  Future<void> addCoupon(Coupon coupon) async {
    final success = await createCoupon(coupon);
    if (!success) {
      throw Exception('Failed to create coupon - code may already exist');
    }
  }

  // Update coupon
  Future<bool> updateCoupon(Coupon updatedCoupon) async {
    try {
      final index = _coupons.indexWhere((coupon) => coupon.id == updatedCoupon.id);
      if (index != -1) {
        // Check if code is unique (excluding current coupon)
        final existingCoupon = _coupons.firstWhere(
          (c) => c.code.toUpperCase() == updatedCoupon.code.toUpperCase() && c.id != updatedCoupon.id,
          orElse: () => updatedCoupon,
        );
        
        if (existingCoupon.id != updatedCoupon.id) {
          return false; // Duplicate code
        }
        
        _coupons[index] = updatedCoupon;
        await _saveCoupons();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating coupon: $e');
      return false;
    }
  }

  // Delete coupon
  Future<bool> deleteCoupon(String couponId) async {
    try {
      _coupons.removeWhere((coupon) => coupon.id == couponId);
      
      // Clear applied coupon if it was deleted
      if (_appliedCoupon?.id == couponId) {
        _appliedCoupon = null;
      }
      
      await _saveCoupons();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting coupon: $e');
      return false;
    }
  }

  // Toggle coupon status
  Future<bool> toggleCouponStatus(String couponId) async {
    try {
      final index = _coupons.indexWhere((coupon) => coupon.id == couponId);
      if (index != -1) {
        _coupons[index] = _coupons[index].copyWith(
          isActive: !_coupons[index].isActive,
          updatedAt: DateTime.now(),
        );
        await _saveCoupons();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling coupon status: $e');
      return false;
    }
  }

  // Validate and apply coupon
  Future<String?> applyCoupon(String code, List<CartItem> cartItems, String? userId) async {
    try {
      final coupon = _coupons.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
        orElse: () => throw Exception('Coupon not found'),
      );

      // Validate coupon
      final validationResult = _validateCoupon(coupon, cartItems, userId);
      if (validationResult != null) {
        return validationResult;
      }

      _appliedCoupon = coupon;
      notifyListeners();
      return null; // Success
    } catch (e) {
      return 'Invalid coupon code';
    }
  }

  // Validate coupon
  String? _validateCoupon(Coupon coupon, List<CartItem> cartItems, String? userId) {
    // Check if coupon is valid
    if (!coupon.isValid) {
      if (coupon.isExpired) return 'Coupon has expired';
      if (!coupon.isActive) return 'Coupon is not active';
      if (coupon.usageLimit != null && coupon.usedCount >= coupon.usageLimit!) {
        return 'Coupon usage limit reached';
      }
    }

    // Check user eligibility
    if (coupon.isFirstTimeOnly && userId != null) {
      // In a real app, you would check if user has made orders before
      // For now, we'll assume it's valid
    }

    if (coupon.allowedUserIds.isNotEmpty && (userId == null || !coupon.allowedUserIds.contains(userId))) {
      return 'You are not eligible for this coupon';
    }

    // Calculate total applicable amount
    double applicableAmount = 0.0;
    for (final item in cartItems) {
      if (_isCouponApplicableToProduct(coupon, item.product)) {
        applicableAmount += item.product.price * item.quantity;
      }
    }

    // Check minimum order amount
    if (coupon.minimumOrderAmount != null && applicableAmount < coupon.minimumOrderAmount!) {
      return 'Minimum order amount is ₹${coupon.minimumOrderAmount!.toStringAsFixed(0)}';
    }

    return null; // Valid
  }

  // Check if coupon is applicable to product
  bool _isCouponApplicableToProduct(Coupon coupon, Product product) {
    // Check if product is excluded
    if (coupon.excludedProductIds.contains(product.id)) return false;
    
    // Check if category is excluded
    if (coupon.excludedCategoryIds.contains(product.category)) return false;
    
    // If specific products are set, check if product is included
    if (coupon.applicableProductIds.isNotEmpty) {
      return coupon.applicableProductIds.contains(product.id);
    }
    
    // If specific categories are set, check if category is included
    if (coupon.applicableCategoryIds.isNotEmpty) {
      return coupon.applicableCategoryIds.contains(product.category);
    }
    
    // If no restrictions, applicable to all
    return true;
  }

  // Remove applied coupon
  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  // Calculate discount amount
  double calculateDiscount(List<CartItem> cartItems) {
    if (_appliedCoupon == null) return 0.0;

    double applicableAmount = 0.0;
    for (final item in cartItems) {
      if (_isCouponApplicableToProduct(_appliedCoupon!, item.product)) {
        applicableAmount += item.product.price * item.quantity;
      }
    }

    return _appliedCoupon!.calculateDiscount(applicableAmount);
  }

  // Record coupon usage
  Future<void> recordCouponUsage(String couponId) async {
    try {
      final index = _coupons.indexWhere((coupon) => coupon.id == couponId);
      if (index != -1) {
        _coupons[index] = _coupons[index].copyWith(
          usedCount: _coupons[index].usedCount + 1,
          updatedAt: DateTime.now(),
        );
        await _saveCoupons();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error recording coupon usage: $e');
    }
  }

  // Get coupon by code
  Coupon? getCouponByCode(String code) {
    try {
      return _coupons.firstWhere(
        (coupon) => coupon.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get coupon by ID
  Coupon? getCouponById(String id) {
    try {
      return _coupons.firstWhere((coupon) => coupon.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get available coupons for user
  List<Coupon> getAvailableCouponsForUser(String? userId, List<CartItem> cartItems) {
    final available = <Coupon>[];
    
    for (final coupon in validCoupons) {
      if (_validateCoupon(coupon, cartItems, userId) == null) {
        available.add(coupon);
      }
    }
    
    return available;
  }

  // Generate unique coupon code
  String generateCouponCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String code;
    do {
      code = '';
      for (int i = 0; i < 8; i++) {
        code += chars[(DateTime.now().millisecondsSinceEpoch + i) % chars.length];
      }
    } while (_coupons.any((c) => c.code == code));
    
    return code;
  }

  // Get coupon statistics
  Map<String, dynamic> getCouponStats() {
    final total = _coupons.length;
    final active = activeCoupons.length;
    final expired = expiredCoupons.length;
    final valid = validCoupons.length;
    
    int totalUsage = 0;
    double totalDiscountGiven = 0.0;
    
    for (final coupon in _coupons) {
      totalUsage += coupon.usedCount;
      // Note: Total discount calculation would need order history
    }

    return {
      'total': total,
      'active': active,
      'expired': expired,
      'valid': valid,
      'totalUsage': totalUsage,
      'totalDiscountGiven': totalDiscountGiven,
    };
  }
}