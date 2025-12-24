import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/address_provider.dart';
import 'providers/advertisement_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/language_provider.dart';
import 'providers/category_provider.dart';
import 'providers/support_provider.dart';
import 'providers/flash_sale_provider.dart';
import 'providers/coupon_provider.dart';
import 'providers/review_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/social_feed_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/ai_marketing_provider.dart';
import 'providers/app_analytics_provider.dart';
import 'providers/simple_ai_provider.dart';
import 'providers/feature_settings_provider.dart';
import 'providers/product_section_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/report_provider.dart';
import 'providers/social_media_provider.dart';
import 'providers/video_ad_provider.dart';
import 'providers/promotional_banner_provider.dart';
import 'providers/anime_poster_bot_provider.dart';
import 'services/product_bot_service.dart';
import 'l10n/app_localizations.dart';
import 'screens/customer/login_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/customer/customer_support_screen.dart';
import 'screens/admin/admin_support_screen.dart';
import 'screens/admin/admin_coupons_screen.dart';
import 'screens/customer/customer_flash_sales_screen.dart';
import 'screens/customer/flash_sale_detail_screen.dart';
import 'screens/admin/notification_management_screen.dart';
import 'screens/customer/notifications_screen.dart';
import 'screens/customer/notification_settings_screen.dart';
import 'screens/customer/order_history_screen.dart';
import 'screens/social/social_feed_screen.dart';
import 'screens/social/create_post_screen.dart';
import 'screens/admin/admin_prediction_dashboard.dart';
import 'screens/customer/addresses_screen.dart';
import 'screens/admin/admin_user_management_screen.dart';
import 'screens/admin/customer_management_screen.dart';
import 'screens/admin/reports_management_screen.dart';
import 'screens/admin/user_verification_screen.dart';
import 'screens/admin/notification_settings_screen.dart' as admin_notif;
import 'screens/admin/admin_social_media_screen.dart';
import 'screens/admin/admin_video_ads_screen.dart';
import 'screens/admin/admin_bot_settings_screen.dart';
import 'screens/admin/admin_official_bot_screen.dart';
import 'screens/admin/admin_promotional_banners_screen.dart';
import 'screens/admin/admin_anime_poster_bot_screen.dart';
import 'screens/admin/admin_flash_sales_screen.dart';

void main() {
  runApp(const KarmaGullyApp());
}

class KarmaGullyApp extends StatelessWidget {
  const KarmaGullyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => AdvertisementProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => FlashSaleProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ChatBotProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SocialFeedProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => AIMarketingProvider()),
        ChangeNotifierProvider(create: (_) => AppAnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => SimpleAIProvider()),
        ChangeNotifierProvider(create: (_) => FeatureSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProductSectionProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SocialMediaProvider()),
        ChangeNotifierProvider(create: (_) => VideoAdProvider()),
        ChangeNotifierProvider(create: (_) => PromotionalBannerProvider()),
        ChangeNotifierProvider(create: (_) => AnimePosterBotProvider()),
      ],
      child: Consumer3<AuthProvider, ThemeProvider, LanguageProvider>(
        builder: (context, authProvider, themeProvider, languageProvider, child) {
          // Initialize prediction provider with real data providers
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
            final productProvider = Provider.of<ProductProvider>(context, listen: false);
            final orderProvider = Provider.of<OrderProvider>(context, listen: false);
            final simpleAIProvider = Provider.of<SimpleAIProvider>(context, listen: false);
            final socialFeedProvider = Provider.of<SocialFeedProvider>(context, listen: false);
            final animeBotProvider = Provider.of<AnimePosterBotProvider>(context, listen: false);
            
            // Connect SimpleAIProvider with ProductProvider for real product access
            simpleAIProvider.setProductProvider(productProvider);
            
            predictionProvider.initializeWithProviders(productProvider, orderProvider);
            
            // Connect SocialFeedProvider with AuthProvider for profile pictures
            socialFeedProvider.setAuthProvider(authProvider);
            
            // Initialize Simple AI system
            final simpleAI = Provider.of<SimpleAIProvider>(context, listen: false);
            simpleAI.initialize();
            
            // 🤖 Initialize Anime Poster Bot
            animeBotProvider.initialize(productProvider);
            
            // 🤖 Initialize Product Bot Service
            final botService = ProductBotService(socialFeedProvider, productProvider);
            productProvider.setBotService(botService);
            botService.startBot();
            
            print('🚀 Simple AI Marketing System initialized successfully!');
            print('🤖 Product Bot Service activated! Auto-posting enabled.');
          });
          
          return MaterialApp(
            title: 'KarmaGully',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.currentLocale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('en'),
              Locale('hi'),
              Locale('bn'),
              Locale('ta'),
            ],
            key: ValueKey(languageProvider.currentLocale.toString()),
            home: _getHomeScreen(authProvider),
            routes: {
              '/customer-support': (context) => const CustomerSupportScreen(),
              '/admin-support': (context) => const AdminSupportScreen(),
              '/admin-coupons': (context) => const AdminCouponsScreen(),
              '/customer-flash-sales': (context) => const CustomerFlashSalesScreen(),
              '/flash-sale-detail': (context) => const FlashSaleDetailScreen(),
              '/notification-management': (context) => const NotificationManagementScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/notification-settings': (context) => const NotificationSettingsScreen(),
              '/order-history': (context) => const OrderHistoryScreen(),
              '/social-feed': (context) => const SocialFeedScreen(),
              '/create-post': (context) => const CreatePostScreen(),
              '/admin-predictions': (context) => const AdminPredictionDashboard(),
              '/addresses': (context) => const AddressesScreen(),
              '/admin-user-management': (context) => const AdminUserManagementScreen(),
              '/customer-management': (context) => const CustomerManagementScreen(),
              '/admin-reports-management': (context) => const ReportsManagementScreen(),
              '/admin-notification-settings': (context) => const admin_notif.NotificationSettingsScreen(),
              '/user-verification': (context) => const UserVerificationScreen(),
              '/admin-video-ads': (context) => const AdminVideoAdsScreen(),
              '/admin-social-media': (context) => const AdminSocialMediaScreen(),
              '/admin-bot-settings': (context) => const AdminBotSettingsScreen(),
              '/admin-official-bot': (context) => const AdminOfficialBotScreen(),
              '/admin-promotional-banners': (context) => const AdminPromotionalBannersScreen(),
              '/admin-anime-poster-bot': (context) => const AdminAnimePosterBotScreen(),
              '/admin-flash-sales': (context) => const AdminFlashSalesScreen(),
            },
          );
        },
      ),
    );
  }

  Widget _getHomeScreen(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }
    
    if (authProvider.isAdmin) {
      return const AdminDashboard();
    }
    
    return const HomeScreen();
  }
}
