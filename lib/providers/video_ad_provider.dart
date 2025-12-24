import 'package:flutter/material.dart';
import '../models/video_ad.dart';

class VideoAdProvider with ChangeNotifier {
  final List<VideoAd> _videoAds = [];
  bool _isPlayerVisible = true;

  List<VideoAd> get videoAds => List.unmodifiable(_videoAds);
  
  List<VideoAd> get activeVideoAds {
    final active = _videoAds.where((ad) => ad.isActive).toList();
    active.sort((a, b) => b.priority.compareTo(a.priority));
    return active;
  }

  bool get isPlayerVisible => _isPlayerVisible;

  void loadVideoAds() {
    // Only load sample videos if list is empty (first time initialization)
    if (_videoAds.isEmpty) {
      _videoAds.addAll([
        VideoAd(
          id: '1',
          title: 'Summer Sale',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          thumbnailUrl: 'https://picsum.photos/200/300',
          targetUrl: 'https://example.com/summer-sale',
          duration: 30,
          isActive: true,
          createdAt: DateTime.now(),
          priority: 1,
        ),
        VideoAd(
          id: '2',
          title: 'New Arrivals',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          thumbnailUrl: 'https://picsum.photos/200/301',
          targetUrl: 'https://example.com/new-arrivals',
          duration: 25,
          isActive: true,
          createdAt: DateTime.now(),
          priority: 2,
        ),
      ]);
    }
    // Show player if there are active ads
    if (activeVideoAds.isNotEmpty) {
      _isPlayerVisible = true;
    }
    notifyListeners();
  }

  void addVideoAd(VideoAd ad) {
    _videoAds.add(ad);
    // Show player when new active ad is added
    if (ad.isActive && activeVideoAds.isNotEmpty) {
      _isPlayerVisible = true;
    }
    notifyListeners();
  }

  void updateVideoAd(VideoAd ad) {
    final index = _videoAds.indexWhere((a) => a.id == ad.id);
    if (index != -1) {
      _videoAds[index] = ad;
      // Show player if there are active ads
      if (activeVideoAds.isNotEmpty) {
        _isPlayerVisible = true;
      }
      notifyListeners();
    }
  }

  void deleteVideoAd(String id) {
    _videoAds.removeWhere((ad) => ad.id == id);
    notifyListeners();
  }

  void toggleAdStatus(String id) {
    final index = _videoAds.indexWhere((a) => a.id == id);
    if (index != -1) {
      _videoAds[index] = _videoAds[index].copyWith(
        isActive: !_videoAds[index].isActive,
      );
      notifyListeners();
    }
  }

  void hidePlayer() {
    _isPlayerVisible = false;
    notifyListeners();
  }

  void showPlayer() {
    _isPlayerVisible = true;
    notifyListeners();
  }

  void resetPlayerVisibility() {
    _isPlayerVisible = true;
    notifyListeners();
  }
}
