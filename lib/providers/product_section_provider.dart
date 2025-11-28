import 'package:flutter/foundation.dart';
import '../models/product_section.dart';
import '../services/product_section_service.dart';

class ProductSectionProvider extends ChangeNotifier {
  final ProductSectionService _sectionService = ProductSectionService();
  List<ProductSection> _sections = [];
  bool _isLoading = false;

  List<ProductSection> get sections => _sections;
  List<ProductSection> get activeSections => _sections.where((s) => s.isActive).toList();
  bool get isLoading => _isLoading;

  ProductSectionProvider() {
    loadSections();
  }

  Future<void> loadSections() async {
    _isLoading = true;
    notifyListeners();

    _sections = await _sectionService.getAllSections();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSection(String name, String description) async {
    final newSection = ProductSection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      order: _sections.length,
    );

    await _sectionService.addSection(newSection);
    await loadSections();
  }

  Future<void> updateSection(ProductSection section) async {
    await _sectionService.updateSection(section);
    await loadSections();
  }

  Future<void> deleteSection(String id) async {
    await _sectionService.deleteSection(id);
    await loadSections();
  }

  Future<void> toggleSectionStatus(String id) async {
    await _sectionService.toggleSectionStatus(id);
    await loadSections();
  }

  Future<void> reorderSections(List<ProductSection> reorderedSections) async {
    await _sectionService.reorderSections(reorderedSections);
    await loadSections();
  }

  ProductSection? getSectionById(String id) {
    try {
      return _sections.firstWhere((section) => section.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ProductSection> getSectionsByIds(List<String> ids) {
    return _sections.where((section) => ids.contains(section.id)).toList();
  }
}
