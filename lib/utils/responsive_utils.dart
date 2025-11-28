import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double _tabletBreakpoint = 600.0;
  static const double _desktopBreakpoint = 1200.0;

  // Device type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _tabletBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _tabletBreakpoint && width < _desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }

  // Screen dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Carousel responsive dimensions - Increased size
  static double getCarouselHeight(BuildContext context) {
    final height = getScreenHeight(context);
    if (isDesktop(context)) {
      return (height * 0.40).clamp(300.0, 400.0); // Much bigger: increased from 0.35 to 0.40
    } else if (isTablet(context)) {
      return (height * 0.38).clamp(280.0, 350.0); // Much bigger: increased from 0.32 to 0.38
    } else {
      // Mobile - much bigger: increased from 30% to 35%
      return (height * 0.35).clamp(240.0, 300.0); // Much bigger: increased from 0.30 to 0.35
    }
  }

  static double getCarouselIndicatorHeight(BuildContext context) {
    return getCarouselHeight(context) * 0.15; // 15% of carousel height
  }

  static double getCarouselContentHeight(BuildContext context) {
    return getCarouselHeight(context) * 0.85; // 85% of carousel height
  }

  // Video player responsive dimensions - Made even smaller to prevent overflow
  static double getVideoPlayerExpandedWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (isDesktop(context)) {
      return width * 0.2; // Very small on desktop
    } else if (isTablet(context)) {
      return width * 0.28; // Smaller on tablet
    } else {
      return width * 0.35; // Much smaller on mobile
    }
  }

  static double getVideoPlayerExpandedHeight(BuildContext context) {
    final height = getScreenHeight(context);
    if (isDesktop(context)) {
      return height * 0.15; // Very small
    } else if (isTablet(context)) {
      return height * 0.18; // Smaller
    } else {
      return height * 0.22; // Much smaller on mobile
    }
  }

  static double getVideoPlayerMinimizedSize(BuildContext context) {
    final width = getScreenWidth(context);
    if (isDesktop(context)) {
      return width * 0.04; // Very small on desktop
    } else if (isTablet(context)) {
      return width * 0.05; // Smaller on tablet
    } else {
      return width * 0.08; // Much smaller on mobile
    }
  }

  // Product card responsive dimensions
  static double getProductCardHeight(BuildContext context) {
    final height = getScreenHeight(context);
    if (isDesktop(context)) {
      return (height * 0.25).clamp(200.0, 280.0);
    } else if (isTablet(context)) {
      return (height * 0.22).clamp(180.0, 250.0);
    } else {
      return (height * 0.20).clamp(160.0, 220.0);
    }
  }

  static double getProductCardImageHeight(BuildContext context) {
    return getProductCardHeight(context) * 0.55; // 55% of card height for more space
  }

  static double getProductCardInfoHeight(BuildContext context) {
    return getProductCardHeight(context) * 0.45; // 45% of card height
  }

  static double getProductCardWidth(BuildContext context) {
    final width = getScreenWidth(context);
    final padding = getHorizontalPadding(context) * 2;
    final spacing = getHorizontalSpacing(context);
    
    if (isDesktop(context)) {
      return (width - padding - (spacing * 3)) / 4; // 4 columns
    } else if (isTablet(context)) {
      return (width - padding - (spacing * 2)) / 3; // 3 columns
    } else {
      return (width - padding - spacing) / 2; // 2 columns
    }
  }

  // General responsive spacing
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return 32.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 16.0;
    }
  }

  static double getVerticalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 12.0;
    }
  }

  static double getHorizontalSpacing(BuildContext context) {
    if (isDesktop(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 8.0;
    }
  }

  static double getVerticalSpacing(BuildContext context) {
    if (isDesktop(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 8.0;
    }
  }

  // Indicator sizes
  static double getIndicatorSize(BuildContext context) {
    if (isDesktop(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 7.0;
    } else {
      return 6.0;
    }
  }

  // Font sizes
  static double getTitleFontSize(BuildContext context) {
    if (isDesktop(context)) {
      return 28.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 20.0;
    }
  }

  static double getBodyFontSize(BuildContext context) {
    if (isDesktop(context)) {
      return 18.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 14.0;
    }
  }

  static double getCaptionFontSize(BuildContext context) {
    if (isDesktop(context)) {
      return 14.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 10.0;
    }
  }

  // Icon sizes
  static double getIconSize(BuildContext context) {
    if (isDesktop(context)) {
      return 28.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 20.0;
    }
  }

  // Border radius
  static double getBorderRadius(BuildContext context) {
    if (isDesktop(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 8.0;
    }
  }

  // Safe area helpers
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double getSafeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getSafeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // Flash sale banner responsive dimensions
  static double getFlashSaleBannerHeight(BuildContext context) {
    final height = getScreenHeight(context);
    if (isDesktop(context)) {
      return (height * 0.25).clamp(200.0, 250.0);
    } else if (isTablet(context)) {
      return (height * 0.22).clamp(180.0, 220.0);
    } else {
      return (height * 0.20).clamp(160.0, 200.0);
    }
  }

  static double getFlashSaleBannerWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (isDesktop(context)) {
      return (width * 0.25).clamp(280.0, 350.0);
    } else if (isTablet(context)) {
      return (width * 0.4).clamp(250.0, 300.0);
    } else {
      return (width * 0.75).clamp(250.0, 280.0);
    }
  }

  // Product grid responsive dimensions
  static double getProductGridHeight(BuildContext context) {
    final height = getScreenHeight(context);
    if (isDesktop(context)) {
      return (height * 0.4).clamp(300.0, 400.0);
    } else if (isTablet(context)) {
      return (height * 0.35).clamp(250.0, 320.0);
    } else {
      return (height * 0.3).clamp(200.0, 280.0);
    }
  }

  static double getProductImageHeight(BuildContext context) {
    final cardHeight = getProductGridHeight(context);
    return cardHeight * 0.6; // 60% of card height for image
  }

  static double getProductInfoHeight(BuildContext context) {
    final cardHeight = getProductGridHeight(context);
    return cardHeight * 0.4; // 40% of card height for info
  }

  static double getProductButtonHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 40.0;
    } else if (isTablet(context)) {
      return 36.0;
    } else {
      return 32.0;
    }
  }

  static int getProductGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  static double getProductGridAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 0.8;
    } else if (isTablet(context)) {
      return 0.75;
    } else {
      return 0.7;
    }
  }

  // Bottom Navigation responsive dimensions
  static double getBottomNavHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 90.0;
    } else if (isTablet(context)) {
      return 80.0;
    } else {
      return 70.0;
    }
  }

  static double getBottomNavPadding(BuildContext context) {
    if (isDesktop(context)) {
      return 20.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 12.0;
    }
  }

  static double getBottomNavIconSize(BuildContext context) {
    if (isDesktop(context)) {
      return 26.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 22.0;
    }
  }

  static double getBottomNavFontSize(BuildContext context) {
    if (isDesktop(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 11.0;
    } else {
      return 10.0;
    }
  }

  static double getBottomNavIndicatorHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 4.0;
    } else if (isTablet(context)) {
      return 3.5;
    } else {
      return 3.0;
    }
  }
}