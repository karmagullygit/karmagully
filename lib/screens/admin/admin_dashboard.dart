import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/navigation_helper.dart';
import 'admin_categories_screen.dart';
import 'simple_ai_dashboard.dart';
import 'ads_tracking_setup_screen.dart';
import 'campaign_analytics_screen.dart';
import 'ads_management_screen.dart';
import 'ai_recommendation_settings_screen.dart';
import 'admin_feature_settings_screen.dart';
import 'admin_featured_products_screen.dart';
import 'admin_sections_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        automaticallyImplyLeading: false,
        actions: [
          // Theme toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    auth.logout();
                    NavigationHelper.navigateToLogin(context);
                  } else if (value == 'customer') {
                    NavigationHelper.navigateToHome(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'customer',
                    child: Row(
                      children: [
                        Icon(Icons.store),
                        SizedBox(width: 8),
                        Text('Customer View'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${auth.currentUser?.name ?? 'Admin'}!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Manage your store from here'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Quick Stats
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final totalProducts = productProvider.products.length;
                final lowStockProducts = productProvider.products
                    .where((p) => p.stock < 10)
                    .length;
                final outOfStockProducts = productProvider.products
                    .where((p) => p.stock == 0)
                    .length;
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      'Total Products',
                      totalProducts.toString(),
                      Icons.inventory,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Low Stock',
                      lowStockProducts.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Out of Stock',
                      outOfStockProducts.toString(),
                      Icons.error,
                      Colors.red,
                    ),
                    _buildStatCard(
                      'Categories',
                      '3', // Electronics, Fashion, Home
                      Icons.category,
                      Colors.green,
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Management Options
            const Text(
              'Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Column(
              children: [
                _buildManagementTile(
                  'Product Management',
                  'Add, edit, and manage your products',
                  Icons.inventory_2,
                  Colors.blue,
                  () => NavigationHelper.navigateToAdminProducts(context),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Featured Products',
                  'Select products to feature on home screen',
                  Icons.star,
                  Colors.amber,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminFeaturedProductsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Product Sections',
                  'Create custom sections for products',
                  Icons.category,
                  const Color(0xFF6B73FF),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminSectionsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Order Management',
                  'View and manage customer orders',
                  Icons.receipt_long,
                  Colors.blue,
                  () => NavigationHelper.navigateToOrderManagement(context),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Advertisement Management',
                  'Manage carousel banners and video ads',
                  Icons.campaign,
                  Colors.purple,
                  () => NavigationHelper.navigateToAdManagement(context),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Category Management',
                  'Add, edit, and manage product categories',
                  Icons.category,
                  Colors.indigo,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminCategoriesScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Flash Sales',
                  'Create and manage flash sales with countdown timers',
                  Icons.flash_on,
                  Colors.deepOrange,
                  () => Navigator.pushNamed(context, '/admin-flash-sales'),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Coupons & Discounts',
                  'Create and manage discount coupons for customers',
                  Icons.confirmation_number,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/admin-coupons'),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Feature Settings',
                  'Enable or disable app features for customers',
                  Icons.toggle_on,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminFeatureSettingsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'AI Predictions',
                  'Stock & demand forecasting with AI analytics',
                  Icons.psychology,
                  Colors.teal,
                  () => Navigator.pushNamed(context, '/admin-predictions'),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'AI Recommendations',
                  'Customize AI recommendation display and content',
                  Icons.recommend,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIRecommendationSettingsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'AI Marketing Assistant',
                  'Generate marketing & sales plans for your products',
                  Icons.auto_fix_high,
                  Colors.indigo,
                  () => NavigationHelper.navigateToAIMarketing(context),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  '🤖 Advanced AI Marketing',
                  'Auto-marketing with real-time data analysis & execution',
                  Icons.smart_toy,
                  Colors.deepPurple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleAIDashboard(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  '🎯 Ads Management',
                  'Create, edit, delete and customize all advertisements',
                  Icons.ads_click,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdsManagementScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  '📱 Ads Tracking Setup',
                  'Configure Meta SDK & Firebase for campaign tracking',
                  Icons.track_changes,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdsTrackingSetupScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  '📊 Campaign Analytics',
                  'View ad performance & conversion tracking data',
                  Icons.analytics,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CampaignAnalyticsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Push Notifications',
                  'Create and manage push notifications',
                  Icons.notifications_active,
                  Colors.red,
                  () => Navigator.pushNamed(context, '/notification-management'),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Customer Support',
                  'Manage customer support tickets',
                  Icons.support_agent,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/admin-support'),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Customer Management',
                  'Manage customer accounts and data',
                  Icons.people,
                  Colors.green,
                  () => _showComingSoon(context, 'Customer Management'),
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  'Analytics',
                  'View sales reports and analytics',
                  Icons.analytics,
                  Colors.orange,
                  () => _showComingSoon(context, 'Analytics'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature will be available in the next update!'),
        actions: [
          TextButton(
            onPressed: () => NavigationHelper.safePopDialog(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}