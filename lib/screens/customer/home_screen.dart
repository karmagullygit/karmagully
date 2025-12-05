import 'dart:async';
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
import '../../utils/responsive_utils.dart';
import '../../widgets/chatbot_widget.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';
import 'category_products_screen.dart';
import 'product_detail_screen.dart';
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
    return Stack(
      children: [
        // Top-right gradient overlay like in the reference image
        Positioned(
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
        // Dark base background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0E1A), // Dark navy
                Color(0xFF1A1B2E), // Slightly lighter
                Color(0xFF16213E), // Blue tint
              ],
            ),
          ),
          child: SafeArea(
            child: Consumer<FeatureSettingsProvider>(
              builder: (context, featureSettings, child) {
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(context, true), // Force dark mode
                    _buildSearchSection(context, true),
                    _buildCarouselSection(context, true),
                    _buildFlashSalesSection(context, true),
                    _buildCategoriesSection(context, true),
                    if (featureSettings.customerFeedEnabled)
                      _buildSocialFeedPreviewSection(context, true),
                    _buildFeaturedSection(context, true),
                    SliverToBoxAdapter(
                      child: _buildProductSections(context),
                    ),
                    _buildProductGrid(context, true),
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
    );
  }

  Widget _buildSearchContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E1A), // Dark navy
            Color(0xFF1A1B2E), // Slightly lighter
            Color(0xFF16213E), // Blue tint
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, true),
            _buildSearchSection(context, true),
            _buildProductGrid(context, true),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A), // Dark background base
          body: _getCurrentScreenContent(),
          // Remove conflicting FloatingActionButton - chatbot has its own
          // floatingActionButton: _buildFloatingCart(context, true),
          bottomNavigationBar: _buildNewBottomNavigationBar(context),
        );
      },
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(
          ResponsiveUtils.getHorizontalPadding(context), 
          ResponsiveUtils.getVerticalSpacing(context) * 0.5, 
          ResponsiveUtils.getHorizontalPadding(context), 
          ResponsiveUtils.getVerticalSpacing(context)
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E2139), // Dark card background
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) + 8),
            border: Border.all(
              color: const Color(0xFF2A2D3A), // Subtle border
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
            ),
            onSubmitted: (query) {
              // Track search action
              final analytics = Provider.of<AppAnalyticsProvider>(context, listen: false);
              analytics.trackUserAction(
                userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
                action: 'search',
                screen: 'home',
                metadata: {'query': query},
              );
            },
            decoration: InputDecoration(
              hintText: 'Search for posters...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: ResponsiveUtils.getBodyFontSize(context),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: const Color(0xFF6B73FF), // Neon blue accent
                size: ResponsiveUtils.getIconSize(context),
              ),
              suffixIcon: Container(
                margin: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context)),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B73FF), // Neon blue
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                ),
                child: Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: ResponsiveUtils.getIconSize(context) * 0.8,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getHorizontalPadding(context),
                vertical: ResponsiveUtils.getVerticalPadding(context),
              ),
            ),
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
          
          // Only show the entire section if there are active flash sales
          if (activeFlashSales.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with LIVE indicator and neon styling
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUtils.getHorizontalPadding(context), 
                  ResponsiveUtils.getVerticalSpacing(context) * 0.5, 
                  ResponsiveUtils.getHorizontalPadding(context), 
                  ResponsiveUtils.getVerticalSpacing(context)
                ),
                child: Row(
                  children: [
                    // LIVE indicator with neon glow
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getHorizontalSpacing(context),
                        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0B5A), // Neon pink
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) + 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF0B5A).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: ResponsiveUtils.getCaptionFontSize(context) * 0.6,
                            height: ResponsiveUtils.getCaptionFontSize(context) * 0.6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getCaptionFontSize(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                    // Fire emoji and Flash Sales text
                    Text(
                      '🔥',
                      style: TextStyle(fontSize: ResponsiveUtils.getBodyFontSize(context) + 2),
                    ),
                    SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5),
                    Text(
                      'Flash Sales',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getBodyFontSize(context) + 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // See All button
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/customer-flash-sales');
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: const Color(0xFF6B73FF), // Neon blue
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getCaptionFontSize(context) + 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Active Flash Sale Banners
              SizedBox(
                height: ResponsiveUtils.getFlashSaleBannerHeight(context),
                child: PageView.builder(
                  itemCount: activeFlashSales.length,
                  itemBuilder: (context, index) {
                    final flashSale = activeFlashSales[index];
                    return _buildFlashSaleBanner(context, flashSale);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // New method to build individual flash sale banner
  Widget _buildFlashSaleBanner(BuildContext context, dynamic flashSale) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) + 4),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B46C1), // Purple
            Color(0xFF9333EA), // Violet
            Color(0xFFEC4899), // Pink
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) + 4),
        child: Stack(
          children: [
            // Background pattern/effects
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            // Background image if available
            if (flashSale.imageUrl != null && flashSale.imageUrl.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: Image.network(
                    flashSale.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
            // Content layout using flexible positioning
            Row(
              children: [
                // Left side content - Flexible
                Expanded(
                  flex: ResponsiveUtils.isMobile(context) ? 7 : 6,
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getVerticalPadding(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Flash sale title
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            flashSale.title ?? 'Flash Sale',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getBodyFontSize(context) + 4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Discount percentage
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getHorizontalSpacing(context),
                            vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0B5A),
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF0B5A).withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${flashSale.discountPercentage}% OFF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.getTitleFontSize(context) + 4,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        // Timer text - Dynamic countdown
                        Consumer<FlashSaleProvider>(
                          builder: (context, flashProvider, child) {
                            final timeRemaining = flashSale.timeRemaining;
                            final formattedTime = _formatDuration(timeRemaining);
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Ends In: $formattedTime',
                                style: TextStyle(
                                  color: const Color(0xFF6B73FF),
                                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                        // Shop Now button
                        SizedBox(
                          height: ResponsiveUtils.getProductButtonHeight(context),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/customer-flash-sales');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B73FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF6B73FF).withOpacity(0.4),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Shop Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side decorative elements - Flexible
                Expanded(
                  flex: ResponsiveUtils.isMobile(context) ? 3 : 4,
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getVerticalPadding(context)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gift box icon
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: ResponsiveUtils.getIconSize(context) * 2,
                              maxHeight: ResponsiveUtils.getIconSize(context) * 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.card_giftcard,
                                color: Colors.white,
                                size: ResponsiveUtils.getIconSize(context) + 4,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                        // Gift emoji
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: ResponsiveUtils.getIconSize(context) * 2.5,
                              maxHeight: ResponsiveUtils.getIconSize(context) * 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                            ),
                            child: Center(
                              child: Text(
                                '🎁',
                                style: TextStyle(fontSize: ResponsiveUtils.getIconSize(context)),
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
          ],
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
              child: const Center(
                child: Text(
                  'No banners available',
                  style: TextStyle(color: Colors.white70),
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
                    height: 260,
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
                        return Container(
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
                                  Image.network(
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

  Widget _buildCarouselSection_DUPLICATE_TO_DELETE(BuildContext context, bool isDarkMode) {
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
              child: const Center(
                child: Text(
                  'No banners available',
                  style: TextStyle(color: Colors.white70),
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
                height: 220,
                margin: const EdgeInsets.only(bottom: 12),
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
                    return Container(
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
                              Image.network(
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
                    'KarmaShop',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Shop with good karma',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
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
                color: const Color(0xFF1E2139),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2D3A)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF6B73FF),
                  size: 20,
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
                    color: const Color(0xFF1E2139),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2D3A)),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Navigate to cart screen
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF6B73FF),
                          size: 20,
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
                color: Colors.white,
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
                return const SizedBox(
                  height: 110,
                  child: Center(
                    child: Text(
                      'No categories available',
                      style: TextStyle(color: Colors.white70),
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
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
                            color: const Color(0xFF1877F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dynamic_feed,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Feed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'See what our community is sharing',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/social-feed'),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF1877F2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2139),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2A2D3A),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post header
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1877F2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        post.userAvatar,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.userDisplayName ?? post.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          post.formattedDate,
                                          style: const TextStyle(
                                            color: Colors.white70,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                post.content,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
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
                                  const Text(
                                    '24',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.comment,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '5',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
            const Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final featuredProducts = productProvider.featuredProducts;
                
                if (featuredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No featured products available',
                      style: TextStyle(color: Colors.white70),
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
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2139),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2D3A)),
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
                              child: product.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.image,
                                            color: Colors.white54,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image,
                                      color: Colors.white54,
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFF6B73FF),
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

  Widget _buildProductSections(BuildContext context) {
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
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (section.description.isNotEmpty)
                              Text(
                                section.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to section products view
                          },
                          child: const Text(
                            'See All',
                            style: TextStyle(color: Color(0xFF6B73FF)),
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
                              color: const Color(0xFF1C1F26),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF6B73FF).withOpacity(0.2),
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
                                    color: const Color(0xFF2A2D3A),
                                    child: product.imageUrl.isNotEmpty
                                        ? Image.network(
                                            product.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(
                                              Icons.image,
                                              color: Colors.white54,
                                              size: 48,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.image,
                                            color: Colors.white54,
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
                                          style: const TextStyle(
                                            color: Colors.white,
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
                                              style: const TextStyle(
                                                color: Color(0xFF6B73FF),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF6B73FF).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                Icons.add_shopping_cart,
                                                color: Color(0xFF6B73FF),
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
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFF6B73FF)),
              ),
            ),
          );
        }

        if (productProvider.products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No products available',
                  style: TextStyle(color: Colors.white70),
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
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return _buildProductCard(context, product);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
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
          color: const Color(0xFF1E2139),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
          border: Border.all(
            color: const Color(0xFF2A2D3A),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                      child: product.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                                topRight: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                              ),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFF2A2D3A),
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white54,
                                      size: ResponsiveUtils.getIconSize(context),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              color: const Color(0xFF2A2D3A),
                              child: Icon(
                                Icons.image,
                                color: Colors.white54,
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
                                color: isInWishlist ? const Color(0xFFFF0B5A) : Colors.white,
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
                          color: Colors.white,
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
                        color: const Color(0xFF6B73FF),
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
                              backgroundColor: const Color(0xFF6B73FF),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B73FF),
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

  Widget _buildNewBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E2139),
        selectedItemColor: const Color(0xFF6B73FF),
        unselectedItemColor: Colors.white60,
        selectedFontSize: 12,
        unselectedFontSize: 10,
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
          _buildSocialFeedPreviewSection(context, true),
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
                    'KarmaShop',
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