import 'package:flutter/material.dart';
import '../models/prediction_models.dart';

class CriticalAlertCard extends StatelessWidget {
  final StockPrediction prediction;

  const CriticalAlertCard({Key? key, required this.prediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.red[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: const Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(
          prediction.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Stock: ${prediction.currentStock}'),
            Text('Predicted Demand: ${prediction.predictedDemand}'),
            Text('Status: ${prediction.status.displayName}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'URGENT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class TopSellingCard extends StatelessWidget {
  final TopSellingPrediction prediction;

  const TopSellingCard({Key? key, required this.prediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: const Icon(Icons.trending_up, color: Colors.white),
        ),
        title: Text(
          prediction.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Predicted Sales: ${prediction.predictedSales.toStringAsFixed(1)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${prediction.revenueImpact.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Text(
              'Revenue',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class StockPredictionCard extends StatelessWidget {
  final StockPrediction prediction;
  final VoidCallback? onTap;

  const StockPredictionCard({
    Key? key,
    required this.prediction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(prediction.status);
    IconData statusIcon = _getStatusIcon(prediction.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prediction.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          prediction.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'Current Stock',
                      '${prediction.currentStock}',
                      Icons.inventory,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Predicted Demand',
                      '${prediction.predictedDemand}',
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Recommended',
                      '${prediction.recommendedStock}',
                      Icons.recommend,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.psychology, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Confidence: ${(prediction.confidenceLevel * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Updated: ${_formatDate(prediction.predictionDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (prediction.trends.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildTrendIndicator(prediction.trends.last.direction),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(TrendDirection direction) {
    Color trendColor;
    IconData trendIcon;
    String trendText;

    switch (direction) {
      case TrendDirection.increasing:
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        trendText = 'Increasing Trend';
        break;
      case TrendDirection.decreasing:
        trendColor = Colors.red;
        trendIcon = Icons.trending_down;
        trendText = 'Decreasing Trend';
        break;
      case TrendDirection.stable:
        trendColor = Colors.blue;
        trendIcon = Icons.trending_flat;
        trendText = 'Stable Trend';
        break;
      case TrendDirection.volatile:
        trendColor = Colors.orange;
        trendIcon = Icons.show_chart;
        trendText = 'Volatile Trend';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, size: 16, color: trendColor),
          const SizedBox(width: 4),
          Text(
            trendText,
            style: TextStyle(
              fontSize: 12,
              color: trendColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.criticalLow:
        return Colors.red;
      case StockStatus.low:
        return Colors.orange;
      case StockStatus.normal:
        return Colors.green;
      case StockStatus.high:
        return Colors.blue;
      case StockStatus.overStock:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(StockStatus status) {
    switch (status) {
      case StockStatus.criticalLow:
        return Icons.error;
      case StockStatus.low:
        return Icons.warning;
      case StockStatus.normal:
        return Icons.check_circle;
      case StockStatus.high:
        return Icons.info;
      case StockStatus.overStock:
        return Icons.trending_down;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class DemandPredictionCard extends StatelessWidget {
  final DemandPrediction prediction;
  final VoidCallback? onTap;

  const DemandPredictionCard({
    Key? key,
    required this.prediction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prediction.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prediction.categoryId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDemandMetric(
                      'Daily Avg',
                      prediction.averageDailyDemand.toStringAsFixed(1),
                      Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _buildDemandMetric(
                      'Peak Factor',
                      '${prediction.peakDemandFactor.toStringAsFixed(1)}x',
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildDemandMetric(
                      'Forecasts',
                      '${prediction.weeklyForecast.length}w',
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
              if (prediction.seasonalPatterns.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Seasonal Patterns',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: prediction.seasonalPatterns.map((pattern) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSeasonColor(pattern.season).withOpacity(0.1),
                        border: Border.all(color: _getSeasonColor(pattern.season)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${pattern.season} (${pattern.demandMultiplier.toStringAsFixed(1)}x)',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSeasonColor(pattern.season),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Updated: ${_formatDate(prediction.lastUpdated)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemandMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getSeasonColor(String season) {
    switch (season.toLowerCase()) {
      case 'holiday season':
        return Colors.red;
      case 'summer':
        return Colors.orange;
      case 'back to school':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class PredictionChart extends StatelessWidget {
  final List<StockTrend> trends;
  final String title;

  const PredictionChart({
    Key? key,
    required this.trends,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: trends.isNotEmpty
                  ? _buildChart()
                  : const Center(
                      child: Text('No trend data available'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    // This is a simplified chart representation
    // In a real app, you'd use a charting library like fl_chart
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Chart visualization\nwould appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Use fl_chart or similar package\nfor actual implementation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const QuickActionButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class LoadingPredictionCard extends StatelessWidget {
  const LoadingPredictionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
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
}