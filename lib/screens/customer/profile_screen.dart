import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/support_provider.dart';
import '../../providers/social_media_provider.dart';
import 'customer_chat_screen.dart';
import '../info/about_screen.dart';
import '../info/privacy_policy_screen.dart';
import '../info/terms_screen.dart';
import '../info/refund_screen.dart';
import '../info/shipping_screen.dart';
import '../info/pricing_screen.dart';
import '../info/contact_screen.dart';
import '../info/account_deletion_screen.dart';
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
      // Load social media links
      Provider.of<SocialMediaProvider>(context, listen: false).loadSocialMediaLinks();

      // Ensure customer's support tickets are fresh so "Customer support chat" appears
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<SupportProvider>(context, listen: false).loadCustomerTickets(auth.currentUser!.id);
      }
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
                _buildSocialMediaSection(themeProvider.isDarkMode),
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
                    // Karma ID Display
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: auth.currentUser?.karmaId ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Karma ID copied: ${auth.currentUser?.karmaId}'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fingerprint,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            auth.currentUser?.karmaId ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.copy,
                            size: 10,
                            color: AppColors.getTextSecondaryColor(isDarkMode),
                          ),
                        ],
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
    return Consumer3<OrderProvider, WishlistProvider, ReviewProvider>(
      builder: (context, orderProvider, wishlistProvider, reviewProvider, child) {
        final userReviews = reviewProvider.getUserReviews('user_1');
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Orders',
                orderProvider.totalOrders.toString(),
                Icons.shopping_bag_outlined,
                isDarkMode,
                onTap: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Wishlist',
                wishlistProvider.itemCount.toString(),
                Icons.favorite_outline,
                isDarkMode,
                onTap: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Reviews',
                userReviews.length.toString(),
                Icons.star_outline,
                isDarkMode,
                onTap: () => _showUserReviewsDialog(context, userReviews, isDarkMode),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isDarkMode, {VoidCallback? onTap}) {
    final content = Container(
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
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }
    return content;
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
        _buildCustomerSupportChatTile(isDarkMode),
      ],
    );
  }

  Widget _buildCustomerSupportChatTile(bool isDarkMode) {
    return Consumer2<SupportProvider, AuthProvider>(
      builder: (context, supportProvider, auth, child) {
        final user = auth.currentUser;
        if (user == null) return const SizedBox.shrink();

        // Find an active ticket for this user that is in progress or assigned
        final tickets = supportProvider.getCustomerTickets(user.id);
        final activeList = tickets.where((t) => t.status == 'in_progress' || (t.assignedToAdminId != null)).toList();
        if (activeList.isEmpty) {
          // Locked state - don't show tile if no accepted ticket
          return const SizedBox.shrink();
        }

        final active = activeList.first;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chat,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: const Text(
              'Customer support chat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: const Text('Chat with support about your request'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              // Ensure messages loaded and navigate to chat for the active ticket
              await Provider.of<SupportProvider>(context, listen: false)
                  .loadMessages(active.id);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerChatScreen(ticketId: active.id),
                ),
              );
            },
          ),
        );
      },
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

  Widget _buildSocialMediaSection(bool isDarkMode) {
    return Consumer<SocialMediaProvider>(
      builder: (context, socialProvider, child) {
        final links = socialProvider.socialMediaLinks;

        if (links.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Follow Us',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.getCardBackgroundColor(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect with us on social media',
                    style: TextStyle(
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: links.map((link) {
                      return GestureDetector(
                        onTap: () => _launchSocialURL(link.url, link.name),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _getSocialIconColor(link.iconName).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _getSocialIconColor(link.iconName).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: FaIcon(
                              _getSocialIconData(link.iconName),
                              color: _getSocialIconColor(link.iconName),
                              size: 26,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getSocialIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebookF;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'twitter':
        return FontAwesomeIcons.xTwitter;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'linkedin':
        return FontAwesomeIcons.linkedinIn;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'telegram':
        return FontAwesomeIcons.telegram;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'pinterest':
        return FontAwesomeIcons.pinterestP;
      case 'snapchat':
        return FontAwesomeIcons.snapchat;
      default:
        return FontAwesomeIcons.share;
    }
  }

  Color _getSocialIconColor(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF000000);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'telegram':
        return const Color(0xFF0088CC);
      case 'tiktok':
        return const Color(0xFF010101);
      case 'pinterest':
        return const Color(0xFFBD081C);
      case 'snapchat':
        return const Color(0xFFFFFC00);
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchSocialURL(String url, String platformName) async {
    try {
      final uri = Uri.parse(url);
      
      // Try to launch the URL
      bool launched = false;
      
      // First, try launching with external application mode (opens in app if installed)
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        // If external app fails, try platform default
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      
      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $platformName'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening $platformName'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                title: Text(
                  'About',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                  );
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              ListTile(
                leading: Icon(
                  Icons.article_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Terms & Conditions',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TermsScreen()),
                  );
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              ListTile(
                leading: Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Refund & Cancellation',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RefundScreen()),
                  );
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              ListTile(
                leading: Icon(
                  Icons.local_shipping,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Shipping & Delivery',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShippingScreen()),
                  );
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              ListTile(
                leading: Icon(
                  Icons.format_paint,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Pricing & Product Info',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PricingScreen()),
                  );
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              ListTile(
                leading: Icon(
                  Icons.contact_support,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Contact & Support',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactScreen()),
                  );
                },
              ),
              Divider(color: AppColors.getBorderColor(isDarkMode), height: 1),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Account & Data Deletion',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccountDeletionScreen()),
                  );
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

  void _showUserReviewsDialog(BuildContext context, List<dynamic> reviews, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
        title: Text(
          'My Reviews',
          style: TextStyle(
            color: AppColors.getTextColor(isDarkMode),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.getBackgroundColor(isDarkMode),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < review.rating ? Icons.star : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                );
                              }),
                              const Spacer(),
                              Text(
                                _formatDate(review.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.getTextSecondaryColor(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.comment,
                            style: TextStyle(
                              color: AppColors.getTextColor(isDarkMode),
                              fontSize: 14,
                            ),
                          ),
                          if (review.isVerifiedPurchase) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified Purchase',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}