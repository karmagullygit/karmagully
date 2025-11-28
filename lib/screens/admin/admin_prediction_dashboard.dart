import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prediction_provider.dart';
import '../../models/prediction_models.dart';
import '../../widgets/prediction_widgets.dart';

class AdminPredictionDashboard extends StatefulWidget {
  const AdminPredictionDashboard({Key? key}) : super(key: key);

  @override
  State<AdminPredictionDashboard> createState() => _AdminPredictionDashboardState();
}

class _AdminPredictionDashboardState extends State<AdminPredictionDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load predictions when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPredictions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPredictions() async {
    final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
    
    // Use the new method that works with real data
    await predictionProvider.generatePredictionsFromRealData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Prediction Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Overview'),
            Tab(icon: Icon(Icons.inventory), text: 'Stock'),
            Tab(icon: Icon(Icons.trending_up), text: 'Demand'),
            Tab(icon: Icon(Icons.report), text: 'Reports'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPredictions,
            tooltip: 'Refresh Predictions',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, predictionProvider, child) {
          if (predictionProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating AI Predictions...'),
                ],
              ),
            );
          }

          if (predictionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${predictionProvider.error}',
                    style: TextStyle(color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPredictions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(predictionProvider),
              _buildStockTab(predictionProvider),
              _buildDemandTab(predictionProvider),
              _buildReportsTab(predictionProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPredictionSettings,
        icon: const Icon(Icons.tune),
        label: const Text('Tune AI'),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildOverviewTab(PredictionProvider provider) {
    final analytics = provider.analytics;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Products',
                  '${analytics?.totalProducts ?? 0}',
                  Icons.inventory_2,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Low Stock Alerts',
                  '${analytics?.lowStockAlerts ?? 0}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Overstock Items',
                  '${analytics?.overStockAlerts ?? 0}',
                  Icons.trending_down,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'AI Accuracy',
                  '${((analytics?.averageAccuracy ?? 0) * 100).toStringAsFixed(1)}%',
                  Icons.psychology,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Critical Alerts
          if (provider.criticalStockAlerts.isNotEmpty) ...[
            const Text(
              'Critical Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...provider.criticalStockAlerts.take(5).map(
              (alert) => CriticalAlertCard(prediction: alert),
            ),
            const SizedBox(height: 24),
          ],
          
          // Top Selling Predictions
          const Text(
            'Top Selling Predictions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (analytics?.topSellingPredictions.isNotEmpty == true)
            ...analytics!.topSellingPredictions.take(5).map(
              (prediction) => TopSellingCard(prediction: prediction),
            )
          else
            const Text('No predictions available'),
        ],
      ),
    );
  }

  Widget _buildStockTab(PredictionProvider provider) {
    return Column(
      children: [
        // Filter and Sort Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Status')),
                  DropdownMenuItem(value: 'critical', child: Text('Critical Low')),
                  DropdownMenuItem(value: 'low', child: Text('Low Stock')),
                  DropdownMenuItem(value: 'overstock', child: Text('Overstock')),
                ],
                onChanged: (value) {
                  // Implement filtering
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () {
                  provider.sortStockPredictionsByStatus();
                },
                tooltip: 'Sort by Priority',
              ),
            ],
          ),
        ),
        
        // Stock Predictions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.stockPredictions.length,
            itemBuilder: (context, index) {
              final prediction = provider.stockPredictions[index];
              return StockPredictionCard(
                prediction: prediction,
                onTap: () => _showPredictionDetails(prediction),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDemandTab(PredictionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demand Forecasts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          ...provider.demandPredictions.map(
            (prediction) => DemandPredictionCard(
              prediction: prediction,
              onTap: () => _showDemandDetails(prediction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(PredictionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports & Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Report Generation Cards
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Weekly Report'),
              subtitle: const Text('Generate weekly stock and demand analysis'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _generateWeeklyReport(provider),
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.green),
              title: const Text('Monthly Report'),
              subtitle: const Text('Comprehensive monthly business insights'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _generateMonthlyReport(provider),
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.analytics, color: Colors.purple),
              title: const Text('Custom Analytics'),
              subtitle: const Text('Create custom prediction reports'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _showCustomAnalytics(provider),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          const Text(
            'Quick Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          _buildStatsGrid(provider),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(PredictionProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Products Analyzed', '${provider.totalProductsAnalyzed}'),
        _buildStatCard('Avg Confidence', '${(provider.averageConfidenceLevel * 100).toStringAsFixed(1)}%'),
        _buildStatCard('Total Demand', '${provider.totalPredictedDemand}'),
        _buildStatCard('Categories', '${provider.analytics?.categoryDemand.keys.length ?? 0}'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    final provider = Provider.of<PredictionProvider>(context, listen: false);
    
    switch (action) {
      case 'export':
        _exportPredictions(provider);
        break;
      case 'settings':
        _showPredictionSettings();
        break;
    }
  }

  void _exportPredictions(PredictionProvider provider) {
    // final data = provider.exportPredictionsToJson();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Predictions'),
        content: const Text('Prediction data has been prepared for export.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement actual export functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showPredictionSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Prediction Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.tune),
              title: Text('Prediction Accuracy'),
              subtitle: Text('Adjust AI model parameters'),
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Update Frequency'),
              subtitle: Text('How often to refresh predictions'),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Alert Thresholds'),
              subtitle: Text('Configure stock alert levels'),
            ),
          ],
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

  void _showPredictionDetails(StockPrediction prediction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictionDetailsScreen(prediction: prediction),
      ),
    );
  }

  void _showDemandDetails(DemandPrediction prediction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DemandDetailsScreen(prediction: prediction),
      ),
    );
  }

  void _generateWeeklyReport(PredictionProvider provider) {
    final report = provider.generateWeeklyReport();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Report Generated'),
        content: SingleChildScrollView(
          child: Text(
            'Report Period: ${report['period']['start']} to ${report['period']['end']}\n\n'
            'Summary:\n'
            '• Total Products: ${report['summary']['totalProducts']}\n'
            '• Low Stock Alerts: ${report['summary']['lowStockAlerts']}\n'
            '• Overstock Alerts: ${report['summary']['overStockAlerts']}\n'
            '• Average Confidence: ${(report['summary']['averageConfidence'] * 100).toStringAsFixed(1)}%',
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
              // Implement save/share functionality
            },
            child: const Text('Save Report'),
          ),
        ],
      ),
    );
  }

  void _generateMonthlyReport(PredictionProvider provider) {
    final report = provider.generateMonthlyReport();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyReportScreen(reportData: report),
      ),
    );
  }

  void _showCustomAnalytics(PredictionProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomAnalyticsScreen(provider: provider),
      ),
    );
  }
}

// Placeholder screens - you can implement these separately
class PredictionDetailsScreen extends StatelessWidget {
  final StockPrediction prediction;
  
  const PredictionDetailsScreen({Key? key, required this.prediction}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(prediction.productName)),
      body: const Center(child: Text('Prediction Details Screen')),
    );
  }
}

class DemandDetailsScreen extends StatelessWidget {
  final DemandPrediction prediction;
  
  const DemandDetailsScreen({Key? key, required this.prediction}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(prediction.productName)),
      body: const Center(child: Text('Demand Details Screen')),
    );
  }
}

class MonthlyReportScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;
  
  const MonthlyReportScreen({Key? key, required this.reportData}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: const Center(child: Text('Monthly Report Screen')),
    );
  }
}

class CustomAnalyticsScreen extends StatelessWidget {
  final PredictionProvider provider;
  
  const CustomAnalyticsScreen({Key? key, required this.provider}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Analytics')),
      body: const Center(child: Text('Custom Analytics Screen')),
    );
  }
}