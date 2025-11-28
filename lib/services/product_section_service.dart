import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_section.dart';

class ProductSectionService {
  static const String _sectionsKey = 'product_sections';

  Future<List<ProductSection>> getAllSections() async {
    final prefs = await SharedPreferences.getInstance();
    final sectionsJson = prefs.getString(_sectionsKey);
    
    if (sectionsJson == null) {
      return [];
    }

    final List<dynamic> decoded = json.decode(sectionsJson);
    return decoded.map((json) => ProductSection.fromJson(json)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<List<ProductSection>> getActiveSections() async {
    final sections = await getAllSections();
    return sections.where((section) => section.isActive).toList();
  }

  Future<ProductSection?> getSectionById(String id) async {
    final sections = await getAllSections();
    try {
      return sections.firstWhere((section) => section.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addSection(ProductSection section) async {
    final sections = await getAllSections();
    sections.add(section);
    await _saveSections(sections);
  }

  Future<void> updateSection(ProductSection section) async {
    final sections = await getAllSections();
    final index = sections.indexWhere((s) => s.id == section.id);
    
    if (index != -1) {
      sections[index] = section;
      await _saveSections(sections);
    }
  }

  Future<void> deleteSection(String id) async {
    final sections = await getAllSections();
    sections.removeWhere((section) => section.id == id);
    await _saveSections(sections);
  }

  Future<void> reorderSections(List<ProductSection> reorderedSections) async {
    // Update order field for each section
    final updatedSections = <ProductSection>[];
    for (int i = 0; i < reorderedSections.length; i++) {
      updatedSections.add(reorderedSections[i].copyWith(order: i));
    }
    await _saveSections(updatedSections);
  }

  Future<void> toggleSectionStatus(String id) async {
    final section = await getSectionById(id);
    if (section != null) {
      await updateSection(section.copyWith(isActive: !section.isActive));
    }
  }

  Future<void> _saveSections(List<ProductSection> sections) async {
    final prefs = await SharedPreferences.getInstance();
    final sectionsJson = json.encode(sections.map((s) => s.toJson()).toList());
    await prefs.setString(_sectionsKey, sectionsJson);
  }

  Future<void> clearAllSections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sectionsKey);
  }
}
