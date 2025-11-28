import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/responsive_utils.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';
import '../../widgets/chatbot_widget.dart';

class MainCustomerScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainCustomerScreen({super.key, this.initialIndex = 0});

  @override
  State<MainCustomerScreen> createState() => _MainCustomerScreenState();
}

class _MainCustomerScreenState extends State<MainCustomerScreen> {
  late int _currentPageIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          body: Stack(
            children: [
              // Top-right gradient overlay like in the home screen
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
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    const HomeScreen(), // Use the HomeScreen widget
                    _FeedScreen(),
                    _SearchScreen(),
                    const WishlistScreen(),
                    const ProfileScreen(),
                  ],
                ),
              ),
              
              // AI Chatbot Widget
              const Positioned.fill(
                child: ChatBotWidget(),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomAppBar(context),
        );
      },
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2139),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnimatedBottomBarButton(
                context,
                label: 'Home',
                index: 0,
                onTap: () => _onBottomNavTap(0),
              ),
              _buildAnimatedBottomBarButton(
                context,
                label: 'Feed',
                index: 1,
                onTap: () => _onBottomNavTap(1),
              ),
              _buildAnimatedBottomBarButton(
                context,
                label: 'Search',
                index: 2,
                onTap: () => _onBottomNavTap(2),
              ),
              _buildAnimatedBottomBarButton(
                context,
                label: 'Wishlist',
                index: 3,
                onTap: () => _onBottomNavTap(3),
              ),
              _buildAnimatedBottomBarButton(
                context,
                label: 'Profile',
                index: 4,
                onTap: () => _onBottomNavTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBottomBarButton(
    BuildContext context, {
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = _currentPageIndex == index;
    final color = isActive ? const Color(0xFF6B73FF) : Colors.white54;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            Container(
              width: 32,
              height: 32,
              child: isActive ? 
                // Animated when active
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween(begin: 0.8, end: 1.2),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: _getIconForIndex(index, isActive),
                    );
                  },
                ) : _getIconForIndex(index, isActive),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconForIndex(int index, bool isActive) {
    final color = isActive ? const Color(0xFF6B73FF) : Colors.white54;
    
    switch (index) {
      case 0:
        return Icon(
          isActive ? Icons.home : Icons.home_outlined,
          color: color,
          size: 24,
        );
      case 1:
        return Icon(
          isActive ? Icons.dynamic_feed : Icons.dynamic_feed_outlined,
          color: color,
          size: 24,
        );
      case 2:
        return Icon(
          isActive ? Icons.search : Icons.search_outlined,
          color: color,
          size: 24,
        );
      case 3:
        return Icon(
          isActive ? Icons.favorite : Icons.favorite_border,
          color: color,
          size: 24,
        );
      case 4:
        return Icon(
          isActive ? Icons.person : Icons.person_outline,
          color: color,
          size: 24,
        );
      default:
        return Icon(
          Icons.home,
          color: color,
          size: 24,
        );
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

// Feed screen
class _FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Social Feed'),
            backgroundColor: const Color(0xFF1E2139),
            foregroundColor: Colors.white,
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dynamic_feed,
                      size: 64,
                      color: Color(0xFF6B73FF),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Social Feed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Coming Soon!',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Search screen
class _SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Search'),
            backgroundColor: const Color(0xFF1E2139),
            foregroundColor: Colors.white,
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2139),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) + 8),
                        border: Border.all(
                          color: const Color(0xFF2A2D3A),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search for products...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color(0xFF6B73FF),
                            size: ResponsiveUtils.getIconSize(context),
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
                  const SizedBox(height: 32),
                  const Icon(
                    Icons.search,
                    size: 64,
                    color: Color(0xFF6B73FF),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Search Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find what you\'re looking for...',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}