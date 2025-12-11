import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/order_tracking.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';
import 'order_tracking_screen.dart';
import 'home_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: Consumer2<OrderProvider, AuthProvider>(
                builder: (context, orderProvider, authProvider, child) {
                  if (authProvider.currentUser == null) {
                    return const Center(
                      child: Text('Please log in to view your orders'),
                    );
                  }

                  final allUserOrders = orderProvider
                      .getUserOrders(authProvider.currentUser!.id);
                  final filteredOrders = _getFilteredOrders(allUserOrders);

                  if (filteredOrders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          child: _buildOrderCard(order, index),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.list_alt},
      {'key': 'pending', 'label': 'Pending', 'icon': Icons.schedule},
      {'key': 'shipped', 'label': 'Shipped', 'icon': Icons.local_shipping},
      {'key': 'delivered', 'label': 'Delivered', 'icon': Icons.done_all},
      {'key': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key'] as String;
                });
              },
              avatar: Icon(
                filter['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              label: Text(
                filter['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppColors.primary,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderTrackingScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(order.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: _buildStatusChip(order.status),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Order Items Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.items.map((item) => item.productName).join(', '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tracking Info (if available)
              if (order.trackingInfo != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tracking: ${order.trackingInfo!.trackingNumber}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderTrackingScreen(
                              orderId: order.id,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.track_changes, size: 16),
                      label: const Text(
                        'Track Order',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (order.status.canBeCancelled && 
                      order.cancellationRequest == null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showQuickCancelDialog(order),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (order.status == OrderStatus.delivered)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showReorderDialog(order),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text(
                          'Reorder',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Cancellation Status (if applicable)
              if (order.cancellationRequest != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.cancellationRequest!.processedAt == null
                              ? 'Cancellation request pending'
                              : order.cancellationRequest!.isApproved
                                  ? 'Cancellation approved'
                                  : 'Cancellation denied',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_selectedFilter) {
      case 'pending':
        message = 'No pending orders';
        icon = Icons.schedule;
        break;
      case 'shipped':
        message = 'No shipped orders';
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        message = 'No delivered orders';
        icon = Icons.done_all;
        break;
      case 'cancelled':
        message = 'No cancelled orders';
        icon = Icons.cancel;
        break;
      default:
        message = 'No orders found';
        icon = Icons.shopping_bag_outlined;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          if (_selectedFilter == 'all') ...[
            const SizedBox(height: 8),
            Text(
              'Start shopping to see your orders here',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    List<Order> filtered = orders;
    
    // Apply status filter
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'pending':
          filtered = filtered.where((order) => 
              order.status == OrderStatus.pending ||
              order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.processing).toList();
          break;
        case 'shipped':
          filtered = filtered.where((order) => 
              order.status == OrderStatus.shipped ||
              order.status == OrderStatus.outForDelivery).toList();
          break;
        case 'delivered':
          filtered = filtered.where((order) => 
              order.status == OrderStatus.delivered).toList();
          break;
        case 'cancelled':
          filtered = filtered.where((order) => 
              order.status == OrderStatus.cancelled ||
              order.status == OrderStatus.returned ||
              order.status == OrderStatus.refunded).toList();
          break;
      }
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((order) =>
          order.id.toLowerCase().contains(query) ||
          order.items.any((item) => 
              item.productName.toLowerCase().contains(query))).toList();
    }
    
    return filtered;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.returned:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter order ID or product name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showQuickCancelDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel Order #${order.id.substring(0, 8)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              final orderProvider = 
                  Provider.of<OrderProvider>(context, listen: false);
              orderProvider.requestOrderCancellation(
                order.id,
                CancellationReason.changeOfMind,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cancellation request submitted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReorderDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder Items'),
        content: Text(
          'Would you like to add all items from Order #${order.id.substring(0, 8)} to your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add items to cart
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Items added to cart'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}