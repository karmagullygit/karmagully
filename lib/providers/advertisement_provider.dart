import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/advertisement.dart';
import '../models/carousel_banner.dart';

class AdvertisementProvider with ChangeNotifier {
  final _uuid = const Uuid();
  final List<Advertisement> _advertisements = [];
  final List<CarouselBanner> _carouselBanners = [];
  final Set<String> _dismissedAds = {}; // Track dismissed floating video ads

  // Getters
  List<Advertisement> get advertisements => [..._advertisements];
  List<CarouselBanner> get carouselBanners => [..._carouselBanners];
  Set<String> get dismissedAds => {..._dismissedAds};

  // Get active advertisements by placement
  List<Advertisement> getActiveAdsByPlacement(AdPlacement placement) {
    return _advertisements
        .where((ad) => ad.placement == placement && ad.isCurrentlyActive)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  // Get active carousel banners
  List<CarouselBanner> getActiveCarouselBanners() {
    return _carouselBanners
        .where((banner) => banner.isCurrentlyActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  // Get floating video ads that haven't been dismissed
  List<Advertisement> getActiveFloatingVideoAds() {
    return getActiveAdsByPlacement(AdPlacement.floatingVideo)
        .where((ad) => ad.hasVideo && !_dismissedAds.contains(ad.id))
        .toList();
  }

  // Advertisement CRUD operations
  String addAdvertisement({
    required String title,
    required String description,
    required AdType type,
    required AdPlacement placement,
    required String imageUrl,
    String? videoUrl,
    String? actionUrl,
    String? productId,
    bool isActive = true,
    required DateTime startDate,
    DateTime? endDate,
    int priority = 0,
    Map<String, dynamic> metadata = const {},
  }) {
    final advertisement = Advertisement(
      id: _uuid.v4(),
      title: title,
      description: description,
      type: type,
      placement: placement,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      actionUrl: actionUrl,
      productId: productId,
      isActive: isActive,
      startDate: startDate,
      endDate: endDate,
      priority: priority,
      metadata: metadata,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _advertisements.add(advertisement);
    notifyListeners();
    return advertisement.id;
  }

  void updateAdvertisement(String id, Advertisement updatedAd) {
    final index = _advertisements.indexWhere((ad) => ad.id == id);
    if (index != -1) {
      _advertisements[index] = updatedAd.copyWith(updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  void deleteAdvertisement(String id) {
    _advertisements.removeWhere((ad) => ad.id == id);
    _dismissedAds.remove(id);
    notifyListeners();
  }

  void toggleAdvertisementStatus(String id) {
    final index = _advertisements.indexWhere((ad) => ad.id == id);
    if (index != -1) {
      _advertisements[index] = _advertisements[index].copyWith(
        isActive: !_advertisements[index].isActive,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Carousel Banner CRUD operations
  String addCarouselBanner({
    required String title,
    String subtitle = '',
    required String imageUrl,
    String? actionUrl,
    String? productId,
    bool isActive = true,
    int order = 0,
    required DateTime startDate,
    DateTime? endDate,
    String backgroundColor = '#1976D2',
    String textColor = '#FFFFFF',
  }) {
    final banner = CarouselBanner(
      id: _uuid.v4(),
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      productId: productId,
      isActive: isActive,
      order: order,
      startDate: startDate,
      endDate: endDate,
      backgroundColor: backgroundColor,
      textColor: textColor,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _carouselBanners.add(banner);
    notifyListeners();
    return banner.id;
  }

  void updateCarouselBanner(String id, CarouselBanner updatedBanner) {
    final index = _carouselBanners.indexWhere((banner) => banner.id == id);
    if (index != -1) {
      _carouselBanners[index] = updatedBanner.copyWith(updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  void deleteCarouselBanner(String id) {
    _carouselBanners.removeWhere((banner) => banner.id == id);
    notifyListeners();
  }

  void toggleCarouselBannerStatus(String id) {
    final index = _carouselBanners.indexWhere((banner) => banner.id == id);
    if (index != -1) {
      _carouselBanners[index] = _carouselBanners[index].copyWith(
        isActive: !_carouselBanners[index].isActive,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Dismiss floating video ad
  void dismissFloatingVideoAd(String adId) {
    _dismissedAds.add(adId);
    notifyListeners();
  }

  // Clear dismissed ads (call this when app restarts or user logs out)
  void clearDismissedAds() {
    _dismissedAds.clear();
    notifyListeners();
  }

  // Load sample data
  void loadSampleData() {
    print('Loading sample advertisement data...'); // Debug
    _loadSampleCarouselBanners();
    _loadSampleAdvertisements();
    print('Loaded ${_carouselBanners.length} carousel banners and ${_advertisements.length} advertisements'); // Debug
    notifyListeners();
  }

  void _loadSampleCarouselBanners() {
    final sampleBanners = [
      CarouselBanner(
        id: _uuid.v4(),
        title: 'Summer Sale',
        subtitle: 'Up to 50% Off',
        imageUrl: 'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=800',
        actionUrl: '/sale',
        isActive: true,
        order: 1,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        backgroundColor: '#FF6B6B',
        textColor: '#FFFFFF',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CarouselBanner(
        id: _uuid.v4(),
        title: 'New Arrivals',
        subtitle: 'Latest Fashion Trends',
        imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800',
        actionUrl: '/new-arrivals',
        isActive: true,
        order: 2,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        backgroundColor: '#4ECDC4',
        textColor: '#FFFFFF',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CarouselBanner(
        id: _uuid.v4(),
        title: 'Free Shipping',
        subtitle: 'On orders over \$50',
        imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
        actionUrl: '/free-shipping',
        isActive: true,
        order: 3,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 90)),
        backgroundColor: '#45B7D1',
        textColor: '#FFFFFF',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _carouselBanners.addAll(sampleBanners);
  }

  void _loadSampleAdvertisements() {
    final sampleAds = [
      Advertisement(
        id: _uuid.v4(),
        title: 'Product Showcase',
        description: 'Watch our latest product in action',
        type: AdType.video,
        placement: AdPlacement.floatingVideo,
        imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        actionUrl: '/products/featured',
        isActive: true,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        priority: 10,
        metadata: {
          'autoplay': true,
          'duration': 30,
          'canDismiss': true,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Advertisement(
        id: _uuid.v4(),
        title: 'Special Promotion',
        description: 'Limited time offer on premium products',
        type: AdType.promotion,
        placement: AdPlacement.banner,
        imageUrl: 'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=400',
        actionUrl: '/promotions/special',
        isActive: true,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        priority: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _advertisements.addAll(sampleAds);
  }

  // Get advertisement by ID
  Advertisement? getAdvertisementById(String id) {
    try {
      return _advertisements.firstWhere((ad) => ad.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get carousel banner by ID
  CarouselBanner? getCarouselBannerById(String id) {
    try {
      return _carouselBanners.firstWhere((banner) => banner.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all data
  void clearAllData() {
    _advertisements.clear();
    _carouselBanners.clear();
    _dismissedAds.clear();
    notifyListeners();
  }

  // Get statistics for admin
  Map<String, dynamic> getAdvertisementStatistics() {
    final activeAds = _advertisements.where((ad) => ad.isCurrentlyActive).length;
    final totalAds = _advertisements.length;
    final activeBanners = _carouselBanners.where((banner) => banner.isCurrentlyActive).length;
    final totalBanners = _carouselBanners.length;

    return {
      'totalAdvertisements': totalAds,
      'activeAdvertisements': activeAds,
      'totalCarouselBanners': totalBanners,
      'activeCarouselBanners': activeBanners,
      'dismissedVideoAds': _dismissedAds.length,
      'videoAds': _advertisements.where((ad) => ad.hasVideo).length,
    };
  }
}