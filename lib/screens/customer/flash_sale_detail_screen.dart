import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/flash_sale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/flash_sale.dart';
import '../../models/product.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/navigation_helper.dart';

class FlashSaleDetailScreen extends StatefulWidget {
  const FlashSaleDetailScreen({super.key});

  @override
  State<FlashSaleDetailScreen> createState() => _FlashSaleDetailScreenState();
}

class _FlashSaleDetailScreenState extends State<FlashSaleDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  late List<AnimationController> _productControllers;
  
  FlashSale? flashSale;
  List<Product> flashSaleProducts = [];

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _productControllers = List.generate(
      10,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['flashSaleId'] != null) {
        final flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);
        flashSale = flashSaleProvider.getFlashSaleById(args['flashSaleId']);
        
        if (flashSale != null) {
          _loadFlashSaleProducts();
        }
      }
      
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _contentController.forward();
      });
      _pulseController.repeat();
    });
  }

  void _loadFlashSaleProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (flashSale != null && flashSale!.productIds.isNotEmpty) {
      // Filter products by the flash sale's product IDs
      flashSaleProducts = productProvider.products
          .where((product) => flashSale!.productIds.contains(product.id))
          .toList();
    } else {
      // Fallback: show first 6 products if no specific products assigned
      flashSaleProducts = productProvider.products.take(6).toList();
    }
    
    debugPrint('Flash sale products loaded: ${flashSaleProducts.length}');
    debugPrint('Total products available: ${productProvider.products.length}');
    
    // Start product animations
    for (int i = 0; i < _productControllers.length && i < flashSaleProducts.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 100)), () {
        if (mounted) _productControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    for (var controller in _productControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (flashSale == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flash Sale'),
        ),
        body: const Center(
          child: Text('Flash sale not found'),
        ),
      );
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final Color bannerColor = flashSale!.bannerColor != null 
            ? Color(int.parse(flashSale!.bannerColor!.replaceFirst('#', '0xff')))
            : Colors.deepOrange;

        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(isDarkMode, bannerColor),
              SliverToBoxAdapter(
                child: _buildContent(isDarkMode, bannerColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode, Color bannerColor) {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getScreenHeight(context) * 0.35,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: bannerColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: ResponsiveUtils.getIconSize(context),
        ),
        onPressed: () => NavigationHelper.safePop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: FadeTransition(
          opacity: _headerController,
          child: Text(
            flashSale!.title,
            style: TextStyle(
              fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
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
              // Background pattern
              Positioned.fill(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, -1),
                    end: Offset.zero,
                  ).animate(_headerController),
                  child: Container(
                    decoration: BoxDecoration(
                      backgroundBlendMode: BlendMode.overlay,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: ResponsiveUtils.getVerticalPadding(context) * 2,
                left: ResponsiveUtils.getHorizontalPadding(context),
                right: ResponsiveUtils.getHorizontalPadding(context),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(_headerController),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Live indicator
                      if (flashSale!.isActive)
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.getHorizontalSpacing(context),
                              vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.4,
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
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5),
                                Text(
                                  'LIVE NOW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                      
                      // Discount percentage
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getHorizontalSpacing(context) * 1.5,
                          vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'UP TO ${flashSale!.discountPercentage.toInt()}% OFF',
                          style: TextStyle(
                            color: bannerColor,
                            fontSize: ResponsiveUtils.getTitleFontSize(context),
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildContent(bool isDarkMode, Color bannerColor) {
    return FadeTransition(
      opacity: _contentController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
          
          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About This Sale',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                Text(
                  flashSale!.description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
          
          // Countdown timer
          _buildCountdownTimer(isDarkMode),
          
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
          
          // Products section
          _buildProductsSection(isDarkMode, bannerColor),
          
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer(bool isDarkMode) {
    return Consumer<FlashSaleProvider>(
      builder: (context, provider, child) {
        final timeRemaining = flashSale!.timeRemaining;
        final hours = timeRemaining.inHours;
        final minutes = timeRemaining.inMinutes % 60;
        final seconds = timeRemaining.inSeconds % 60;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
          padding: EdgeInsets.all(ResponsiveUtils.getVerticalPadding(context)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.withOpacity(0.1), Colors.orange.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                'Sale Ends In',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours', isDarkMode),
                  _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Minutes', isDarkMode),
                  _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Seconds', isDarkMode),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit(String value, String label, bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: ResponsiveUtils.getScreenWidth(context) * 0.15,
          height: ResponsiveUtils.getScreenWidth(context) * 0.15,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.5),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getCaptionFontSize(context),
            color: AppColors.getTextSecondaryColor(isDarkMode),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(bool isDarkMode, Color bannerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
          child: Text(
            'Featured Products',
            style: TextStyle(
              fontSize: ResponsiveUtils.getTitleFontSize(context),
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
        
        if (flashSaleProducts.isEmpty)
          Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: bannerColor),
            ),
          )
        else
          Container(
            height: ResponsiveUtils.getProductCardHeight(context) + 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
              itemCount: flashSaleProducts.length,
              itemBuilder: (context, index) {
                final product = flashSaleProducts[index];
                final animationController = index < _productControllers.length 
                    ? _productControllers[index] 
                    : _contentController;
                
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animationController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: animationController,
                    child: Container(
                      width: ResponsiveUtils.getScreenWidth(context) * 0.45,
                      margin: EdgeInsets.only(right: ResponsiveUtils.getHorizontalSpacing(context)),
                      child: _buildProductCard(product, isDarkMode, bannerColor),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(Product product, bool isDarkMode, Color bannerColor) {
    // Calculate flash sale price (simulate discount)
    final originalPrice = product.price;
    final discountedPrice = originalPrice * (1 - flashSale!.discountPercentage / 100);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
      ),
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/product-detail',
            arguments: {'product': product},
          );
        },
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                        topRight: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  // Discount badge
                  Positioned(
                    top: ResponsiveUtils.getVerticalSpacing(context) * 0.5,
                    right: ResponsiveUtils.getHorizontalSpacing(context) * 0.5,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getHorizontalSpacing(context) * 0.5,
                        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        color: bannerColor,
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                      ),
                      child: Text(
                        '-${flashSale!.discountPercentage.toInt()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.getCaptionFontSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextColor(isDarkMode),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.3),
                    
                    // Prices
                    Row(
                      children: [
                        Text(
                          '\$${discountedPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                            fontWeight: FontWeight.bold,
                            color: bannerColor,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5),
                        Expanded(
                          child: Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getCaptionFontSize(context),
                              color: AppColors.getTextSecondaryColor(isDarkMode),
                              decoration: TextDecoration.lineThrough,
                            ),
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
  }
}