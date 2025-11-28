import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/advertisement_provider.dart';
import '../../models/advertisement.dart';
import '../../models/carousel_banner.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/responsive_utils.dart';
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/advertisement_edit_dialogs.dart';

class AdManagementScreen extends StatefulWidget {
  const AdManagementScreen({super.key});

  @override
  State<AdManagementScreen> createState() => _AdManagementScreenState();
}

class _AdManagementScreenState extends State<AdManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<AnimationController> _itemControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _itemControllers = List.generate(
      10,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    for (var controller in _itemControllers) {
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
                  expandedHeight: ResponsiveUtils.getScreenHeight(context) * 0.15,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.primary,
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
                      opacity: _fadeController,
                      child: Text(
                        'Ad Manager',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getTitleFontSize(context),
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
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                            AppColors.secondary.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -ResponsiveUtils.getScreenWidth(context) * 0.1,
                            top: -ResponsiveUtils.getScreenHeight(context) * 0.05,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, -1),
                                end: Offset.zero,
                              ).animate(_slideController),
                              child: Container(
                                width: ResponsiveUtils.getScreenWidth(context) * 0.4,
                                height: ResponsiveUtils.getScreenWidth(context) * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -ResponsiveUtils.getScreenWidth(context) * 0.15,
                            bottom: -ResponsiveUtils.getScreenHeight(context) * 0.08,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-1, 1),
                                end: Offset.zero,
                              ).animate(_slideController),
                              child: Container(
                                width: ResponsiveUtils.getScreenWidth(context) * 0.5,
                                height: ResponsiveUtils.getScreenWidth(context) * 0.5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(ResponsiveUtils.getScreenHeight(context) * 0.08),
                    child: Container(
                      height: ResponsiveUtils.getScreenHeight(context) * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
                          topRight: Radius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.getTextSecondaryColor(isDarkMode),
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context) * 0.9,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: [
                          Tab(
                            icon: Icon(
                              Icons.view_carousel_rounded,
                              size: ResponsiveUtils.getIconSize(context),
                            ),
                            text: 'Banners',
                          ),
                          Tab(
                            icon: Icon(
                              Icons.video_library_rounded,
                              size: ResponsiveUtils.getIconSize(context),
                            ),
                            text: 'Videos',
                          ),
                          Tab(
                            icon: Icon(
                              Icons.tune_rounded,
                              size: ResponsiveUtils.getIconSize(context),
                            ),
                            text: 'Settings',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildCarouselBannersTab(isDarkMode),
                _buildVideoAdsTab(isDarkMode),
                _buildSettingsTab(isDarkMode),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(isDarkMode),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddContentBottomSheet(isDarkMode),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(
          Icons.add_rounded,
          size: ResponsiveUtils.getIconSize(context),
        ),
        label: Text(
          'Add Content',
          style: TextStyle(
            fontSize: ResponsiveUtils.getBodyFontSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselBannersTab(bool isDarkMode) {
    return Consumer<AdvertisementProvider>(
      builder: (context, adProvider, child) {
        final banners = adProvider.carouselBanners;

        if (banners.isEmpty) {
          return _buildEmptyState(
            isDarkMode: isDarkMode,
            icon: Icons.view_carousel_rounded,
            title: 'No Banners Yet',
            subtitle: 'Create your first carousel banner to showcase promotions',
            actionText: 'Add Banner',
            onAction: () => _addSampleBanner(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh logic here
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            child: ListView.builder(
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return _buildBannerCard(banners[index], adProvider, isDarkMode, index);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoAdsTab(bool isDarkMode) {
    return Consumer<AdvertisementProvider>(
      builder: (context, adProvider, child) {
        final videoAds = adProvider.advertisements.where((ad) => ad.hasVideo).toList();

        if (videoAds.isEmpty) {
          return _buildEmptyState(
            isDarkMode: isDarkMode,
            icon: Icons.video_library_rounded,
            title: 'No Video Ads Yet',
            subtitle: 'Create engaging video advertisements to boost sales',
            actionText: 'Add Video Ad',
            onAction: () => _addSampleVideoAd(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            child: ListView.builder(
              itemCount: videoAds.length,
              itemBuilder: (context, index) {
                return _buildVideoAdCard(videoAds[index], adProvider, isDarkMode, index);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
          _buildSettingsSection(
            isDarkMode: isDarkMode,
            title: 'Carousel Settings',
            icon: Icons.view_carousel_rounded,
            items: [
              _buildSettingsItem(
                isDarkMode: isDarkMode,
                title: 'Auto-Play Duration',
                subtitle: 'Time between slide transitions',
                trailing: _buildDropdown(isDarkMode, ['2s', '3s', '4s', '5s'], '4s'),
              ),
              _buildSettingsItem(
                isDarkMode: isDarkMode,
                title: 'Show Indicators',
                subtitle: 'Display navigation dots',
                trailing: _buildSwitch(isDarkMode, true),
              ),
              _buildSettingsItem(
                isDarkMode: isDarkMode,
                title: 'Infinite Loop',
                subtitle: 'Continuous carousel rotation',
                trailing: _buildSwitch(isDarkMode, true),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
          _buildSettingsSection(
            isDarkMode: isDarkMode,
            title: 'Video Settings',
            icon: Icons.video_settings_rounded,
            items: [
              _buildSettingsItem(
                isDarkMode: isDarkMode,
                title: 'Player Size',
                subtitle: 'Default video player dimensions',
                trailing: _buildDropdown(isDarkMode, ['Small', 'Medium', 'Large'], 'Medium'),
              ),
              _buildSettingsItem(
                isDarkMode: isDarkMode,
                title: 'Auto-Hide Controls',
                subtitle: 'Hide controls after inactivity',
                trailing: _buildSwitch(isDarkMode, false),
              ),
              _buildSettingsItem(
                isDarkMode: isDarkMode,
                title: 'Background Play',
                subtitle: 'Continue playing in background',
                trailing: _buildSwitch(isDarkMode, false),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
          _buildSettingsSection(
            isDarkMode: isDarkMode,
            title: 'Performance',
            icon: Icons.speed_rounded,
            items: [
              _buildSettingsItem(
                isDarkMode: isDarkMode,
                title: 'Image Caching',
                subtitle: 'Cache images for faster loading',
                trailing: _buildSwitch(isDarkMode, true),
              ),
              _buildSettingsItem(
                isDarkMode: isDarkMode,
                title: 'Preload Next',
                subtitle: 'Preload next carousel item',
                trailing: _buildSwitch(isDarkMode, true),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 3),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDarkMode,
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: FadeTransition(
        opacity: _fadeController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: ResponsiveUtils.getScreenWidth(context) * 0.3,
                    height: ResponsiveUtils.getScreenWidth(context) * 0.3,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: ResponsiveUtils.getIconSize(context) * 3,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 2),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 3),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(
                Icons.add_rounded,
                size: ResponsiveUtils.getIconSize(context),
              ),
              label: Text(
                actionText,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
    );
  }

  Widget _buildBannerCard(CarouselBanner banner, AdvertisementProvider provider, bool isDarkMode, int index) {
    if (index < _itemControllers.length) {
      _itemControllers[index].forward();
    }
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: index < _itemControllers.length ? _itemControllers[index] : _fadeController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: index < _itemControllers.length ? _itemControllers[index] : _fadeController,
        child: Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.getVerticalSpacing(context)),
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(isDarkMode),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDarkMode),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and switch
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner.title,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextColor(isDarkMode),
                            ),
                          ),
                          if (banner.subtitle.isNotEmpty) ...[
                            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.3),
                            Text(
                              banner.subtitle,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                                color: AppColors.getTextSecondaryColor(isDarkMode),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: banner.isActive,
                      onChanged: (value) => provider.toggleCarouselBannerStatus(banner.id),
                      activeColor: AppColors.success,
                    ),
                  ],
                ),
              ),
              
              // Preview
              Container(
                margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
                height: ResponsiveUtils.getCarouselHeight(context) * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                  color: _parseColor(banner.backgroundColor),
                  image: banner.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(banner.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Content
                    Positioned(
                      bottom: ResponsiveUtils.getVerticalPadding(context),
                      left: ResponsiveUtils.getHorizontalPadding(context),
                      right: ResponsiveUtils.getHorizontalPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (banner.title.isNotEmpty)
                            Text(
                              banner.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.8,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (banner.subtitle.isNotEmpty) ...[
                            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.3),
                            Text(
                              banner.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Preview label
                    Positioned(
                      top: ResponsiveUtils.getVerticalSpacing(context),
                      right: ResponsiveUtils.getHorizontalSpacing(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getHorizontalSpacing(context),
                          vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                        ),
                        child: Text(
                          'PREVIEW',
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
              
              // Footer with actions
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: ResponsiveUtils.getIconSize(context) * 0.8,
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                    SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5),
                    Text(
                      DateFormat('MMM d, y').format(banner.createdAt),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getCaptionFontSize(context),
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showEditBannerDialog(banner),
                      icon: Icon(
                        Icons.edit_rounded,
                        size: ResponsiveUtils.getIconSize(context) * 0.8,
                      ),
                      label: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDeleteBanner(banner, provider),
                      icon: Icon(
                        Icons.delete_rounded,
                        size: ResponsiveUtils.getIconSize(context) * 0.8,
                        color: AppColors.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                          color: AppColors.error,
                        ),
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
  }

  Widget _buildVideoAdCard(Advertisement ad, AdvertisementProvider provider, bool isDarkMode, int index) {
    if (index < _itemControllers.length) {
      _itemControllers[index].forward();
    }
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: index < _itemControllers.length ? _itemControllers[index] : _fadeController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: index < _itemControllers.length ? _itemControllers[index] : _fadeController,
        child: Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.getVerticalSpacing(context)),
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(isDarkMode),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDarkMode),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ad.title,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextColor(isDarkMode),
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.3),
                          Text(
                            ad.description,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getBodyFontSize(context),
                              color: AppColors.getTextSecondaryColor(isDarkMode),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: ad.isActive,
                      onChanged: (value) => provider.toggleAdvertisementStatus(ad.id),
                      activeColor: AppColors.success,
                    ),
                  ],
                ),
              ),
              
              // Video preview
              Container(
                margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
                height: ResponsiveUtils.getVideoPlayerExpandedHeight(context) * 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                  image: DecorationImage(
                    image: NetworkImage(ad.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.primary,
                              size: ResponsiveUtils.getIconSize(context) * 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Footer
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getHorizontalSpacing(context),
                        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                      ),
                      child: Text(
                        'Priority ${ad.priority}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getCaptionFontSize(context),
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showEditAdDialog(ad),
                      icon: Icon(
                        Icons.edit_rounded,
                        size: ResponsiveUtils.getIconSize(context) * 0.8,
                      ),
                      label: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDeleteAd(ad, provider),
                      icon: Icon(
                        Icons.delete_rounded,
                        size: ResponsiveUtils.getIconSize(context) * 0.8,
                        color: AppColors.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                          color: AppColors.error,
                        ),
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
  }

  Widget _buildSettingsSection({
    required bool isDarkMode,
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.getCardBackgroundColor(isDarkMode),
                borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadowColor(isDarkMode),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.primary,
                            size: ResponsiveUtils.getIconSize(context),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getTitleFontSize(context) * 0.9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Items
                  ...items,
                  
                  SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.5),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required bool isDarkMode,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getCaptionFontSize(context),
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildDropdown(bool isDarkMode, List<String> items, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalSpacing(context),
        vertical: ResponsiveUtils.getVerticalSpacing(context) * 0.3,
      ),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (newValue) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Setting updated to $newValue'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: TextStyle(
            fontSize: ResponsiveUtils.getBodyFontSize(context),
            color: AppColors.getTextColor(isDarkMode),
          ),
          dropdownColor: AppColors.getCardBackgroundColor(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildSwitch(bool isDarkMode, bool value) {
    return Switch.adaptive(
      value: value,
      onChanged: (newValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setting ${newValue ? 'enabled' : 'disabled'}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      activeColor: AppColors.primary,
    );
  }

  void _showAddContentBottomSheet(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: ResponsiveUtils.getScreenHeight(context) * 0.4,
        decoration: BoxDecoration(
          color: AppColors.getCardBackgroundColor(isDarkMode),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
            topRight: Radius.circular(ResponsiveUtils.getBorderRadius(context) * 2),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: ResponsiveUtils.getVerticalSpacing(context)),
              width: ResponsiveUtils.getScreenWidth(context) * 0.15,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
              child: Text(
                'Add New Content',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
            ),
            
            // Options
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context)),
                child: Column(
                  children: [
                    _buildBottomSheetOption(
                      isDarkMode: isDarkMode,
                      icon: Icons.view_carousel_rounded,
                      title: 'Carousel Banner',
                      subtitle: 'Create promotional banner for homepage',
                      onTap: () {
                        Navigator.pop(context);
                        _addSampleBanner();
                      },
                    ),
                    SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                    _buildBottomSheetOption(
                      isDarkMode: isDarkMode,
                      icon: Icons.video_library_rounded,
                      title: 'Video Advertisement',
                      subtitle: 'Add engaging video content',
                      onTap: () {
                        Navigator.pop(context);
                        _addSampleVideoAd();
                      },
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

  Widget _buildBottomSheetOption({
    required bool isDarkMode,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(isDarkMode),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
          border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.getVerticalSpacing(context) * 0.8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: ResponsiveUtils.getIconSize(context) * 1.2,
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
                      fontSize: ResponsiveUtils.getBodyFontSize(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(isDarkMode),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getCaptionFontSize(context),
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: ResponsiveUtils.getIconSize(context) * 0.8,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  void _addSampleBanner() {
    final provider = Provider.of<AdvertisementProvider>(context, listen: false);
    provider.addCarouselBanner(
      title: 'New Promotion ${provider.carouselBanners.length + 1}',
      subtitle: 'Limited Time Offer - Special Discount',
      imageUrl: 'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=800',
      isActive: true,
      order: provider.carouselBanners.length + 1,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Banner added successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addSampleVideoAd() {
    final provider = Provider.of<AdvertisementProvider>(context, listen: false);
    provider.addAdvertisement(
      title: 'Product Video ${provider.advertisements.length + 1}',
      description: 'Engaging video showcasing our latest products and features',
      type: AdType.video,
      placement: AdPlacement.floatingVideo,
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      isActive: true,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 15)),
      priority: 5,
      metadata: {
        'autoplay': true,
        'canDismiss': true,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Video ad added successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditBannerDialog(CarouselBanner banner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditBannerDialog(banner: banner),
    );
  }

  void _showEditAdDialog(Advertisement ad) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditAdvertisementDialog(advertisement: ad),
    );
  }

  void _confirmDeleteBanner(CarouselBanner banner, AdvertisementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
        ),
        title: const Text('Delete Banner'),
        content: Text('Are you sure you want to delete "${banner.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteCarouselBanner(banner.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Banner deleted successfully'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAd(Advertisement ad, AdvertisementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context)),
        ),
        title: const Text('Delete Advertisement'),
        content: Text('Are you sure you want to delete "${ad.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteAdvertisement(ad.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Advertisement deleted successfully'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}