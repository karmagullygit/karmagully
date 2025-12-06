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
import 'l10n/app_localizations.dart';
import 'screens/customer/login_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/customer/customer_support_screen.dart';
import 'screens/admin/admin_support_screen.dart';
import 'screens/admin/admin_flash_sales_screen.dart';
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

void main() {
  runApp(const KarmaShopApp());
}

class KarmaShopApp extends StatelessWidget {
  const KarmaShopApp({super.key});

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
      ],
      child: Consumer3<AuthProvider, ThemeProvider, LanguageProvider>(
        builder: (context, authProvider, themeProvider, languageProvider, child) {
          // Initialize prediction provider with real data providers
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
            final productProvider = Provider.of<ProductProvider>(context, listen: false);
            final orderProvider = Provider.of<OrderProvider>(context, listen: false);
            final simpleAIProvider = Provider.of<SimpleAIProvider>(context, listen: false);
            
            // Connect SimpleAIProvider with ProductProvider for real product access
            simpleAIProvider.setProductProvider(productProvider);
            
            predictionProvider.initializeWithProviders(productProvider, orderProvider);
            
            // Initialize Simple AI system
            final simpleAI = Provider.of<SimpleAIProvider>(context, listen: false);
            simpleAI.initialize();
            
            print('🚀 Simple AI Marketing System initialized successfully!');
          });
          
          return MaterialApp(
            title: 'KarmaShop',
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
              '/admin-flash-sales': (context) => const AdminFlashSalesScreen(),
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
