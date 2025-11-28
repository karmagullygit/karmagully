import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryService {
  static const String _storageKey = 'app_categories';
  
  // Default categories
  static final List<Category> _defaultCategories = [
    Category(
      id: '1',
      name: 'Electronics',
      description: 'Mobile phones, laptops, gadgets',
      colorCode: '#2196F3',
      imageUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
    ),
    Category(
      id: '2',
      name: 'Fashion',
      description: 'Clothing, shoes, accessories',
      colorCode: '#4CAF50',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
    ),
    Category(
      id: '3',
      name: 'Home',
      description: 'Furniture, decor, appliances',
      colorCode: '#FF9800',
      imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400',
    ),
    Category(
      id: '4',
      name: 'Sports',
      description: 'Sports equipment and accessories',
      colorCode: '#F44336',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
    ),
    Category(
      id: '5',
      name: 'Books',
      description: 'Books, magazines, stationery',
      colorCode: '#9C27B0',
      imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
    ),
    Category(
      id: '6',
      name: 'Health',
      description: 'Healthcare and beauty products',
      colorCode: '#E91E63',
      imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
    ),
  ];

  // Get all categories
  static Future<List<Category>> getAllCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_storageKey);
      
      if (categoriesJson != null) {
        final List<dynamic> decoded = json.decode(categoriesJson);
        return decoded.map((item) => Category.fromJson(item)).toList();
      } else {
        // First time - save default categories
        await _saveCategories(_defaultCategories);
        return _defaultCategories;
      }
    } catch (e) {
      print('Error loading categories: $e');
      return _defaultCategories;
    }
  }

  // Save categories to storage
  static Future<void> _saveCategories(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(categories.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, categoriesJson);
    } catch (e) {
      print('Error saving categories: $e');
    }
  }

  // Add new category
  static Future<void> addCategory(Category category) async {
    final categories = await getAllCategories();
    final newCategory = category.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    categories.add(newCategory);
    await _saveCategories(categories);
  }

  // Update existing category
  static Future<void> updateCategory(Category category) async {
    final categories = await getAllCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category.copyWith(updatedAt: DateTime.now());
      await _saveCategories(categories);
    }
  }

  // Delete category
  static Future<void> deleteCategory(String categoryId) async {
    final categories = await getAllCategories();
    categories.removeWhere((c) => c.id == categoryId);
    await _saveCategories(categories);
  }

  // Search categories
  static Future<List<Category>> searchCategories(String query) async {
    final categories = await getAllCategories();
    if (query.isEmpty) return categories;
    
    return categories.where((category) =>
      category.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Clear all categories (for testing)
  static Future<void> clearAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}