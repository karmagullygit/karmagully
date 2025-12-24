import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/social_feed_provider.dart';
import '../../services/product_bot_service.dart';

class AdminBotSettingsScreen extends StatefulWidget {
  const AdminBotSettingsScreen({super.key});

  @override
  State<AdminBotSettingsScreen> createState() => _AdminBotSettingsScreenState();
}

class _AdminBotSettingsScreenState extends State<AdminBotSettingsScreen> {
  bool _isAutoPostEnabled = true;
  int _postDelay = 5; // seconds
  bool _generateCollages = true;
  bool _addHashtags = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 KarmaBot Settings'),
        backgroundColor: const Color(0xFF6B73FF),
      ),
      body: Consumer2<ProductProvider, SocialFeedProvider>(
        builder: (context, productProvider, socialProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status Card
              Card(
                color: _isAutoPostEnabled ? Colors.green.shade50 : Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _isAutoPostEnabled ? Icons.check_circle : Icons.cancel,
                        color: _isAutoPostEnabled ? Colors.green : Colors.grey,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isAutoPostEnabled ? '🤖 KarmaBot Active' : '🤖 KarmaBot Inactive',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isAutoPostEnabled
                                  ? 'KarmaBot is automatically posting new products'
                                  : 'KarmaBot auto-posting is disabled',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings
              const Text(
                'Bot Configuration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Auto-post Toggle
              SwitchListTile(
                title: const Text('Auto-Post Products'),
                subtitle: const Text('Automatically post new products to feed'),
                value: _isAutoPostEnabled,
                activeColor: const Color(0xFF6B73FF),
                onChanged: (value) {
                  setState(() => _isAutoPostEnabled = value);
                },
              ),

              // Post Delay
              ListTile(
                title: const Text('Post Delay'),
                subtitle: Text('Wait $_postDelay seconds after product upload'),
                trailing: DropdownButton<int>(
                  value: _postDelay,
                  items: [1, 3, 5, 10, 30, 60].map((seconds) {
                    return DropdownMenuItem(
                      value: seconds,
                      child: Text('$seconds sec'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _postDelay = value);
                    }
                  },
                ),
              ),

              // Generate Collages
              SwitchListTile(
                title: const Text('Generate Collages'),
                subtitle: const Text('Create multi-product collage posts'),
                value: _generateCollages,
                activeColor: const Color(0xFF6B73FF),
                onChanged: (value) {
                  setState(() => _generateCollages = value);
                },
              ),

              // Add Hashtags
              SwitchListTile(
                title: const Text('Add Hashtags'),
                subtitle: const Text('Include relevant hashtags in posts'),
                value: _addHashtags,
                activeColor: const Color(0xFF6B73FF),
                onChanged: (value) {
                  setState(() => _addHashtags = value);
                },
              ),

              const SizedBox(height: 24),

              // Manual Actions
              const Text(
                'Manual Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Create Collage Button
              ElevatedButton.icon(
                onPressed: () => _createCollagePost(context, productProvider, socialProvider),
                icon: const Icon(Icons.collections),
                label: const Text('Create Collage Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B73FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),

              // Create Promotion Button
              ElevatedButton.icon(
                onPressed: () => _createPromotionalPost(context, productProvider, socialProvider),
                icon: const Icon(Icons.campaign),
                label: const Text('Create Promotional Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 24),

              // Bot Statistics
              const Text(
                'Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatRow('Total Products', '${productProvider.products.length}'),
                      const Divider(),
                      _buildStatRow('Total Posts', '${socialProvider.posts.length}'),
                      const Divider(),
                      _buildStatRow('Bot Posts', _countBotPosts(socialProvider)),
                      const Divider(),
                      _buildStatRow('Today\'s Posts', _countTodayPosts(socialProvider)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bot Info
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'About Product Bot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Automatically posts products to customer feed\n'
                        '• Generates AI-powered captions\n'
                        '• Adds relevant hashtags\n'
                        '• Creates engaging collages\n'
                        '• Posts after customizable delay',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B73FF),
          ),
        ),
      ],
    );
  }

  String _countBotPosts(SocialFeedProvider provider) {
    final botPosts = provider.posts.where((post) => 
      post.userId == ProductBotService.botUserId
    ).length;
    return '$botPosts';
  }

  String _countTodayPosts(SocialFeedProvider provider) {
    final today = DateTime.now();
    final todayPosts = provider.posts.where((post) {
      final postDate = post.createdAt;
      return postDate.year == today.year &&
             postDate.month == today.month &&
             postDate.day == today.day;
    }).length;
    return '$todayPosts';
  }

  void _createCollagePost(BuildContext context, ProductProvider productProvider, 
                          SocialFeedProvider socialProvider) async {
    final products = productProvider.products.take(4).toList();
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products available to create collage')),
      );
      return;
    }

    final botService = ProductBotService(socialProvider, productProvider);
    await botService.createCollagePost(products);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Collage post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _createPromotionalPost(BuildContext context, ProductProvider productProvider,
                               SocialFeedProvider socialProvider) async {
    final products = productProvider.products.where((p) => p.isActive).toList();
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active products available')),
      );
      return;
    }

    final botService = ProductBotService(socialProvider, productProvider);
    await botService.createPromotionalPost(
      '🎉 MEGA SALE! Up to 50% OFF on selected items! 🎉',
      products.take(1).toList(),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Promotional post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
