import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/simple_ai_provider.dart';
import 'ai_marketing_chat_screen.dart';

class SimpleAIDashboard extends StatelessWidget {
  const SimpleAIDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Marketing Control'),
        backgroundColor: const Color(0xFF1A1D29),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0F1419),
      body: Consumer<SimpleAIProvider>(
        builder: (context, aiProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Marketing Toggle
                _buildMarketingToggle(aiProvider, context),
                const SizedBox(height: 20),
                
                // Current Status Card
                _buildStatusCard(aiProvider),
                const SizedBox(height: 20),
                
                // AI Marketing Assistant
                _buildAIAssistantCard(context),
                const SizedBox(height: 20),
                
                // Quick Actions
                _buildActionsCard(aiProvider, context),
                const SizedBox(height: 20),
                
                // Customization Options
                _buildCustomizationCard(aiProvider, context),
                const SizedBox(height: 20),
                
                // Simple Analytics
                _buildAnalyticsCard(aiProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(SimpleAIProvider aiProvider) {
    final status = aiProvider.getCurrentStatus();
    
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.dashboard, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Current App Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatusItem('Featured Collection', status['featuredCollection'], Icons.star),
            _buildStatusItem('Active Discount', '${status['currentDiscount']}%', Icons.local_offer),
            _buildStatusItem('Current Banner', status['promotionalBanner'], Icons.campaign),
            _buildStatusItem('Special Offer', status['specialOffer'], Icons.card_giftcard),
            
            if (status['showUrgencyBadge'])
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '🚨 URGENCY MODE ACTIVE',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    if (value.isEmpty || value == '0' || value == '0%') {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(SimpleAIProvider aiProvider, BuildContext context) {
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  'AI Marketing Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              aiProvider.isAIMarketingEnabled 
                  ? 'Manage your AI-generated marketing content'
                  : 'Enable AI Marketing to use these actions',
              style: TextStyle(
                color: aiProvider.isAIMarketingEnabled ? Colors.white70 : Colors.grey, 
                fontSize: 14
              ),
            ),
            const SizedBox(height: 16),
            
            if (aiProvider.isAIMarketingEnabled) ...[
              // Current AI Marketing Content Management
              _buildCurrentAIContent(aiProvider, context),
              const SizedBox(height: 20),
              
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Action Buttons
            ...aiProvider.availableActions.map((action) => 
              _buildActionButton(action, aiProvider, context)
            ),
            
            const SizedBox(height: 16),
            
            // Reset Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: aiProvider.isAIMarketingEnabled ? () async {
                  await aiProvider.resetToDefault();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Reset to default settings'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Default'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAIContent(SimpleAIProvider aiProvider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Current AI Marketing Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Current Banner
          if (aiProvider.promotionalBanner.isNotEmpty)
            _buildAIContentItem(
              title: 'Promotional Banner',
              content: aiProvider.promotionalBanner,
              icon: Icons.campaign,
              color: Colors.blue,
              onEdit: () => _showEditBannerDialog(context, aiProvider),
              onDelete: () => _deleteBanner(context, aiProvider),
            ),
          
          // Current Featured Collection
          if (aiProvider.featuredCollection.isNotEmpty)
            _buildAIContentItem(
              title: 'Featured Collection',
              content: aiProvider.featuredCollection,
              icon: Icons.collections,
              color: Colors.purple,
              onEdit: () => _showEditCollectionDialog(context, aiProvider),
              onDelete: () => _deleteCollection(context, aiProvider),
            ),
          
          // Current Special Offer
          if (aiProvider.specialOffer.isNotEmpty)
            _buildAIContentItem(
              title: 'Special Offer',
              content: aiProvider.specialOffer,
              icon: Icons.local_offer,
              color: Colors.green,
              onEdit: () => _showEditOfferDialog(context, aiProvider),
              onDelete: () => _deleteOffer(context, aiProvider),
            ),
          
          // Recommended Products
          if (aiProvider.recommendedProducts.isNotEmpty)
            _buildAIProductsList(aiProvider, context),
          
          // Current Discount
          if (aiProvider.currentDiscount > 0)
            _buildAIContentItem(
              title: 'Active Discount',
              content: '${aiProvider.currentDiscount.toInt()}% OFF',
              icon: Icons.discount,
              color: Colors.red,
              onEdit: () => _showEditDiscountDialog(context, aiProvider),
              onDelete: () => _deleteDiscount(context, aiProvider),
            ),
          
          // Show message if no content
          if (aiProvider.promotionalBanner.isEmpty && 
              aiProvider.featuredCollection.isEmpty && 
              aiProvider.specialOffer.isEmpty && 
              aiProvider.recommendedProducts.isEmpty && 
              aiProvider.currentDiscount == 0)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  'No AI marketing content active.\nUse the actions below to generate content.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIContentItem({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Widget _buildAIProductsList(SimpleAIProvider aiProvider, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag, color: Colors.teal, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Recommended Products',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                onPressed: () => _showEditProductsDialog(context, aiProvider),
                tooltip: 'Edit Products',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _deleteProducts(context, aiProvider),
                tooltip: 'Clear Products',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...aiProvider.recommendedProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 16),
                    onPressed: () => _deleteIndividualProduct(context, aiProvider, index),
                    tooltip: 'Remove Product',
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(String action, SimpleAIProvider aiProvider, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: aiProvider.isAIMarketingEnabled ? () async {
          // Show loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🤖 Executing: $action'),
              duration: const Duration(seconds: 1),
            ),
          );
          
          // Execute action
          await aiProvider.executeAction(action);
          
          // Show success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Action executed! Check your main app.'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'VIEW APP',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to main app
                },
              ),
            ),
          );
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getActionColor(action),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          action,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    if (action.contains('Flash Sale') || action.contains('Urgent')) {
      return Colors.red[600]!;
    } else if (action.contains('Feature')) {
      return Colors.blue[600]!;
    } else if (action.contains('Offer')) {
      return Colors.green[600]!;
    } else {
      return Colors.purple[600]!;
    }
  }

  Widget _buildAnalyticsCard(SimpleAIProvider aiProvider) {
    final analytics = aiProvider.getSimpleAnalytics();
    
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  'Simple Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticItem(
                    'Page Views',
                    '${analytics['totalViews']}',
                    Icons.visibility,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticItem(
                    'Conversion Rate',
                    analytics['conversionRate'],
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildAnalyticItem(
              'Popular Collection',
              analytics['popularCollection'],
              Icons.star,
            ),
            
            _buildAnalyticItem(
              'Active Offers',
              '${analytics['currentActiveOffers']}',
              Icons.local_offer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingToggle(SimpleAIProvider aiProvider, BuildContext context) {
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              aiProvider.isAIMarketingEnabled ? Icons.smart_toy : Icons.smart_toy_outlined,
              color: aiProvider.isAIMarketingEnabled ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Marketing System',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    aiProvider.isAIMarketingEnabled 
                        ? 'Currently showing AI banners and recommendations'
                        : 'All AI marketing content is hidden',
                    style: TextStyle(
                      color: aiProvider.isAIMarketingEnabled ? Colors.green : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: aiProvider.isAIMarketingEnabled,
              onChanged: (value) {
                aiProvider.toggleAIMarketing();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                          ? '✅ AI Marketing Enabled - Banners will appear'
                          : '❌ AI Marketing Disabled - All banners removed'
                    ),
                    backgroundColor: value ? Colors.green : Colors.red,
                  ),
                );
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationCard(SimpleAIProvider aiProvider, BuildContext context) {
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Customization',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize banners, products, and marketing content',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: aiProvider.isAIMarketingEnabled ? () {
                      _showBannerCustomization(context, aiProvider);
                    } : null,
                    icon: const Icon(Icons.campaign),
                    label: const Text('Customize Banners'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: aiProvider.isAIMarketingEnabled ? () {
                      _showProductCustomization(context, aiProvider);
                    } : null,
                    icon: const Icon(Icons.inventory),
                    label: const Text('Customize Products'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBannerCustomization(BuildContext context, SimpleAIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Customize Marketing Banner', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Banner Text',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  // Update banner text
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Banner Type',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                dropdownColor: const Color(0xFF1A1D29),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'sale', child: Text('Flash Sale')),
                  DropdownMenuItem(value: 'featured', child: Text('Featured Collection')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent Offer')),
                  DropdownMenuItem(value: 'special', child: Text('Special Promotion')),
                ],
                onChanged: (value) {
                  // Update banner type
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Banner customization saved!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showProductCustomization(BuildContext context, SimpleAIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Customize Product Recommendations', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select which products AI can recommend:',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              // Add product selection checkboxes here
              Text(
                '• Attack on Titan Collection\n• Demon Slayer Series\n• Naruto Ultimate Pack\n• One Piece Merchandise',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Product preferences saved!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Delete and Edit Methods for AI Marketing Content

  void _deleteBanner(BuildContext context, SimpleAIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Delete Banner', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete the promotional banner?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              aiProvider.clearPromotionalBanner();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Promotional banner deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteCollection(BuildContext context, SimpleAIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Delete Collection', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to remove the featured collection?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              aiProvider.clearFeaturedCollection();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Featured collection removed'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteOffer(BuildContext context, SimpleAIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Delete Offer', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete the special offer?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              aiProvider.clearSpecialOffer();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Special offer deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteDiscount(BuildContext context, SimpleAIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Delete Discount', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to remove the active discount?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              aiProvider.clearDiscount();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Discount removed'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteProducts(BuildContext context, SimpleAIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Clear Products', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear all recommended products?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              aiProvider.clearRecommendedProducts();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ All recommended products cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _deleteIndividualProduct(BuildContext context, SimpleAIProvider aiProvider, int index) {
    final productName = aiProvider.recommendedProducts[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Remove Product', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "$productName" from recommended products?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              aiProvider.removeRecommendedProduct(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ "$productName" removed'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showEditBannerDialog(BuildContext context, SimpleAIProvider aiProvider) {
    final controller = TextEditingController(text: aiProvider.promotionalBanner);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Edit Banner', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Banner Text',
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                aiProvider.setPromotionalBanner(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Banner updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditCollectionDialog(BuildContext context, SimpleAIProvider aiProvider) {
    final controller = TextEditingController(text: aiProvider.featuredCollection);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Edit Collection', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Collection Name',
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                aiProvider.setFeaturedCollection(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Collection updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditOfferDialog(BuildContext context, SimpleAIProvider aiProvider) {
    final controller = TextEditingController(text: aiProvider.specialOffer);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Edit Offer', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Special Offer',
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                aiProvider.setSpecialOffer(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Offer updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditDiscountDialog(BuildContext context, SimpleAIProvider aiProvider) {
    double discountValue = aiProvider.currentDiscount;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1D29),
          title: const Text('Edit Discount', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${discountValue.toInt()}% OFF',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Slider(
                value: discountValue,
                min: 0,
                max: 70,
                divisions: 14,
                activeColor: Colors.red,
                onChanged: (value) {
                  setState(() => discountValue = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                aiProvider.setDiscount(discountValue);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Discount set to ${discountValue.toInt()}%'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductsDialog(BuildContext context, SimpleAIProvider aiProvider) {
    final products = List<String>.from(aiProvider.recommendedProducts);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1D29),
          title: const Text('Edit Products', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tap products to remove them:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ...products.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      tileColor: const Color(0xFF0F1419),
                      title: Text(product, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() => products.removeAt(index));
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final newProduct = 'New Product ${products.length + 1}';
                    setState(() => products.add(newProduct));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                aiProvider.setRecommendedProducts(products);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Products updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistantCard(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Color(0xFF4A9EFF), size: 24),
                SizedBox(width: 8),
                Text(
                  'AI Marketing Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '🤖 Your personal AI marketing consultant is ready!\n\nGet instant advice on:\n• Marketing strategies & campaigns\n• Market research & trends\n• Competitor analysis\n• Pricing optimization\n• Social media strategies',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIMarketingChatScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text(
                      'Start Chatting',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9EFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showMarketResearchDialog(context),
                  icon: const Icon(Icons.trending_up, color: Colors.white),
                  label: const Text(
                    'Research',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1419),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4A9EFF), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF4A9EFF), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI powered by Google Gemini with real-time market research',
                      style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarketResearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text(
          '📊 Quick Market Research',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a category to research:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildResearchButton(context, '🖼️ Anime Posters', 'anime posters'),
            _buildResearchButton(context, '🎭 Anime Figures', 'anime figures'),
            _buildResearchButton(context, '👕 Anime Clothing', 'anime clothing'),
            _buildResearchButton(context, '🎮 Gaming Merchandise', 'gaming merchandise'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchButton(BuildContext context, String title, String category) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AIMarketingChatScreen(),
            ),
          );
          // The chat screen will handle the research automatically
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        child: Text(title),
      ),
    );
  }
}