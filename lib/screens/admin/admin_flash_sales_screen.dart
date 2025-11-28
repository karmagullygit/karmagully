import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/flash_sale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/flash_sale.dart';
import 'flash_sale_form_screen.dart';

class AdminFlashSalesScreen extends StatefulWidget {
  const AdminFlashSalesScreen({super.key});

  @override
  State<AdminFlashSalesScreen> createState() => _AdminFlashSalesScreenState();
}

class _AdminFlashSalesScreenState extends State<AdminFlashSalesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FlashSaleProvider>(context, listen: false).loadFlashSales();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            title: const Text('Flash Sales'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Expired'),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
            ),
            actions: [
              IconButton(
                onPressed: () => _navigateToCreateFlashSale(),
                icon: const Icon(Icons.add),
                tooltip: 'Create Flash Sale',
              ),
              IconButton(
                onPressed: () => _refreshFlashSales(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStatsBar(isDarkMode),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFlashSalesList('active', isDarkMode),
                    _buildFlashSalesList('upcoming', isDarkMode),
                    _buildFlashSalesList('expired', isDarkMode),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToCreateFlashSale(),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.flash_on, color: Colors.white),
            label: const Text('New Flash Sale', style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Widget _buildStatsBar(bool isDarkMode) {
    return Consumer<FlashSaleProvider>(
      builder: (context, flashSaleProvider, child) {
        final stats = flashSaleProvider.getFlashSaleStats();
        
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  stats['total'],
                  Icons.flash_on,
                  Colors.white,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Active',
                  stats['active'],
                  Icons.play_arrow,
                  Colors.greenAccent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Upcoming',
                  stats['upcoming'],
                  Icons.schedule,
                  Colors.orangeAccent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Expired',
                  stats['expired'],
                  Icons.stop,
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFlashSalesList(String type, bool isDarkMode) {
    return Consumer<FlashSaleProvider>(
      builder: (context, flashSaleProvider, child) {
        if (flashSaleProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<FlashSale> flashSales;
        switch (type) {
          case 'active':
            flashSales = flashSaleProvider.activeFlashSales;
            break;
          case 'upcoming':
            flashSales = flashSaleProvider.upcomingFlashSales;
            break;
          case 'expired':
            flashSales = flashSaleProvider.expiredFlashSales;
            break;
          default:
            flashSales = [];
        }

        if (flashSales.isEmpty) {
          return _buildEmptyState(type, isDarkMode);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: flashSales.length,
          itemBuilder: (context, index) {
            final flashSale = flashSales[index];
            return _buildFlashSaleCard(flashSale, isDarkMode);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String type, bool isDarkMode) {
    String message;
    IconData icon;
    
    switch (type) {
      case 'active':
        message = 'No active flash sales';
        icon = Icons.flash_off;
        break;
      case 'upcoming':
        message = 'No upcoming flash sales';
        icon = Icons.schedule;
        break;
      case 'expired':
        message = 'No expired flash sales';
        icon = Icons.history;
        break;
      default:
        message = 'No flash sales';
        icon = Icons.flash_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.getTextColor(isDarkMode).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new flash sale to get started',
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateFlashSale(),
            icon: const Icon(Icons.add),
            label: const Text('Create Flash Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleCard(FlashSale flashSale, bool isDarkMode) {
    final Color bannerColor = flashSale.bannerColor != null 
        ? Color(int.parse(flashSale.bannerColor!.replaceFirst('#', '0xff')))
        : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.getCardBackgroundColor(isDarkMode),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image with Overlay
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                colors: [bannerColor, bannerColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      image: flashSale.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(flashSale.imageUrl),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                bannerColor.withOpacity(0.3),
                                BlendMode.overlay,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                
                // Content Overlay
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(flashSale),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(flashSale),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) => _handleMenuAction(value, flashSale),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: ListTile(
                                    leading: Icon(
                                      flashSale.isActive ? Icons.pause : Icons.play_arrow,
                                    ),
                                    title: Text(flashSale.isActive ? 'Deactivate' : 'Activate'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red),
                                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          flashSale.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${flashSale.discountPercentage}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                  flashSale.description,
                  style: TextStyle(
                    color: AppColors.getTextColor(isDarkMode).withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Timer/Status Row
                if (flashSale.isLive || flashSale.isUpcoming)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: flashSale.isLive ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: flashSale.isLive ? Colors.red : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          flashSale.isLive ? Icons.timer : Icons.schedule,
                          color: flashSale.isLive ? Colors.red : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          flashSale.isLive ? 'Ends in: ' : 'Starts in: ',
                          style: TextStyle(
                            color: flashSale.isLive ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Consumer<FlashSaleProvider>(
                          builder: (context, provider, child) {
                            return Text(
                              provider.formatCountdown(flashSale.timeRemaining),
                              style: TextStyle(
                                color: flashSale.isLive ? Colors.red : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Progress Bar (if max items set)
                if (flashSale.maxItems != null) ...[
                  Row(
                    children: [
                      Text(
                        'Items Sold: ${flashSale.soldItems}/${flashSale.maxItems}',
                        style: TextStyle(
                          color: AppColors.getTextColor(isDarkMode),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${flashSale.percentageSold.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: AppColors.getTextColor(isDarkMode),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: flashSale.percentageSold / 100,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      flashSale.percentageSold > 80 ? Colors.red : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Details Row
                Row(
                  children: [
                    if (flashSale.productIds.isNotEmpty) ...[
                      Icon(
                        Icons.inventory,
                        size: 16,
                        color: AppColors.getTextColor(isDarkMode).withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flashSale.productIds.length} products',
                        style: TextStyle(
                          color: AppColors.getTextColor(isDarkMode).withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (flashSale.categoryIds.isNotEmpty) ...[
                      Icon(
                        Icons.category,
                        size: 16,
                        color: AppColors.getTextColor(isDarkMode).withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flashSale.categoryIds.length} categories',
                        style: TextStyle(
                          color: AppColors.getTextColor(isDarkMode).withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(FlashSale flashSale) {
    if (flashSale.isLive) return 'LIVE';
    if (flashSale.isUpcoming) return 'UPCOMING';
    if (flashSale.isExpired) return 'EXPIRED';
    return 'INACTIVE';
  }

  Color _getStatusColor(FlashSale flashSale) {
    if (flashSale.isLive) return Colors.red;
    if (flashSale.isUpcoming) return Colors.orange;
    if (flashSale.isExpired) return Colors.grey;
    return Colors.grey;
  }

  void _handleMenuAction(String action, FlashSale flashSale) {
    switch (action) {
      case 'edit':
        _navigateToEditFlashSale(flashSale);
        break;
      case 'toggle':
        _toggleFlashSaleStatus(flashSale);
        break;
      case 'delete':
        _showDeleteConfirmDialog(flashSale);
        break;
    }
  }

  void _navigateToCreateFlashSale() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FlashSaleFormScreen(),
      ),
    );
  }

  void _navigateToEditFlashSale(FlashSale flashSale) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashSaleFormScreen(flashSale: flashSale),
      ),
    );
  }

  void _toggleFlashSaleStatus(FlashSale flashSale) async {
    final provider = Provider.of<FlashSaleProvider>(context, listen: false);
    final success = await provider.toggleFlashSaleStatus(flashSale.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Flash sale ${flashSale.isActive ? 'deactivated' : 'activated'}'
                : 'Failed to update flash sale status',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmDialog(FlashSale flashSale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flash Sale'),
        content: Text('Are you sure you want to delete "${flashSale.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<FlashSaleProvider>(context, listen: false);
              final success = await provider.deleteFlashSale(flashSale.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Flash sale deleted successfully'
                          : 'Failed to delete flash sale',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _refreshFlashSales() {
    Provider.of<FlashSaleProvider>(context, listen: false).loadFlashSales();
  }
}