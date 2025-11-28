import '../models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductService {
  static const String _productsKey = 'stored_products';
  
  // Default products - only used if no products exist in storage
  static final List<Product> _defaultProducts = [
    Product(
      id: '1',
      name: 'Wireless Headphones',
      description: 'High-quality wireless headphones with noise cancellation',
      price: 199.99,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      category: 'Electronics',
      stock: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Product(
      id: '2',
      name: 'Smart Watch',
      description: 'Feature-rich smartwatch with health monitoring',
      price: 299.99,
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      category: 'Electronics',
      stock: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Product(
      id: '3',
      name: 'Running Shoes',
      description: 'Comfortable running shoes for all terrains',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      category: 'Fashion',
      stock: 30,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Product(
      id: '4',
      name: 'Coffee Maker',
      description: 'Automatic coffee maker with programmable timer',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      category: 'Home',
      stock: 20,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Product(
      id: '5',
      name: 'Bluetooth Speaker',
      description: 'Portable Bluetooth speaker with excellent sound quality',
      price: 79.99,
      imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
      category: 'Electronics',
      stock: 40,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Load products from storage
  Future<List<Product>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getStringList(_productsKey);
      
      if (productsJson != null && productsJson.isNotEmpty) {
        // Load saved products from storage
        final products = productsJson
            .map((json) => Product.fromJson(jsonDecode(json)))
            .toList();
        
        print('Loaded ${products.length} products from storage');
        return products;
      } else {
        // First time - save default products to storage
        print('No saved products found, initializing with defaults');
        await _saveProducts(_defaultProducts);
        return List.from(_defaultProducts);
      }
    } catch (e) {
      print('Error loading products: $e');
      // Fallback to default products
      return List.from(_defaultProducts);
    }
  }

  // Save products to storage
  Future<void> _saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = products
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      
      await prefs.setStringList(_productsKey, productsJson);
      print('Saved ${products.length} products to storage');
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  Future<Product?> getProductById(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final products = await getProducts();
    return products.where((product) => product.category == category).toList();
  }

  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await _saveProducts(products);
  }

  Future<void> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      await _saveProducts(products);
    }
  }

  Future<void> deleteProduct(String productId) async {
    final products = await getProducts();
    products.removeWhere((product) => product.id == productId);
    await _saveProducts(products);
  }

  Future<List<String>> getCategories() async {
    final products = await getProducts();
    return products.map((product) => product.category).toSet().toList();
  }
}