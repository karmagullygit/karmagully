import 'package:flutter/material.dart';
import '../models/social_media_link.dart';

class SocialMediaProvider with ChangeNotifier {
  final List<SocialMediaLink> _socialMediaLinks = [];

  List<SocialMediaLink> get socialMediaLinks {
    final active = _socialMediaLinks.where((link) => link.isActive).toList();
    active.sort((a, b) => a.order.compareTo(b.order));
    return active;
  }

  List<SocialMediaLink> get allLinks => List.unmodifiable(_socialMediaLinks);

  void loadSocialMediaLinks() {
    // Load default social media links
    _socialMediaLinks.clear();
    _socialMediaLinks.addAll([
      SocialMediaLink(
        id: '1',
        name: 'Facebook',
        url: 'https://facebook.com/karmashop',
        iconName: 'facebook',
        order: 1,
        isActive: true,
      ),
      SocialMediaLink(
        id: '2',
        name: 'Instagram',
        url: 'https://instagram.com/karmashop',
        iconName: 'instagram',
        order: 2,
        isActive: true,
      ),
      SocialMediaLink(
        id: '3',
        name: 'Twitter',
        url: 'https://twitter.com/karmashop',
        iconName: 'twitter',
        order: 3,
        isActive: true,
      ),
      SocialMediaLink(
        id: '4',
        name: 'YouTube',
        url: 'https://youtube.com/@karmashop',
        iconName: 'youtube',
        order: 4,
        isActive: true,
      ),
      SocialMediaLink(
        id: '5',
        name: 'LinkedIn',
        url: 'https://linkedin.com/company/karmashop',
        iconName: 'linkedin',
        order: 5,
        isActive: true,
      ),
      SocialMediaLink(
        id: '6',
        name: 'WhatsApp',
        url: 'https://wa.me/1234567890',
        iconName: 'whatsapp',
        order: 6,
        isActive: true,
      ),
    ]);
    notifyListeners();
  }

  void addSocialMediaLink(SocialMediaLink link) {
    _socialMediaLinks.add(link);
    notifyListeners();
  }

  void updateSocialMediaLink(SocialMediaLink link) {
    final index = _socialMediaLinks.indexWhere((l) => l.id == link.id);
    if (index != -1) {
      _socialMediaLinks[index] = link;
      notifyListeners();
    }
  }

  void deleteSocialMediaLink(String id) {
    _socialMediaLinks.removeWhere((link) => link.id == id);
    notifyListeners();
  }

  void toggleLinkStatus(String id) {
    final index = _socialMediaLinks.indexWhere((l) => l.id == id);
    if (index != -1) {
      _socialMediaLinks[index] = _socialMediaLinks[index].copyWith(
        isActive: !_socialMediaLinks[index].isActive,
      );
      notifyListeners();
    }
  }

  void reorderLinks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final link = _socialMediaLinks.removeAt(oldIndex);
    _socialMediaLinks.insert(newIndex, link);
    
    // Update order values
    for (int i = 0; i < _socialMediaLinks.length; i++) {
      _socialMediaLinks[i] = _socialMediaLinks[i].copyWith(order: i);
    }
    notifyListeners();
  }
}
