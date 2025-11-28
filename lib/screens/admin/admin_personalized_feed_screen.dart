import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/personalized_feed_provider.dart';
import '../../models/feed_item.dart';

class AdminPersonalizedFeedScreen extends StatefulWidget {
  const AdminPersonalizedFeedScreen({super.key});

  @override
  State<AdminPersonalizedFeedScreen> createState() => _AdminPersonalizedFeedScreenState();
}

class _AdminPersonalizedFeedScreenState extends State<AdminPersonalizedFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalizedFeedProvider>().generateAdminFeed();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.dashboard_customize,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin AI Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'AI-Powered Business Insights',
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
              context.read<PersonalizedFeedProvider>().generateAdminFeed();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Insights',
          ),
          IconButton(
            onPressed: () {
              _showAnalytics();
            },
            icon: const Icon(Icons.analytics),
            tooltip: 'Analytics',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.priority_high), text: 'Critical'),
            Tab(icon: Icon(Icons.trending_up), text: 'Insights'),
            Tab(icon: Icon(Icons.security), text: 'Alerts'),
            Tab(icon: Icon(Icons.psychology), text: 'AI Tips'),
          ],
        ),
      ),
      body: Consumer<PersonalizedFeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading) {
            return _buildLoadingState();
          }

          if (feedProvider.error != null) {
            return _buildErrorState(feedProvider.error!);
          }

          final adminFeed = feedProvider.adminFeed;

          if (adminFeed.isEmpty) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCriticalTab(adminFeed),
              _buildInsightsTab(adminFeed),
              _buildAlertsTab(adminFeed),
              _buildAITipsTab(adminFeed),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickActions();
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.bolt, color: Colors.white),
        label: const Text(
          'Quick Actions',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          SizedBox(height: 16),
          Text(
            'Generating AI Insights...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Analyzing business data and trends',
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
            'Unable to load admin insights',
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
              context.read<PersonalizedFeedProvider>().generateAdminFeed();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
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
            Icons.dashboard_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Insights Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is still learning from your data',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PersonalizedFeedProvider>().generateAdminFeed();
            },
            icon: const Icon(Icons.psychology),
            label: const Text('Generate Insights'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalTab(List<FeedItem> adminFeed) {
    final criticalItems = adminFeed
        .where((item) => item.severity == 'critical' || item.severity == 'high')
        .toList();

    if (criticalItems.isEmpty) {
      return _buildTabEmptyState(
        icon: Icons.check_circle_outline,
        title: 'All Good!',
        subtitle: 'No critical issues detected',
        color: Colors.green,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<PersonalizedFeedProvider>().generateAdminFeed(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: criticalItems.length,
        itemBuilder: (context, index) {
          return _buildAdminFeedCard(criticalItems[index]);
        },
      ),
    );
  }

  Widget _buildInsightsTab(List<FeedItem> adminFeed) {
    final insightItems = adminFeed
        .where((item) => [
          'sales_insight',
          'performance_metric',
          'trend_analysis',
          'revenue_spike'
        ].contains(item.type))
        .toList();

    return RefreshIndicator(
      onRefresh: () => context.read<PersonalizedFeedProvider>().generateAdminFeed(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: insightItems.length,
        itemBuilder: (context, index) {
          return _buildAdminFeedCard(insightItems[index]);
        },
      ),
    );
  }

  Widget _buildAlertsTab(List<FeedItem> adminFeed) {
    final alertItems = adminFeed
        .where((item) => [
          'security_alert',
          'inventory_warning',
          'system_status',
          'user_behavior_alert'
        ].contains(item.type))
        .toList();

    return RefreshIndicator(
      onRefresh: () => context.read<PersonalizedFeedProvider>().generateAdminFeed(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alertItems.length,
        itemBuilder: (context, index) {
          return _buildAdminFeedCard(alertItems[index]);
        },
      ),
    );
  }

  Widget _buildAITipsTab(List<FeedItem> adminFeed) {
    final aiItems = adminFeed
        .where((item) => [
          'ai_suggestion',
          'recommendation_success',
          'marketing_opportunity',
          'seasonal_prediction'
        ].contains(item.type))
        .toList();

    return RefreshIndicator(
      onRefresh: () => context.read<PersonalizedFeedProvider>().generateAdminFeed(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: aiItems.length,
        itemBuilder: (context, index) {
          return _buildAdminFeedCard(aiItems[index]);
        },
      ),
    );
  }

  Widget _buildTabEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: color,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminFeedCard(FeedItem feedItem) {
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(feedItem.colorValue).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(feedItem.colorValue),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              feedItem.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (feedItem.value != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(feedItem.colorValue),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    feedItem.value!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (feedItem.trendArrow.isNotEmpty)
                                    Text(
                                      ' ${feedItem.trendArrow}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (feedItem.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                feedItem.category!.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            feedItem.timeAgo,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedItem.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                // AI Recommendation
                if (feedItem.data.containsKey('recommendation'))
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: const Color(0xFF6366F1),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI Recommendation',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                              Text(
                                feedItem.data['recommendation'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action buttons
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _handleAdminAction(feedItem);
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
                    OutlinedButton(
                      onPressed: () {
                        _showDetailDialog(feedItem);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(feedItem.colorValue),
                        side: BorderSide(color: Color(feedItem.colorValue)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAdminAction(FeedItem feedItem) {
    switch (feedItem.type) {
      case 'sales_insight':
        _showSnackbar('Opening sales analytics... 📊');
        break;
      case 'inventory_warning':
        _showSnackbar('Managing inventory... 📦');
        break;
      case 'security_alert':
        _showSnackbar('Reviewing security... 🔒');
        break;
      case 'user_behavior_alert':
        _showSnackbar('Analyzing user behavior... 👥');
        break;
      default:
        _showSnackbar('Action completed! ✅');
    }
  }

  void _showDetailDialog(FeedItem feedItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(feedItem.icon),
            const SizedBox(width: 8),
            Expanded(child: Text(feedItem.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(feedItem.description),
              if (feedItem.data.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Additional Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...feedItem.data.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAdminAction(feedItem);
            },
            child: Text(feedItem.actionText),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
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
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildQuickActionTile(
              icon: Icons.refresh,
              title: 'Refresh All Data',
              subtitle: 'Update insights and metrics',
              onTap: () {
                Navigator.pop(context);
                context.read<PersonalizedFeedProvider>().generateAdminFeed();
                _showSnackbar('Data refreshed! 🔄');
              },
            ),
            _buildQuickActionTile(
              icon: Icons.analytics,
              title: 'Generate Report',
              subtitle: 'Create comprehensive analytics report',
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Report generated! 📄');
              },
            ),
            _buildQuickActionTile(
              icon: Icons.settings,
              title: 'Dashboard Settings',
              subtitle: 'Customize your admin dashboard',
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Settings opened! ⚙️');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF6366F1),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feed Analytics'),
        content: Consumer<PersonalizedFeedProvider>(
          builder: (context, provider, child) {
            final analytics = provider.feedAnalytics;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Current Feed Metrics:'),
                  const SizedBox(height: 12),
                  if (analytics.isEmpty)
                    const Text('No analytics data available yet.')
                  else
                    ...analytics.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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