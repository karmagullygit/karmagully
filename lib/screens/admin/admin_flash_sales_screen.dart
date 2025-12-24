import 'dart:io';
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
          color: AppColors.getCardBackgroundColor(isDarkMode),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Active', stats['active'] ?? 0, Colors.green, isDarkMode),
              _buildStatItem('Upcoming', stats['upcoming'] ?? 0, Colors.orange, isDarkMode),
              _buildStatItem('Expired', stats['expired'] ?? 0, Colors.red, isDarkMode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, Color color, bool isDarkMode) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.getTextColor(isDarkMode),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFlashSalesList(String status, bool isDarkMode) {
    return Consumer<FlashSaleProvider>(
      builder: (context, flashSaleProvider, child) {
        final flashSales = flashSaleProvider.getFlashSalesByStatus(status);

        if (flashSales.isEmpty) {
          return _buildEmptyState(status, isDarkMode);
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

  Widget _buildEmptyState(String status, bool isDarkMode) {
    String message;
    IconData icon;

    switch (status) {
      case 'active':
        message = 'No active flash sales';
        icon = Icons.flash_on;
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
        icon = Icons.flash_on;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.getTextColor(isDarkMode).withValues(alpha: 0.5),
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
              color: AppColors.getTextColor(isDarkMode).withValues(alpha: 0.7),
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
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: flashSale.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: flashSale.imageUrl.startsWith('file://')
                          ? FileImage(File(flashSale.imageUrl.replaceFirst('file://', '')))
                          : NetworkImage(flashSale.imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
              color: bannerColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const Spacer(),
                    _buildTimer(flashSale),
                  ],
                ),
              ),
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
                    color: AppColors.getTextColor(isDarkMode),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.getTextColor(isDarkMode).withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${flashSale.startTime.toString().split(' ')[0]} - ${flashSale.endTime.toString().split(' ')[0]}',
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode).withValues(alpha: 0.7),
                        fontSize: 12,
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
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
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

  Widget _buildTimer(FlashSale flashSale) {
    final now = DateTime.now();
    Duration remaining;

    if (flashSale.isExpired) {
      return const Text(
        'Expired',
        style: TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (flashSale.isUpcoming) {
      remaining = flashSale.startTime.difference(now);
      return Text(
        'Starts in: ${_formatDuration(remaining)}',
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      remaining = flashSale.endTime.difference(now);
      return Text(
        'Ends in: ${_formatDuration(remaining)}',
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
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

  void _toggleFlashSaleStatus(FlashSale flashSale) async {
    final provider = Provider.of<FlashSaleProvider>(context, listen: false);
    final success = await provider.toggleFlashSaleStatus(flashSale.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flash sale ${flashSale.isActive ? 'deactivated' : 'activated'}'),
          backgroundColor: Colors.green,
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final provider = Provider.of<FlashSaleProvider>(context, listen: false);
              final success = await provider.deleteFlashSale(flashSale.id);
              if (success && mounted) {
                // Use a post-frame callback to safely show the SnackBar
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Flash sale deleted'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _refreshFlashSales() {
    Provider.of<FlashSaleProvider>(context, listen: false).loadFlashSales();
  }
}