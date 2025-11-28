import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/personalized_feed_provider.dart';
import '../../models/feed_item.dart';

class UserPersonalizedFeedScreen extends StatefulWidget {
  const UserPersonalizedFeedScreen({super.key});

  @override
  State<UserPersonalizedFeedScreen> createState() => _UserPersonalizedFeedScreenState();
}

class _UserPersonalizedFeedScreenState extends State<UserPersonalizedFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalizedFeedProvider>().generateUserFeed();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your AI Feed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Personalized just for you',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PersonalizedFeedProvider>().generateUserFeed();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Feed',
          ),
          IconButton(
            onPressed: () {
              _showFeedPreferences();
            },
            icon: const Icon(Icons.tune),
            tooltip: 'Customize Feed',
          ),
        ],
      ),
      body: Consumer<PersonalizedFeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading) {
            return _buildLoadingState();
          }

          if (feedProvider.error != null) {
            return _buildErrorState(feedProvider.error!);
          }

          final userFeed = feedProvider.userFeed;

          if (userFeed.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => feedProvider.generateUserFeed(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: userFeed.length,
              itemBuilder: (context, index) {
                final feedItem = userFeed[index];
                return _buildFeedItemCard(feedItem, feedProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Generating Your Personalized Feed...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AI is analyzing your preferences',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load your feed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PersonalizedFeedProvider>().generateUserFeed();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your Feed is Empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to get personalized recommendations',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItemCard(FeedItem feedItem, PersonalizedFeedProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: feedItem.needsAttention
            ? Border.all(color: Color(feedItem.colorValue), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and time
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(feedItem.colorValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    feedItem.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedItem.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        feedItem.timeAgo,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (feedItem.needsAttention)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(feedItem.colorValue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'HOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Image if available
          if (feedItem.imageUrl.isNotEmpty && feedItem.imageUrl != 'https://via.placeholder.com/300x200')
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  feedItem.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              feedItem.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),

          // Additional info for specific types
          if (feedItem.data.containsKey('discount'))
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${feedItem.data['discount']}% OFF',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (feedItem.data.containsKey('price'))
                    Text(
                      '\$${feedItem.data['price']}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.trackFeedInteraction(feedItem.id, 'clicked');
                      _handleFeedItemAction(feedItem);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(feedItem.colorValue),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(feedItem.actionText),
                  ),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.favorite_border,
                  onPressed: () {
                    provider.trackFeedInteraction(feedItem.id, 'liked');
                    _showSnackbar('Added to favorites! 💖');
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.share,
                  onPressed: () {
                    provider.trackFeedInteraction(feedItem.id, 'shared');
                    _showSnackbar('Shared! 📤');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: Colors.grey[600],
      ),
    );
  }

  void _handleFeedItemAction(FeedItem feedItem) {
    switch (feedItem.type) {
      case 'product_recommendation':
      case 'trending_deal':
        if (feedItem.data.containsKey('productId')) {
          // Navigate to product detail screen
          _showSnackbar('Opening product details...');
        }
        break;
      case 'personalized_offer':
        _showSnackbar('Offer claimed! Check your coupons 🎉');
        break;
      case 'category_spotlight':
        _showSnackbar('Browsing category...');
        break;
      case 'flash_sale':
        _showSnackbar('Flash sale opened! ⚡');
        break;
      default:
        _showSnackbar('Action completed!');
    }
  }

  void _showFeedPreferences() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Customize Your Feed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Feed Preferences'),
              subtitle: const Text('Adjust what you see in your feed'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Feed preferences updated! 🎯');
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('AI Learning'),
              subtitle: const Text('Help AI understand your preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('AI learning enhanced! 🧠');
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset Recommendations'),
              subtitle: const Text('Start fresh with new suggestions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                context.read<PersonalizedFeedProvider>().generateUserFeed();
                _showSnackbar('Feed refreshed! ✨');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}