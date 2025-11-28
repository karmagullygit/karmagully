import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/flash_sale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/flash_sale.dart';
import '../../utils/responsive_utils.dart';

class CustomerFlashSalesScreen extends StatefulWidget {
  const CustomerFlashSalesScreen({super.key});

  @override
  State<CustomerFlashSalesScreen> createState() => _CustomerFlashSalesScreenState();
}

class _CustomerFlashSalesScreenState extends State<CustomerFlashSalesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  late List<AnimationController> _cardControllers;
  late ScrollController _scrollController;
  
  int? _focusedFlashSaleIndex;
  String? _focusedFlashSaleId;

  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _cardControllers = List.generate(
      10,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    // Check for navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _focusedFlashSaleIndex = args['focusIndex'] as int?;
        _focusedFlashSaleId = args['flashSaleId'] as String?;
      }
      
      // Start animations
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _contentController.forward();
      });
      _pulseController.repeat();
      
      // Scroll to focused item if specified
      if (_focusedFlashSaleIndex != null) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _scrollToFocusedItem();
        });
      }
    });
  }

  void _scrollToFocusedItem() {
    if (_focusedFlashSaleIndex != null && _scrollController.hasClients) {
      // Calculate approximate item height and scroll position
      final itemHeight = ResponsiveUtils.getScreenHeight(context) * 0.3;
      final targetPosition = _focusedFlashSaleIndex! * itemHeight;
      
      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: ResponsiveUtils.getScreenHeight(context) * 0.25,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalSpacing(context) * 0.3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: ResponsiveUtils.getIconSize(context),
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(_headerController),
                      child: FadeTransition(
                        opacity: _headerController,
                        child: Text(
                          'Flash Sales',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getTitleFontSize(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepOrange,
                                Colors.deepOrange.withOpacity(0.8),
                                Colors.red.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        
                        // Animated background elements
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, -1),
                            end: const Offset(0.5, -0.5),
                          ).animate(_headerController),
                          child: Container(
                            width: ResponsiveUtils.getScreenWidth(context) * 0.6,
                            height: ResponsiveUtils.getScreenWidth(context) * 0.6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 1),
                            end: const Offset(-0.3, 0.7),
                          ).animate(_headerController),
                          child: Container(
                            width: ResponsiveUtils.getScreenWidth(context) * 0.4,
                            height: ResponsiveUtils.getScreenWidth(context) * 0.4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        
                        // Fire icons
                        Positioned(
                          right: ResponsiveUtils.getHorizontalPadding(context),
                          top: ResponsiveUtils.getScreenHeight(context) * 0.08,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Icon(
                              Icons.local_fire_department,
                              size: ResponsiveUtils.getIconSize(context) * 2,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Consumer<FlashSaleProvider>(
              builder: (context, flashSaleProvider, child) {
                final activeFlashSales = flashSaleProvider.activeFlashSales;
                final upcomingFlashSales = flashSaleProvider.upcomingFlashSales;

                if (activeFlashSales.isEmpty && upcomingFlashSales.isEmpty) {
                  return _buildEmptyState(context, isDarkMode);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await flashSaleProvider.loadFlashSales();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                        
                        // Live Flash Sales Section
                        if (activeFlashSales.isNotEmpty) ...[
                          _buildModernSectionHeader(
                            context, 
                            '🔥 Live Flash Sales', 
                            Colors.red, 
                            isDarkMode,
                            subtitle: 'Limited time offers - Act fast!'
                          ),
                          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                          _buildFlashSalesGrid(context, activeFlashSales, isDarkMode, isLive: true),
                          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
                        ],

                        // Upcoming Flash Sales Section
                        if (upcomingFlashSales.isNotEmpty) ...[
                          _buildModernSectionHeader(
                            context, 
                            '⏰ Coming Soon', 
                            Colors.orange, 
                            isDarkMode,
                            subtitle: 'Get ready for these upcoming deals'
                          ),
                          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                          _buildFlashSalesGrid(context, upcomingFlashSales, isDarkMode, isLive: false),
                          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
                        ],

                        // Enhanced Flash Sale Tips
                        _buildModernFlashSaleTips(isDarkMode),
                        SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 3),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return FadeTransition(
      opacity: _contentController,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: ResponsiveUtils.getScreenWidth(context) * 0.4,
                      height: ResponsiveUtils.getScreenWidth(context) * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.flash_off_rounded,
                        size: ResponsiveUtils.getIconSize(context) * 4,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
              Text(
                'No Flash Sales Available',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDarkMode),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              Text(
                'Check back later for amazing deals!\nBe the first to know about upcoming sales.',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 3),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.shopping_bag_rounded,
                  size: ResponsiveUtils.getIconSize(context),
                ),
                label: Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getHorizontalPadding(context) * 2,
                    vertical: ResponsiveUtils.getVerticalPadding(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
                  ),
                  elevation: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSectionHeader(
    BuildContext context, 
    String title, 
    Color color, 
    bool isDarkMode, {
    String? subtitle,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(_contentController),
      child: FadeTransition(
        opacity: _contentController,
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(isDarkMode),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDarkMode),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                ),
                child: Icon(
                  title.contains('Live') ? Icons.local_fire_department : Icons.schedule_rounded,
                  size: ResponsiveUtils.getIconSize(context) * 1.2,
                  color: color,
                ),
              ),
              SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextColor(isDarkMode),
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context) * 0.9,
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashSalesGrid(
    BuildContext context, 
    List<FlashSale> flashSales, 
    bool isDarkMode, {
    required bool isLive,
  }) {
    // Determine grid layout based on screen size
    int crossAxisCount = ResponsiveUtils.isTablet(context) ? 3 : 2;
    if (ResponsiveUtils.isDesktop(context)) crossAxisCount = 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: ResponsiveUtils.getHorizontalSpacing(context),
        mainAxisSpacing: ResponsiveUtils.getVerticalSpacing(context),
        childAspectRatio: 0.75,
      ),
      itemCount: flashSales.length,
      itemBuilder: (context, index) {
        // Start card animation with delay
        if (index < _cardControllers.length) {
          Future.delayed(Duration(milliseconds: index * 100), () {
            if (mounted) _cardControllers[index].forward();
          });
        }
        
        return _buildModernFlashSaleCard(
          context, 
          flashSales[index], 
          isDarkMode, 
          isLive: isLive,
          index: index,
        );
      },
    );
  }

  Widget _buildModernFlashSaleCard(
    BuildContext context, 
    FlashSale flashSale, 
    bool isDarkMode, {
    required bool isLive,
    required int index,
  }) {
    final Color bannerColor = flashSale.bannerColor != null 
        ? Color(int.parse(flashSale.bannerColor!.replaceFirst('#', '0xff')))
        : Colors.deepOrange;

    final animationController = index < _cardControllers.length 
        ? _cardControllers[index] 
        : _contentController;

    // Check if this is the focused flash sale
    final isFocused = (_focusedFlashSaleId != null && flashSale.id == _focusedFlashSaleId) ||
                     (_focusedFlashSaleIndex != null && index == _focusedFlashSaleIndex);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animationController,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween(begin: isFocused ? 0.8 : 1.0, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: isFocused 
                          ? bannerColor.withOpacity(0.3)
                          : AppColors.getShadowColor(isDarkMode),
                      blurRadius: isFocused ? 15 : 10,
                      offset: const Offset(0, 5),
                      spreadRadius: isFocused ? 2 : 0,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _navigateToFlashSaleProducts(context, flashSale),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackgroundColor(isDarkMode),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
                      border: isFocused 
                          ? Border.all(color: bannerColor, width: 2)
                          : null,
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with gradient and live indicator
                      Container(
                        height: ResponsiveUtils.getScreenHeight(context) * 0.15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
                            topRight: Radius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              bannerColor,
                              bannerColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Pattern overlay
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ModernPatternPainter(
                                  Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            
                            // Content
                            Padding(
                              padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context) * 0.8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Live indicator with animation
                                  if (isLive)
                                    ScaleTransition(
                                      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                                        CurvedAnimation(
                                          parent: _pulseController,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ResponsiveUtils.getHorizontalSpacing(context) * 0.8,
                                          vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: ResponsiveUtils.getIconSize(context) * 0.3,
                                              height: ResponsiveUtils.getIconSize(context) * 0.3,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.3),
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
                                    ),
                                  
                                  const Spacer(),
                                  
                                  // Discount badge
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.getHorizontalSpacing(context),
                                      vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${flashSale.discountPercentage.toInt()}% OFF',
                                      style: TextStyle(
                                        color: bannerColor,
                                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content section
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context) * 0.8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                flashSale.title,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextColor(isDarkMode),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.3),

                              // Description
                              Text(
                                flashSale.description,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getCaptionFontSize(context),
                                  color: AppColors.getTextSecondaryColor(isDarkMode),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const Spacer(),

                              // Bottom section with countdown
                              Row(
                                children: [
                                  Icon(
                                    isLive ? Icons.access_time : Icons.schedule,
                                    size: ResponsiveUtils.getIconSize(context) * 0.7,
                                    color: AppColors.getTextSecondaryColor(isDarkMode),
                                  ),
                                  SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.3),
                                  Expanded(
                                    child: Text(
                                      isLive ? 'Ends soon!' : 'Starting soon',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getCaptionFontSize(context),
                                        color: AppColors.getTextSecondaryColor(isDarkMode),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: ResponsiveUtils.getIconSize(context) * 0.6,
                                    color: bannerColor,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernFlashSaleTips(bool isDarkMode) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_contentController),
      child: FadeTransition(
        opacity: _contentController,
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                    ),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.primary,
                      size: ResponsiveUtils.getIconSize(context),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                  Text(
                    'Flash Sale Pro Tips',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(isDarkMode),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              
              ...[
                '⚡ Set notifications to never miss a deal',
                '🎯 Add items to wishlist for instant alerts',
                '💰 Compare prices before the sale starts',
                '🏃‍♂️ Popular items sell out fast - act quickly!',
              ].map((tip) => Padding(
                padding: EdgeInsets.only(bottom: ResponsiveUtils.getVerticalSpacing(context) * 0.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFlashSaleProducts(BuildContext context, FlashSale flashSale) {
    // Navigate to a filtered product list showing only flash sale items
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${flashSale.title} flash sale'),
        backgroundColor: Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Custom painter for modern pattern overlay
class _ModernPatternPainter extends CustomPainter {
  final Color color;

  _ModernPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw geometric pattern
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        final x = (size.width / 6) * (i + 1);
        final y = (size.height / 4) * (j + 1);
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}