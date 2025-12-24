import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/product_bot_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  ProductBotService? _botService;
  
  List<Product> _products = [];
  
  // Set bot service (to be injected)
  void setBotService(ProductBotService botService) {
    _botService = botService;
  }
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = '';

  List<Product> get products => _filteredProducts.isEmpty && _searchQuery.isEmpty && _selectedCategory.isEmpty 
      ? _products 
      : _filteredProducts;
  
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _products = await _productService.getProducts();
      _applyFilters();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading products: $e');
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _filteredProducts = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      bool matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesCategory = _selectedCategory.isEmpty ||
          product.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    try {
      await _productService.addProduct(product);
      _products.add(product);
      _applyFilters();
      notifyListeners();
      
      // 🤖 Trigger bot to auto-post product to customer feed after 5 seconds
      if (_botService != null && product.isActive) {
        _botService!.autoPostProduct(product, delay: const Duration(seconds: 5));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding product: $e');
      }
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productService.updateProduct(product);
      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating product: $e');
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      _products.removeWhere((product) => product.id == productId);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting product: $e');
      }
    }
  }

  // Toggle featured status
  Future<void> toggleFeaturedStatus(String productId) async {
    try {
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final product = _products[productIndex];
        final updatedProduct = product.copyWith(isFeatured: !product.isFeatured);
        
        await _productService.updateProduct(updatedProduct);
        _products[productIndex] = updatedProduct;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling featured status: $e');
      }
    }
  }

  // Get featured products
  List<Product> get featuredProducts {
    return _products.where((product) => product.isFeatured && product.isActive).toList();
  }

  // Get products by section
  List<Product> getProductsBySection(String sectionId) {
    return _products.where((product) => 
      product.isActive && product.sectionIds.contains(sectionId)
    ).toList();
  }

  // Assign product to sections
  Future<void> assignProductToSections(String productId, List<String> sectionIds) async {
    try {
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final product = _products[productIndex];
        final updatedProduct = product.copyWith(sectionIds: sectionIds);
        
        await _productService.updateProduct(updatedProduct);
        _products[productIndex] = updatedProduct;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error assigning product to sections: $e');
      }
    }
  }

  // Toggle section assignment for a product
  Future<void> toggleProductSection(String productId, String sectionId) async {
    try {
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final product = _products[productIndex];
        final currentSections = List<String>.from(product.sectionIds);
        
        if (currentSections.contains(sectionId)) {
          currentSections.remove(sectionId);
        } else {
          currentSections.add(sectionId);
        }
        
        final updatedProduct = product.copyWith(sectionIds: currentSections);
        await _productService.updateProduct(updatedProduct);
        _products[productIndex] = updatedProduct;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling product section: $e');
      }
    }
  }
}
