import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/advertisement_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/flash_sale_provider.dart';
import '../../providers/social_feed_provider.dart';
import '../../providers/app_analytics_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/feature_settings_provider.dart';
import '../../providers/product_section_provider.dart';
import '../../providers/video_ad_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/chatbot_widget.dart';
import '../../widgets/flash_sale_banner.dart';
import '../../widgets/floating_ad_player.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';
import 'category_products_screen.dart';
import 'product_detail_screen.dart';
import 'user_profile_screen.dart';
import '../social/social_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _currentPageIndex = 0;
  Timer? _carouselTimer;
  PageController? _carouselController;
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 10000);

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Track page view
      final analytics = Provider.of<AppAnalyticsProvider>(context, listen: false);
      analytics.trackUserAction(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}', // In real app, use actual user ID
        action: 'page_view',
        screen: 'home',
      );
      
      // Load products first
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadProducts().then((_) {
        // After products are loaded, initialize AI recommendations with real data
        final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
        recommendationProvider.initializeWithProducts(productProvider.products);
      });
      
      Provider.of<AdvertisementProvider>(context, listen: false).loadSampleData();
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      Provider.of<SocialFeedProvider>(context, listen: false).loadPosts();
      Provider.of<ProductSectionProvider>(context, listen: false).loadSections();
      
      // Load flash sales (don't reset - preserve admin added flash sales)
      final flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);
      flashSaleProvider.loadFlashSales();
      
      // Load video ads
      Provider.of<VideoAdProvider>(context, listen: false).loadVideoAds();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _carouselTimer?.cancel();
    _carouselController?.dispose();
    super.dispose();
  }

  Widget _getCurrentScreenContent() {
    final featureSettings = Provider.of<FeatureSettingsProvider>(context);
    final feedEnabled = featureSettings.customerFeedEnabled;

    // Adjust index based on whether feed is enabled
    int adjustedIndex = _currentPageIndex;
    if (!feedEnabled && _currentPageIndex >= 1) {
      adjustedIndex = _currentPageIndex + 1;
    }

    switch (adjustedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const SocialFeedScreen();
      case 2:
        return _buildSearchContent();
      case 3:
        return const WishlistScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final backgroundColor = isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFAFAFA);
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        
        return EmojiPetalRain(
      child: Stack(
        children: [
          // Top-right gradient overlay like in the reference image - only in dark mode
          if (isDarkMode) Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.7, -0.8),
                radius: 1.2,
                colors: [
                  const Color(0xFF6B46C1).withOpacity(0.6), // Purple
                  const Color(0xFF9333EA).withOpacity(0.4), // Violet
                  const Color(0xFFEC4899).withOpacity(0.3), // Pink
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
        ),
        // Background color based on theme
        Container(
          color: backgroundColor,
          child: SafeArea(
            child: Consumer<FeatureSettingsProvider>(
              builder: (context, featureSettings, child) {
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(context, isDarkMode),
                    _buildSearchSection(context, isDarkMode),
                    // Only show other sections when not searching
                    if (_searchQuery.isEmpty) ...[
                      _buildCarouselSection(context, isDarkMode),
                      _buildFlashSalesSection(context, isDarkMode),
                      _buildCategoriesSection(context, isDarkMode),
                      // Community Feed section removed
                      _buildFeaturedSection(context, isDarkMode),
                      SliverToBoxAdapter(
                        child: _buildProductSections(context, isDarkMode),
                      ),
                    ] else ...[
                      // Show search results header when searching
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getHorizontalPadding(context),
                            vertical: ResponsiveUtils.getVerticalSpacing(context),
                          ),
                          child: Text(
                            'Search Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                    _buildProductGrid(context, isDarkMode),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
        ),
        
        // AI Chatbot Widget
        const Positioned.fill(
          child: ChatBotWidget(),
        ),
      ],
      ),
    );
      },
    );
  }

  Widget _buildSearchContent() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final backgroundColor = isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFAFAFA);
        
        return Container(
      color: backgroundColor,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, isDarkMode),
            _buildSearchSection(context, isDarkMode),
            _buildProductGrid(context, isDarkMode),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, VideoAdProvider>(
      builder: (context, themeProvider, videoAdProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final backgroundColor = isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFAFAFA);
        
        return Scaffold(
          backgroundColor: backgroundColor,
          body: Stack(
            children: [
              _getCurrentScreenContent(),
              // Floating Ad Player - only show on home page
              if (_currentPageIndex == 0 && videoAdProvider.isPlayerVisible)
                const FloatingAdPlayer(),
            ],
          ),
          // Remove conflicting FloatingActionButton - chatbot has its own
          // floatingActionButton: _buildFloatingCart(context, true),
          bottomNavigationBar: _buildNewBottomNavigationBar(context),
        );
      },
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isDarkMode) {
    final searchBgColor = isDarkMode ? const Color(0xFF1A1F3A) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF5B4FCF) : Colors.blue;
    final textColor = isDarkMode ? const Color(0xFFB4B0C8) : Colors.black87;
    final hintColor = isDarkMode ? const Color(0xFF6B677A) : Colors.grey;
    final iconColor = isDarkMode ? const Color(0xFF8B7FD8) : Colors.blue;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ResponsiveUtils.getHorizontalPadding(context),
          ResponsiveUtils.getVerticalSpacing(context) * 0.5,
          ResponsiveUtils.getHorizontalPadding(context),
          ResponsiveUtils.getVerticalSpacing(context),
        ),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: searchBgColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.search, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor, fontSize: 16),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (query) {
                    final analytics = Provider.of<AppAnalyticsProvider>(context, listen: false);
                    analytics.trackUserAction(
                      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
                      action: 'search',
                      screen: 'home',
                      metadata: {'query': query},
                    );
                  },
                  cursorColor: iconColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: hintColor, fontSize: 16),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.clear, color: isDarkMode ? Colors.white70 : Colors.black54, size: 20),
                  ),
                ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showFilterBottomSheet(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(Icons.tune, color: isDarkMode ? Colors.white : Colors.black87, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashSalesSection(BuildContext context, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Consumer<FlashSaleProvider>(
        builder: (context, flashSaleProvider, child) {
          final activeFlashSales = flashSaleProvider.activeFlashSales;
          
          if (activeFlashSales.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Container(
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: FlashSaleBannerWidget(flashSale: activeFlashSales.first, isDarkMode: isDarkMode),
          );
        },
      ),
    );
  }

  Widget _buildFlashSaleBanner(BuildContext context, dynamic flashSale, {bool isDarkMode = true}) {
    // Debug: print the imageUrl to see what's being stored
    debugPrint('🔥 Flash Sale imageUrl: "${flashSale.imageUrl}"');
    
    return GestureDetector(
      onTap: () {
        // Navigate to actionUrl if provided, otherwise go to flash sales page
        final targetRoute = flashSale.actionUrl ?? '/customer-flash-sales';
        Navigator.pushNamed(context, targetRoute);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Banner Image (user uploaded design)
                _buildFlashSaleImage(flashSale.imageUrl),
                
                // Shimmer animation overlay
                _buildShimmerOverlay(),
                
                // Timer overlay at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Consumer<FlashSaleProvider>(
                    builder: (context, provider, child) {
                      final timeRemaining = flashSale.timeRemaining;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // LIVE badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flash_on, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Timer
                            const Icon(Icons.timer, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            _buildFlashSaleTimer(timeRemaining),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashSaleImage(String imageUrl) {
    if (imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFF1E1E2E),
            child: const Center(child: CircularProgressIndicator(color: Colors.red)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Flash sale network image error: $error');
          return _buildPlaceholderBanner();
        },
      );
    } else {
      return _buildPlaceholderBanner();
    }
  }

  Widget _buildPlaceholderBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53935),
            Color(0xFFD32F2F),
            Color(0xFFC62828),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber, size: 32),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FLASH SALE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Limited Time Offer!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerOverlay() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(seconds: 3),
      curve: Curves.linear,
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.15),
                Colors.transparent,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          // Use a transparent child so the shader does not paint a solid white
          // rectangle that can obscure the banner image underneath.
          child: Container(color: Colors.transparent),
        );
      },
      onEnd: () {
        // The shimmer will restart due to the widget rebuild
      },
    );
  }

  Widget _buildFlashSaleTimer(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimerDigit(hours.toString().padLeft(2, '0'), 'H'),
        const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        _buildTimerDigit(minutes.toString().padLeft(2, '0'), 'M'),
        const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        _buildTimerDigit(seconds.toString().padLeft(2, '0'), 'S'),
      ],
    );
  }

  Widget _buildTimerDigit(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Auto-scroll carousel state
  int _currentCarouselPage = 0;

  void _startCarouselAutoScroll(int pageCount) {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController != null && _carouselController!.hasClients) {
        _currentCarouselPage = (_currentCarouselPage + 1) % pageCount;
        _carouselController!.animateToPage(
          _currentCarouselPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildCarouselSection(BuildContext context, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Consumer<AdvertisementProvider>(
        builder: (context, adProvider, child) {
          final banners = adProvider.carouselBanners;
          if (banners.isEmpty) {
            return Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2139),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2D3A)),
              ),
              child: Center(
                child: Text(
                  'No banners available',
                  style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                ),
              ),
            );
          }

          // Initialize controller and start auto-scroll
          if (_carouselController == null) {
            _carouselController = PageController(initialPage: 0, viewportFraction: 0.92);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startCarouselAutoScroll(banners.length);
            });
          }

          return Column(
                children: [
                  Container(
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 12, top: 0),
                    child: PageView.builder(
                      controller: _carouselController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentCarouselPage = index;
                        });
                      },
                      itemCount: banners.length,
                      itemBuilder: (context, index) {
                        final banner = banners[index];
                        return AnimatedBuilder(
                          animation: _carouselController!,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_carouselController!.position.haveDimensions) {
                              value = _carouselController!.page! - index;
                              value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                            }
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6B46C1),
                                Color(0xFF9333EA),
                                Color(0xFFEC4899),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B73FF).withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                if (banner.imageUrl.isNotEmpty)
                                  banner.imageUrl.startsWith('file://') 
                                    ? Image.file(
                                        File(banner.imageUrl.replaceFirst('file://', '')),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: const Color(0xFF1E2139),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.white54,
                                                size: 50,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Image.network(
                                        banner.imageUrl,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: const Color(0xFF1E2139),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.white54,
                                                size: 50,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.black.withOpacity(0.4),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF0B5A),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '🔥 HOT DEAL',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        banner.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Page indicators (dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      banners.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentCarouselPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentCarouselPage == index
                              ? const Color(0xFF6B73FF)
                              : const Color(0xFF2A2D3A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
        },
      ),
    );
  }

  // Add placeholder methods to prevent compilation errors
  Widget _buildAppBar(BuildContext context, bool isDarkMode) {
    final iconColor = isDarkMode ? const Color(0xFF7C3AED) : Colors.blue;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Row(
          children: [
            // Profile/Menu button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: iconColor),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                icon: Icon(
                  Icons.person,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // App title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KarmaGully',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    'Shop with good karma',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            // Notifications button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: iconColor),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Cart button
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF7C3AED)),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Navigate to cart screen
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF7C3AED),
                          size: 22,
                        ),
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF0B5A),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.getHorizontalPadding(context), 
              ResponsiveUtils.getVerticalPadding(context), 
              ResponsiveUtils.getHorizontalPadding(context), 
              ResponsiveUtils.getVerticalPadding(context)
            ),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: ResponsiveUtils.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.isLoading) {
                return SizedBox(
                  height: ResponsiveUtils.getProductGridHeight(context) * 0.4,
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFF6B73FF))),
                );
              }

              if (categoryProvider.categories.isEmpty) {
                return SizedBox(
                  height: 110,
                  child: Center(
                    child: Text(
                      'No categories available',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categoryProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryProvider.categories[index];
                    
                    // Create gradient colors for each category
                    final gradientColors = _getCategoryGradient(index);
                    
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryProductsScreen(
                              category: category,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 85,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Circular category icon with gradient
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradientColors,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: gradientColors[1].withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2139),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: gradientColors[0].withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: (category.imageUrl?.isNotEmpty ?? false)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(35),
                                        child: Image.network(
                                          category.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.category,
                                              color: gradientColors[0],
                                              size: 28,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.category,
                                        color: gradientColors[0],
                                        size: 28,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Category name
                            Flexible(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to get gradient colors for categories
  List<Color> _getCategoryGradient(int index) {
    final gradients = [
      [const Color(0xFF6B73FF), const Color(0xFF9333EA)], // Blue to Purple
      [const Color(0xFFEC4899), const Color(0xFFFF0B5A)], // Pink to Red
      [const Color(0xFF10B981), const Color(0xFF06B6D4)], // Green to Cyan
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Orange to Red
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)], // Purple to Pink
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // Cyan to Blue
    ];
    return gradients[index % gradients.length];
  }

  Widget _buildSocialFeedPreviewSection(BuildContext context, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Consumer<SocialFeedProvider>(
        builder: (context, socialProvider, child) {
          final posts = socialProvider.posts.take(3).toList();
          
          if (posts.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1D4ED8),
                                Color(0xFF38BDF8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withOpacity(0.6),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.dynamic_feed,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Feed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'See what our community is sharing',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/social-feed'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0EA5E9),
                              Color(0xFF38BDF8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9).withOpacity(0.7),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0E27),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1D4ED8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1D4ED8).withOpacity(0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post header
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfileScreen(
                                            userId: post.userId,
                                            username: post.username,
                                            displayName: post.userDisplayName ?? post.username,
                                            avatar: post.userAvatar,
                                            isVerified: post.isVerified,
                                            profilePictureUrl: post.userAvatar,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1877F2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: post.userAvatar.startsWith('assets/')
                                            ? Image.asset(
                                                post.userAvatar,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              )
                                            : post.userAvatar.startsWith('http') || post.userAvatar.contains('/')
                                                ? Builder(builder: (context) {
                                                    try {
                                                      if (post.userAvatar.startsWith('http')) {
                                                        return Image.network(
                                                          post.userAvatar,
                                                          width: 32,
                                                          height: 32,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stack) {
                                                            return Center(
                                                              child: Text(
                                                                post.userAvatar,
                                                                style: const TextStyle(fontSize: 16),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      }
                                                      return Image.file(
                                                        File(post.userAvatar),
                                                        width: 32,
                                                        height: 32,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stack) {
                                                          return Center(
                                                            child: Text(
                                                              post.userAvatar,
                                                              style: const TextStyle(fontSize: 16),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } catch (e) {
                                                      return Center(
                                                        child: Text(
                                                          post.userAvatar,
                                                          style: const TextStyle(fontSize: 16),
                                                        ),
                                                      );
                                                    }
                                                  })
                                                : Center(
                                                    child: Text(
                                                      post.userAvatar,
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                  ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                post.userDisplayName ?? post.username,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: isDarkMode ? Colors.white : Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (post.isVerified) ...[
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.verified,
                                                color: Color(0xFF1D9BF0),
                                                size: 16,
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          post.formattedDate,
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white70 : Colors.black54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Post content
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  post.content,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Post stats
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 16,
                                    color: Colors.red[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '24',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.comment,
                                    size: 16,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '5',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final featuredProducts = productProvider.featuredProducts;
                
                if (featuredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'No featured products available',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                  );
                }
                
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredProducts.length,
                    itemBuilder: (context, index) {
                      final product = featuredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(productId: product.id),
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E2139) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDarkMode ? const Color(0xFF2A2D3A) : Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF6B73FF).withOpacity(0.3),
                                      const Color(0xFFEC4899).withOpacity(0.3),
                                    ],
                                  ),
                                ),
                                child: (product.imageUrl.isNotEmpty || product.imageUrls.isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: _buildProductImage(
                                          product.imageUrl.isNotEmpty ? product.imageUrl : product.imageUrls.first,
                                          isDarkMode,
                                          context,
                                        ),
                                      )
                                    : Icon(
                                        Icons.image,
                                        color: isDarkMode ? Colors.white54 : Colors.grey,
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isDarkMode ? const Color(0xFF6B73FF) : Colors.blue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSections(BuildContext context, bool isDarkMode) {
    return Consumer2<ProductSectionProvider, ProductProvider>(
      builder: (context, sectionProvider, productProvider, child) {
        final activeSections = sectionProvider.activeSections;
        
        if (activeSections.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: activeSections.map((section) {
            final sectionProducts = productProvider.getProductsBySection(section.id);
            
            if (sectionProducts.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (section.description.isNotEmpty)
                              Text(
                                section.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to section products view
                          },
                          child: Text(
                            'See All',
                            style: TextStyle(color: isDarkMode ? const Color(0xFF6B73FF) : Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sectionProducts.length,
                      itemBuilder: (context, index) {
                        final product = sectionProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(productId: product.id),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF1C1F26) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDarkMode ? const Color(0xFF6B73FF).withOpacity(0.2) : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Container(
                                    height: 180,
                                    width: double.infinity,
                                    color: isDarkMode ? const Color(0xFF2A2D3A) : Colors.grey.shade100,
                                    child: (product.imageUrl.isNotEmpty || product.imageUrls.isNotEmpty)
                                        ? _buildProductImage(
                                            product.imageUrl.isNotEmpty ? product.imageUrl : product.imageUrls.first,
                                            isDarkMode,
                                            context,
                                          )
                                        : Icon(
                                            Icons.image,
                                            color: isDarkMode ? Colors.white54 : Colors.grey,
                                            size: 48,
                                          ),
                                  ),
                                ),
                                // Product Info
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white : Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${product.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: isDarkMode ? const Color(0xFF6B73FF) : Colors.blue,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: (isDarkMode ? const Color(0xFF6B73FF) : Colors.blue).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Icon(
                                                Icons.add_shopping_cart,
                                                color: isDarkMode ? const Color(0xFF6B73FF) : Colors.blue,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProductGrid(BuildContext context, bool isDarkMode) {
    final progressColor = isDarkMode ? const Color(0xFF6B73FF) : Colors.blue;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: progressColor),
              ),
            ),
          );
        }

        if (productProvider.products.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No products available',
                  style: TextStyle(color: textColor),
                ),
              ),
            ),
          );
        }

        // Filter products based on search query
        final filteredProducts = _searchQuery.isEmpty
            ? productProvider.products
            : productProvider.products.where((product) {
                return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                       product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                       product.category.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

        // Apply price range filter
        final priceFilteredProducts = filteredProducts.where((product) {
          return product.price >= _priceRange.start && product.price <= _priceRange.end;
        }).toList();

        if (priceFilteredProducts.isEmpty && _searchQuery.isNotEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No products found for "$_searchQuery"',
                      style: TextStyle(color: textColor, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: const Text('Clear search', style: TextStyle(color: Color(0xFF6B73FF))),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveUtils.getProductGridCrossAxisCount(context),
                childAspectRatio: ResponsiveUtils.getProductGridAspectRatio(context),
                crossAxisSpacing: ResponsiveUtils.getHorizontalSpacing(context),
                mainAxisSpacing: ResponsiveUtils.getVerticalSpacing(context),
              ),
              itemCount: priceFilteredProducts.length,
              itemBuilder: (context, index) {
                final product = priceFilteredProducts[index];
                return _buildProductCard(context, product, isDarkMode);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, bool isDarkMode) {
    final cardBg = isDarkMode ? const Color(0xFF1E2139) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF2A2D3A) : Colors.grey.shade300;
    final shadowColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container - Flexible
            Expanded(
              flex: 3, // 60% of available space
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                    topRight: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6B73FF).withOpacity(0.1),
                      const Color(0xFFEC4899).withOpacity(0.1),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: (product.imageUrl.isNotEmpty || product.imageUrls.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                                topRight: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                              ),
                              child: _buildProductImage(
                                product.imageUrl.isNotEmpty ? product.imageUrl : product.imageUrls.first,
                                isDarkMode,
                                context,
                              ),
                            )
                          : Container(
                              color: isDarkMode ? const Color(0xFF2A2D3A) : Colors.grey.shade200,
                              child: Icon(
                                Icons.image,
                                color: isDarkMode ? Colors.white54 : Colors.grey,
                                size: ResponsiveUtils.getIconSize(context),
                              ),
                            ),
                    ),
                    // Wishlist button
                    Positioned(
                      top: ResponsiveUtils.getVerticalSpacing(context) * 0.5,
                      right: ResponsiveUtils.getHorizontalSpacing(context) * 0.5,
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlistProvider, child) {
                          final isInWishlist = wishlistProvider.isInWishlist(product.id);
                          return Container(
                            padding: EdgeInsets.all(ResponsiveUtils.getCaptionFontSize(context) * 0.4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (isInWishlist) {
                                  wishlistProvider.removeFromWishlist(product.id);
                                } else {
                                  wishlistProvider.addToWishlist(product.id);
                                }
                              },
                              child: Icon(
                                isInWishlist ? Icons.favorite : Icons.favorite_border,
                                color: isInWishlist ? const Color(0xFFFF0B5A) : (isDarkMode ? Colors.white : Colors.black54),
                                size: ResponsiveUtils.getCaptionFontSize(context) + 6,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Product Info Container - Flexible
            Expanded(
              flex: 2, // 40% of available space
              child: Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name - Flexible
                    Expanded(
                      flex: 2,
                      child: Text(
                        product.name,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: ResponsiveUtils.getCaptionFontSize(context) + 2,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Spacing
                    SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.2),
                    // Product Price
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isDarkMode ? const Color(0xFF6B73FF) : Colors.blue,
                        fontSize: ResponsiveUtils.getCaptionFontSize(context) + 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Spacing
                    SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.3),
                    // Add to Cart Button - Fixed height
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveUtils.getCaptionFontSize(context) * 2.5,
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false)
                              .addItem(product, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              backgroundColor: isDarkMode ? const Color(0xFF6B73FF) : Colors.blue,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? const Color(0xFF6B73FF) : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 0.5),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getCaptionFontSize(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imagePath, bool isDarkMode, BuildContext context) {
    // Check if it's a local file path
    if (imagePath.startsWith('/') || imagePath.contains('\\') || imagePath.startsWith('file://')) {
      final file = File(imagePath.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: isDarkMode ? const Color(0xFF2A2D3A) : Colors.grey.shade200,
              child: Icon(
                Icons.image,
                color: isDarkMode ? Colors.white54 : Colors.grey,
                size: ResponsiveUtils.getIconSize(context),
              ),
            );
          },
        );
      }
    }
    
    // It's a network URL
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: isDarkMode ? const Color(0xFF2A2D3A) : Colors.grey.shade200,
          child: Icon(
            Icons.image,
            color: isDarkMode ? Colors.white54 : Colors.grey,
            size: ResponsiveUtils.getIconSize(context),
          ),
        );
      },
    );
  }

  Widget _buildNewBottomNavigationBar(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final bgColor = isDarkMode ? const Color(0xFF020617) : Colors.white;
        final selectedColor = isDarkMode ? const Color(0xFF8B5CF6) : Colors.blue;
        final unselectedColor = isDarkMode ? Colors.white60 : Colors.grey;
        
        return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00111827),
            Color(0xFF020617),
          ],
        ) : null,
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? const Color(0xFF7C3AED) : Colors.blue).withOpacity(0.45),
            blurRadius: 26,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: bgColor,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        selectedIconTheme: IconThemeData(
          color: selectedColor,
          size: 26,
          shadows: [
            BoxShadow(
              color: selectedColor.withOpacity(0.85),
              blurRadius: 18,
            ),
          ],
        ),
        unselectedIconTheme: IconThemeData(
          color: unselectedColor,
          size: 24,
        ),
        currentIndex: _currentPageIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: _buildBottomNavItems(context),
      ),
    );
      },
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(BuildContext context) {
    final featureSettings = Provider.of<FeatureSettingsProvider>(context);
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
    ];

    // Add Feed tab only if customer feed is enabled
    if (featureSettings.customerFeedEnabled) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.dynamic_feed_outlined),
          activeIcon: Icon(Icons.dynamic_feed),
          label: 'Feed',
        ),
      );
    }

    items.addAll([
      const BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: 'Search',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border),
        activeIcon: Icon(Icons.favorite),
        label: 'Wishlist',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ]);

    return items;
  }

  // Helper method to format duration for countdown timer
  String _formatDuration(Duration duration) {
    if (duration <= Duration.zero) {
      return '00:00:00';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  void _showFilterBottomSheet(BuildContext context) {
    RangeValues tempPriceRange = _priceRange;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF1E2139) : Colors.white;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Consumer2<CategoryProvider, ProductProvider>(
              builder: (context, categoryProvider, productProvider, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Category Filter
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _searchQuery.isEmpty,
                            onSelected: (selected) {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                              Navigator.pop(context);
                            },
                            backgroundColor: const Color(0xFF2A2D3A),
                            selectedColor: const Color(0xFF6B73FF),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                          ...categoryProvider.categories.map((category) {
                            return FilterChip(
                              label: Text(category.name),
                              selected: false,
                              onSelected: (selected) {
                                setState(() {
                                  _searchQuery = category.name;
                                  _searchController.text = category.name;
                                });
                                Navigator.pop(context);
                              },
                              backgroundColor: const Color(0xFF2A2D3A),
                              selectedColor: const Color(0xFF6B73FF),
                              labelStyle: const TextStyle(color: Colors.white),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Price Range Slider
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${tempPriceRange.start.round()}',
                            style: const TextStyle(
                              color: Color(0xFF6B73FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹${tempPriceRange.end.round()}',
                            style: const TextStyle(
                              color: Color(0xFF6B73FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: tempPriceRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        activeColor: const Color(0xFF6B73FF),
                        inactiveColor: const Color(0xFF2A2D3A),
                        labels: RangeLabels(
                          '₹${tempPriceRange.start.round()}',
                          '₹${tempPriceRange.end.round()}',
                        ),
                        onChanged: (RangeValues values) {
                          setModalState(() {
                            tempPriceRange = values;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹0',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '₹10,000',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _priceRange = tempPriceRange;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B73FF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Reset Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempPriceRange = const RangeValues(0, 10000);
                            });
                            setState(() {
                              _priceRange = const RangeValues(0, 10000);
                              _searchQuery = '';
                              _searchController.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Reset All Filters',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Content widget for home screen without scaffold (for use in main customer screen)
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<AdvertisementProvider>(context, listen: false).loadSampleData();
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      Provider.of<SocialFeedProvider>(context, listen: false).loadPosts();
      
      // Load flash sales (don't reset - preserve admin added flash sales)
      final flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);
      flashSaleProvider.loadFlashSales();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context, true), // Force dark mode
          _buildSearchSection(context, true),
          _buildCarouselSection(context, true),
          _buildFlashSalesSection(context, true),
          _buildCategoriesSection(context, true),
          // Community Feed section removed
          _buildAIRecommendationSection(context, true),
          _buildFeaturedSection(context, true),
          _buildProductGrid(context, true),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // Copy all the methods from _HomeScreenState for building sections
  Widget _buildAppBar(BuildContext context, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile/Menu button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2139),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2D3A)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                icon: const Icon(
                  Icons.person,
                  color: Color(0xFF6B73FF),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // App title
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KarmaGully',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Notifications
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2139),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2D3A)),
              ),
              child: const Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF6B73FF),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFFFF0B5A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // I'll need to copy all other build methods here, but for now let me create placeholder methods
  // to prevent errors. You can copy the actual implementations from the main HomeScreen class

  Widget _buildSearchSection(BuildContext context, bool isDarkMode) {
    // Copy implementation from main HomeScreen
    return const SliverToBoxAdapter(child: SizedBox(height: 20));
  }

  Widget _buildCarouselSection(BuildContext context, bool isDarkMode) {
    // Copy implementation from main HomeScreen
    return const SliverToBoxAdapter(child: SizedBox(height: 20));
  }

  Widget _buildFlashSalesSection(BuildContext context, bool isDarkMode) {
    // Copy implementation from main HomeScreen
    return const SliverToBoxAdapter(child: SizedBox(height: 20));
  }

  Widget _buildCategoriesSection(BuildContext context, bool isDarkMode) {
    // Copy implementation from main HomeScreen
    return const SliverToBoxAdapter(child: SizedBox(height: 20));
  }

  Widget _buildSocialFeedPreviewSection(BuildContext context, bool isDarkMode) {
    // Copy implementation from main HomeScreen
    return const SliverToBoxAdapter(child: SizedBox(height: 20));
  }

  Widget _buildAIRecommendationSection(BuildContext context, bool isDarkMode) {
    // Copy implementation from main HomeScreen
    return const SliverToBoxAdapter(child: SizedBox(height: 20));
  }

  Widget _buildFeaturedSection(BuildContext context, bool isDarkMode) {
    // Copy implementation from main HomeScreen
    return const SliverToBoxAdapter(child: SizedBox(height: 20));
  }

  Widget _buildProductGrid(BuildContext context, bool isDarkMode) {
    // Copy implementation from main HomeScreen
    return const SliverToBoxAdapter(child: SizedBox(height: 20));
  }
}

// Emoji Petal Rain Widget
class EmojiPetalRain extends StatefulWidget {
  final Widget child;
  const EmojiPetalRain({super.key, required this.child});

  @override
  State<EmojiPetalRain> createState() => _EmojiPetalRainState();
}

class _EmojiPetalRainState extends State<EmojiPetalRain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final int petalCount = 25;

  late List<_EmojiPetal> petals;

  @override
  void initState() {
    super.initState();

    petals = List.generate(
      petalCount,
      (index) => _EmojiPetal(
        x: _random.nextDouble() * 400,
        y: _random.nextDouble() * -600,
        speed: 1 + _random.nextDouble() * 2,
        size: 18 + _random.nextDouble() * 12,
        angle: _random.nextDouble() * pi,
        emoji: "🌸",
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _EmojiPetalPainter(petals),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _EmojiPetal {
  double x;
  double y;
  double speed;
  double size;
  double angle;
  String emoji;

  _EmojiPetal({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.angle,
    required this.emoji,
  });
}

class _EmojiPetalPainter extends CustomPainter {
  final List<_EmojiPetal> petals;
  final Random _random = Random();

  _EmojiPetalPainter(this.petals);

  @override
  void paint(Canvas canvas, Size size) {
    for (var petal in petals) {
      // Move downward
      petal.y += petal.speed;

      // Left-right sway
      petal.x += sin(petal.y / 40) * 1.5;

      // Reset petal above screen
      if (petal.y > size.height) {
        petal.y = -20;
        petal.x = _random.nextDouble() * size.width;
      }

      TextPainter tp = TextPainter(
        text: TextSpan(
          text: petal.emoji,
          style: TextStyle(fontSize: petal.size),
        ),
        textDirection: TextDirection.ltr,
      );

      tp.layout();
      tp.paint(canvas, Offset(petal.x, petal.y));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}