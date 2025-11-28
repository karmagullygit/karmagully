import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coupon.dart';
import '../../providers/coupon_provider.dart';
import 'coupon_form_screen.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({Key? key}) : super(key: key);

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon Management'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.check_circle)),
            Tab(text: 'Expired', icon: Icon(Icons.access_time)),
            Tab(text: 'Draft', icon: Icon(Icons.edit)),
          ],
        ),
      ),
      body: Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          return Column(
            children: [
              // Statistics Bar
              _buildStatisticsBar(couponProvider),
              // Tab View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCouponList(couponProvider.activeCoupons),
                    _buildCouponList(couponProvider.expiredCoupons),
                    _buildCouponList(couponProvider.inactiveCoupons),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CouponFormScreen(),
            ),
          );
        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Coupon'),
      ),
    );
  }

  Widget _buildStatisticsBar(CouponProvider couponProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Coupons',
              '${couponProvider.allCoupons.length}',
              Icons.confirmation_number,
              Colors.purple,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Active',
              '${couponProvider.activeCoupons.length}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total Used',
              '${couponProvider.allCoupons.fold(0, (sum, coupon) => sum + coupon.usedCount)}',
              Icons.trending_up,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList(List<Coupon> coupons) {
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No coupons found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first coupon to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return _buildCouponCard(coupon);
      },
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: _getCouponGradientColors(coupon),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with code and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      coupon.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(coupon),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title and description
              Text(
                coupon.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                coupon.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              
              // Discount info
              Row(
                children: [
                  Icon(
                    _getCouponIcon(coupon.type),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getDiscountText(coupon),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (coupon.usageLimit != null)
                    Text(
                      '${coupon.usedCount}/${coupon.usageLimit} used',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
              
              // Usage progress bar
              if (coupon.usageLimit != null) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: coupon.usedCount / coupon.usageLimit!,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Details row
              Row(
                children: [
                  if (coupon.expiryDate != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: ${_formatDate(coupon.expiryDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) => _handleMenuAction(value, coupon),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: coupon.isActive ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(
                              coupon.isActive ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(coupon.isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Coupon coupon) {
    Color color;
    String text;
    IconData icon;

    if (!coupon.isActive) {
      color = Colors.grey;
      text = 'Draft';
      icon = Icons.edit;
    } else if (coupon.isExpired) {
      color = Colors.red;
      text = 'Expired';
      icon = Icons.access_time;
    } else if (coupon.usageLimit != null && coupon.usedCount >= coupon.usageLimit!) {
      color = Colors.orange;
      text = 'Used Up';
      icon = Icons.check_circle;
    } else {
      color = Colors.green;
      text = 'Active';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getCouponGradientColors(Coupon coupon) {
    if (coupon.bannerColor != null) {
      // Parse hex color
      final color = Color(int.parse(coupon.bannerColor!.replaceFirst('#', '0xFF')));
      return [color, color.withOpacity(0.8)];
    }

    switch (coupon.type) {
      case 'percentage':
        return [Colors.purple, Colors.purple.shade700];
      case 'fixed_amount':
        return [Colors.green, Colors.green.shade700];
      case 'free_shipping':
        return [Colors.blue, Colors.blue.shade700];
      default:
        return [Colors.grey, Colors.grey.shade700];
    }
  }

  IconData _getCouponIcon(String type) {
    switch (type) {
      case 'percentage':
        return Icons.percent;
      case 'fixed_amount':
        return Icons.attach_money;
      case 'free_shipping':
        return Icons.local_shipping;
      default:
        return Icons.confirmation_number;
    }
  }

  String _getDiscountText(Coupon coupon) {
    switch (coupon.type) {
      case 'percentage':
        return '${coupon.value.toStringAsFixed(0)}% OFF';
      case 'fixed_amount':
        return '\$${coupon.value.toStringAsFixed(2)} OFF';
      case 'free_shipping':
        return 'FREE SHIPPING';
      default:
        return 'DISCOUNT';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action, Coupon coupon) {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CouponFormScreen(coupon: coupon),
          ),
        );
        break;
      case 'activate':
      case 'deactivate':
        couponProvider.toggleCouponStatus(coupon.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              coupon.isActive 
                ? 'Coupon deactivated successfully' 
                : 'Coupon activated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'duplicate':
        _duplicateCoupon(coupon);
        break;
      case 'delete':
        _showDeleteDialog(coupon);
        break;
    }
  }

  void _duplicateCoupon(Coupon coupon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CouponFormScreen(couponToDuplicate: coupon),
      ),
    );
  }

  void _showDeleteDialog(Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text('Are you sure you want to delete the coupon "${coupon.code}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CouponProvider>(context, listen: false)
                  .deleteCoupon(coupon.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coupon deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}