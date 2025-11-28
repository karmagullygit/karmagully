import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/navigation_helper.dart';
import '../customer/language_selection_screen.dart';
import '../customer/customer_support_screen.dart';
import 'edit_profile_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Demo orders are created via addOrder method instead
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(themeProvider.isDarkMode),
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.profile,
              style: TextStyle(
                color: AppColors.getTextColor(themeProvider.isDarkMode),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.getBackgroundColor(themeProvider.isDarkMode),
            elevation: 0,
            iconTheme: IconThemeData(
              color: AppColors.getTextColor(themeProvider.isDarkMode),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(themeProvider.isDarkMode),
                const SizedBox(height: 24),
                _buildProfileStats(themeProvider.isDarkMode),
                const SizedBox(height: 24),
                _buildProfileActions(themeProvider.isDarkMode),
                const SizedBox(height: 24),
                _buildSettingsSection(themeProvider.isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDarkMode),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: auth.currentUser?.profilePicture != null
                    ? ClipOval(
                        child: Builder(builder: (context) {
                          final pic = auth.currentUser!.profilePicture!;
                          try {
                            if (pic.startsWith('http')) {
                              return Image.network(pic, width: 80, height: 80, fit: BoxFit.cover);
                            }
                            return Image.file(File(pic), width: 80, height: 80, fit: BoxFit.cover);
                          } catch (e) {
                            return Text(
                              auth.currentUser?.email.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }
                        }),
                      )
                    : Text(
                        auth.currentUser?.email.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.currentUser?.email ?? 'User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Premium Member',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (auth.currentUser == null) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: auth.currentUser!),
                    ),
                  );
                  // After returning, AuthProvider will have been updated by the edit screen
                },
                icon: Icon(
                  Icons.edit,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileStats(bool isDarkMode) {
    return Consumer2<OrderProvider, WishlistProvider>(
      builder: (context, orderProvider, wishlistProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Orders',
                orderProvider.totalOrders.toString(),
                Icons.shopping_bag_outlined,
                isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Wishlist',
                wishlistProvider.itemCount.toString(),
                Icons.favorite_outline,
                isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Reviews',
                '12',
                Icons.star_outline,
                isDarkMode,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions(bool isDarkMode) {
    return Column(
      children: [
        _buildActionTile(
          'Order History',
          Icons.history,
          () => NavigationHelper.navigateToOrders(context),
          isDarkMode,
        ),
        _buildActionTile(
          'Wishlist',
          Icons.favorite,
          () => NavigationHelper.navigateToWishlist(context),
          isDarkMode,
        ),
        _buildActionTile(
          'Addresses',
          Icons.location_on,
          () {
            Navigator.pushNamed(context, '/addresses');
          },
          isDarkMode,
        ),
        _buildActionTile(
          'Payment Methods',
          Icons.payment,
          () {
            // Navigate to payment methods
          },
          isDarkMode,
        ),
        _buildActionTile(
          'Notifications',
          Icons.notifications,
          () {
            Navigator.pushNamed(context, '/notifications');
          },
          isDarkMode,
        ),
        _buildCustomerSupportTile(isDarkMode),
      ],
    );
  }

  Widget _buildCustomerSupportTile(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.support_agent,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            const Text(
              '💬 Customer Support',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: const Text(
          'Get help with your orders and account',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.primary,
        ),
        onTap: () {
          print('Customer Support clicked!'); // Debug print
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerSupportScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.getTextColor(isDarkMode),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.getTextSecondaryColor(isDarkMode),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.settings,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
          ),
          child: Column(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.darkMode,
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) => themeProvider.toggleTheme(),
                      activeColor: AppColors.primary,
                    ),
                  );
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return ListTile(
                    leading: Text(
                      languageProvider.getCurrentLanguageFlag(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.language,
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      languageProvider.getCurrentLanguageName(),
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Help & Support',
                  style: TextStyle(
                    color: AppColors.getTextColor(isDarkMode),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
                onTap: () {
                  // Navigate to help
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              ListTile(
                leading: Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.getTextColor(isDarkMode),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      _showLogoutDialog(auth);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: AppColors.getCardBackgroundColor(themeProvider.isDarkMode),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.getTextColor(themeProvider.isDarkMode),
                ),
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    auth.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully logged out'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}