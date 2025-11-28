import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/login_screen.dart';
import '../screens/customer/product_detail_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../screens/customer/orders_screen.dart';
import '../screens/customer/wishlist_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/product_management_screen.dart';
import '../screens/admin/order_management_screen.dart';
import '../screens/admin/order_detail_screen.dart';
import '../screens/admin/ad_management_screen.dart';
import '../screens/admin/ai_marketing_screen.dart';

class NavigationHelper {
  static bool _isNavigating = false;
  
  /// Safe pop method that prevents navigation issues
  static void safePop(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;
    
    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        // Navigate to appropriate home screen
        _navigateToHome(context);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      _navigateToHome(context);
    } finally {
      // Reset flag after a delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _isNavigating = false;
      });
    }
  }
  
  /// Navigate to home screen based on user type
  static void _navigateToHome(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAdmin) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }
  
  /// Navigate to product detail
  static void navigateToProduct(BuildContext context, String productId) {
    if (_isNavigating) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }
  
  /// Navigate to cart
  static void navigateToCart(BuildContext context) {
    if (_isNavigating) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }
  
  /// Navigate to checkout
  static void navigateToCheckout(BuildContext context) {
    if (_isNavigating) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }
  
  /// Navigate to admin products
  static void navigateToAdminProducts(BuildContext context) {
    if (_isNavigating) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProductManagementScreen()),
    );
  }
  
  /// Navigate to login
  static void navigateToLogin(BuildContext context) {
    if (_isNavigating) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
  
  /// Navigate to home
  static void navigateToHome(BuildContext context) {
    if (_isNavigating) return;
    _navigateToHome(context);
  }
  
  /// Navigate to admin dashboard
  static void navigateToAdmin(BuildContext context) {
    if (_isNavigating) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AdminDashboard()),
      (route) => false,
    );
  }
  
  /// Navigate to order management
  static void navigateToOrderManagement(BuildContext context) {
    if (_isNavigating) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const OrderManagementScreen()),
    );
  }
  
  /// Navigate to order detail
  static void navigateToOrderDetail(BuildContext context, String orderId) {
    if (_isNavigating) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: orderId),
      ),
    );
  }
  
  /// Check if we can safely pop
  static bool canPop(BuildContext context) {
    try {
      return Navigator.of(context).canPop();
    } catch (e) {
      return false;
    }
  }
  
  /// Navigate to product detail screen
  static void navigateToProductDetail(BuildContext context, String productId) {
    if (_isNavigating) return;
    _isNavigating = true;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: productId),
        ),
      ).then((_) => _isNavigating = false);
    } catch (e) {
      _isNavigating = false;
      debugPrint('Navigation error: $e');
    }
  }
  
  /// Navigate to advertisement management screen
  static void navigateToAdManagement(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AdManagementScreen(),
        ),
      ).then((_) => _isNavigating = false);
    } catch (e) {
      _isNavigating = false;
      debugPrint('Navigation error: $e');
    }
  }
  
  /// Safe pop for dialogs
  static void safePopDialog(BuildContext context) {
    try {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Dialog pop error: $e');
    }
  }

  /// Navigate to profile screen
  static void navigateToProfile(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      ).then((_) => _isNavigating = false);
    } catch (e) {
      _isNavigating = false;
      debugPrint('Navigation error: $e');
    }
  }

  /// Navigate to orders screen
  static void navigateToOrders(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const OrdersScreen()),
      ).then((_) => _isNavigating = false);
    } catch (e) {
      _isNavigating = false;
      debugPrint('Navigation error: $e');
    }
  }

  /// Navigate to AI Marketing Assistant screen
  static void navigateToAIMarketing(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AIMarketingScreen()),
      ).then((_) => _isNavigating = false);
    } catch (e) {
      _isNavigating = false;
      debugPrint('Navigation error: $e');
    }
  }

  /// Navigate to wishlist screen
  static void navigateToWishlist(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const WishlistScreen()),
      ).then((_) => _isNavigating = false);
    } catch (e) {
      _isNavigating = false;
      debugPrint('Navigation error: $e');
    }
  }
}