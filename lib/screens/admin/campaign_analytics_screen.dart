import 'package:flutter/material.dart';
import '../../services/ads_tracking_service.dart';
import '../../constants/app_colors.dart';

class CampaignAnalyticsScreen extends StatefulWidget {
  const CampaignAnalyticsScreen({super.key});

  @override
  State<CampaignAnalyticsScreen> createState() => _CampaignAnalyticsScreenState();
}

class _CampaignAnalyticsScreenState extends State<CampaignAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? conversionData;
  List<Map<String, dynamic>>? campaignPerformance;
  List<Map<String, dynamic>>? trackingEvents;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final connectionStatus = AdsTrackingService.getConnectionStatus();
      final campaignResult = AdsTrackingService.getCampaignPerformance();
      final eventsResult = AdsTrackingService.getSampleTrackingEvents();

      // Simulate conversion data based on connection status
      Map<String, dynamic> conversionResult;
      if (connectionStatus['overall']['readyForCampaigns']) {
        conversionResult = {
          'meta': {
            'appInstalls': 245,
            'purchases': 67,
            'addToCarts': 156,
            'viewContents': 892,
            'costPerInstall': 2.45,
            'costPerPurchase': 8.97,
            'roas': 3.2,
          },
          'google': {
            'appInstalls': 189,
            'purchases': 52,
            'firstOpens': 201,
            'sessionStarts': 1205,
            'costPerInstall': 2.89,
            'costPerPurchase': 10.23,
            'ltv': 45.67,
          },
          'combined': {
            'totalInstalls': 434,
            'totalPurchases': 119,
            'averageCostPerInstall': 2.65,
            'averageCostPerPurchase': 9.45,
            'overallROAS': 3.8,
          },
        };
      } else {
        conversionResult = {
          'error': 'Tracking not configured',
          'message': 'Enter your tracking IDs to view conversion data',
        };
      }

      setState(() {
        conversionData = conversionResult;
        campaignPerformance = campaignResult;
        trackingEvents = eventsResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Campaign Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Overview'),
            Tab(icon: Icon(Icons.campaign), text: 'Campaigns'),
            Tab(icon: Icon(Icons.track_changes), text: 'Events'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadAnalyticsData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCampaignsTab(),
                _buildEventsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (conversionData?['error'] != null) {
      return _buildErrorState();
    }

    final meta = conversionData?['meta'] ?? {};
    final google = conversionData?['google'] ?? {};
    final combined = conversionData?['combined'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(combined),
          const SizedBox(height: 20),
          _buildPlatformComparison(meta, google),
          const SizedBox(height: 20),
          _buildROASChart(meta, google),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tracking Not Configured',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                conversionData?['message'] ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/admin/ads-tracking-setup'),
                icon: const Icon(Icons.settings),
                label: const Text('Setup Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> combined) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Installs',
            '${combined['totalInstalls'] ?? 0}',
            Icons.download,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Total Purchases',
            '${combined['totalPurchases'] ?? 0}',
            Icons.shopping_cart,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg CPI',
            '\$${(combined['averageCostPerInstall'] ?? 0.0).toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Overall ROAS',
            '${(combined['overallROAS'] ?? 0.0).toStringAsFixed(1)}x',
            Icons.trending_up,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildPlatformComparison(Map<String, dynamic> meta, Map<String, dynamic> google) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Platform Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPlatformCard('Meta', meta, Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPlatformCard('Google', google, Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformCard(String platform, Map<String, dynamic> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            platform,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          _buildDataRow('Installs', '${data['appInstalls'] ?? 0}'),
          _buildDataRow('Purchases', '${data['purchases'] ?? 0}'),
          _buildDataRow('Cost/Install', '\$${(data['costPerInstall'] ?? 0.0).toStringAsFixed(2)}'),
          _buildDataRow('ROAS', '${(data['roas'] ?? data['ltv'] ?? 0.0).toStringAsFixed(1)}x'),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildROASChart(Map<String, dynamic> meta, Map<String, dynamic> google) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ROAS Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: ((meta['roas'] ?? 0.0) * 10).round(),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'Meta ${(meta['roas'] ?? 0.0).toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: ((google['ltv'] ?? 0.0) * 10).round(),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'Google ${(google['ltv'] ?? 0.0).toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
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

  Widget _buildCampaignsTab() {
    if (campaignPerformance == null) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campaignPerformance!.length,
      itemBuilder: (context, index) {
        final campaign = campaignPerformance![index];
        return _buildCampaignCard(campaign);
      },
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    final platform = campaign['platform'];
    final color = platform == 'Meta' ? Colors.blue : Colors.orange;
    final status = campaign['status'];
    final isActive = status == 'Active';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    platform,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Icon(
                  isActive ? Icons.play_circle : Icons.pause_circle,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              campaign['campaignName'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCampaignMetric(
                    'Budget',
                    '\$${campaign['budget'].toStringAsFixed(0)}',
                    'Spent: \$${campaign['spent'].toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildCampaignMetric(
                    'Installs',
                    '${campaign['installs']}',
                    'CPI: \$${campaign['cpi'].toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildCampaignMetric(
                    'Purchases',
                    '${campaign['purchases']}',
                    'ROAS: ${campaign['roas'].toStringAsFixed(1)}x',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignMetric(String title, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    if (trackingEvents == null) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trackingEvents!.length,
      itemBuilder: (context, index) {
        final event = trackingEvents![index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final platform = event['platform'];
    final color = platform == 'Meta' ? Colors.blue : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            platform == 'Meta' ? Icons.facebook : Icons.analytics,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(event['event']),
        subtitle: Text(event['description']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (event['value'] > 0)
              Text(
                '\$${event['value'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            Text(
              _formatTimestamp(event['timestamp']),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}