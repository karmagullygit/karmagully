import 'package:flutter/foundation.dart';

class WishlistProvider extends ChangeNotifier {
  final List<String> _wishlistItems = [];

  List<String> get wishlistItems => List.unmodifiable(_wishlistItems);
  
  int get itemCount => _wishlistItems.length;
  
  bool isInWishlist(String productId) {
    return _wishlistItems.contains(productId);
  }
  
  void addToWishlist(String productId) {
    if (!_wishlistItems.contains(productId)) {
      _wishlistItems.add(productId);
      notifyListeners();
    }
  }
  
  void removeFromWishlist(String productId) {
    _wishlistItems.remove(productId);
    notifyListeners();
  }
  
  void toggleWishlist(String productId) {
    if (isInWishlist(productId)) {
      removeFromWishlist(productId);
    } else {
      addToWishlist(productId);
    }
  }
  
  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}