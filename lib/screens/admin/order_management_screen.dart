import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../models/order_tracking.dart';
import '../../models/payment_method.dart';
import '../../providers/order_provider.dart';
import '../../utils/navigation_helper.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  OrderStatus? _selectedStatus;
  bool _showOnlyCancellationRequests = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<OrderProvider>(context, listen: false).loadOrders();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search orders by ID or address...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Status Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('All', null),
                      const SizedBox(width: 8),
                      _buildCancellationRequestChip(),
                      const SizedBox(width: 8),
                      ...OrderStatus.values.map((status) =>
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildStatusChip(_getStatusText(status), status),
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                List<Order> orders = _getFilteredOrders(orderProvider);

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedStatus != null
                              ? 'No orders found matching your criteria'
                              : 'No orders yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(order, orderProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, OrderStatus? status) {
    final isSelected = _selectedStatus == status && !_showOnlyCancellationRequests;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
          _showOnlyCancellationRequests = false;
        });
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildCancellationRequestChip() {
    final isSelected = _showOnlyCancellationRequests;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning,
            size: 16,
            color: isSelected ? Colors.red : Colors.red[300],
          ),
          const SizedBox(width: 4),
          const Text('Pending Cancellations'),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _showOnlyCancellationRequests = selected;
          _selectedStatus = null;
        });
      },
      selectedColor: Colors.red.withOpacity(0.1),
      checkmarkColor: Colors.red,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.red : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildOrderCard(Order order, OrderProvider orderProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy - HH:mm').format(order.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 12),
            // Order Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${order.userId}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Items: ${order.items.length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (order.paymentInfo != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getPaymentMethodIcon(order.paymentInfo!.method),
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.paymentInfo!.method.displayName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPaymentStatusColor(order.paymentInfo!.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.paymentInfo!.status.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _showOrderDetails(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('View Details'),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusUpdateButton(order, orderProvider),
                  ],
                ),
              ],
            ),
            // Cancellation Request Alert (if exists)
            if (order.cancellationRequest != null) ...[
              const SizedBox(height: 12),
              _buildCancellationRequestAlert(order, orderProvider),
            ],
            // Shipping Address
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.shippingAddress,
                      style: const TextStyle(fontSize: 14),
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

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        break;
      case OrderStatus.processing:
        color = Colors.indigo;
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        break;
      case OrderStatus.outForDelivery:
        color = Colors.teal;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
      case OrderStatus.returned:
        color = Colors.brown;
        break;
      case OrderStatus.refunded:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusUpdateButton(Order order, OrderProvider orderProvider) {
    if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return OutlinedButton(
      onPressed: () => _showStatusUpdateDialog(order, orderProvider),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: const Text(
        'Update Status',
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    // Navigate to order detail screen
    NavigationHelper.navigateToOrderDetail(context, order.id);
  }

  void _showStatusUpdateDialog(Order order, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
            const SizedBox(height: 16),
            ...OrderStatus.values.where((status) => 
              status != order.status && 
              status != OrderStatus.cancelled
            ).map((status) => ListTile(
              title: Text(_getStatusText(status)),
              onTap: () {
                orderProvider.updateOrderStatus(order.id, status);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order status updated to ${_getStatusText(status)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<Order> _getFilteredOrders(OrderProvider orderProvider) {
    List<Order> orders;

    // First check if we're showing only cancellation requests
    if (_showOnlyCancellationRequests) {
      orders = orderProvider.ordersWithPendingCancellations;
    } else {
      orders = orderProvider.allOrders;
      
      // Filter by status
      if (_selectedStatus != null) {
        orders = orders.where((order) => order.status == _selectedStatus).toList();
      }
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final filteredBySearch = orderProvider.searchOrders(_searchQuery);
      orders = orders.where((order) => 
        filteredBySearch.any((searchOrder) => searchOrder.id == order.id)
      ).toList();
    }

    return orders;
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  Widget _buildCancellationRequestAlert(Order order, OrderProvider orderProvider) {
    final request = order.cancellationRequest!;
    
    // Don't show if already processed
    if (request.processedAt != null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Cancellation Request',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reason: ${request.reason.displayName}',
            style: const TextStyle(fontSize: 13),
          ),
          if (request.customReason != null) ...[
            const SizedBox(height: 4),
            Text(
              'Details: ${request.customReason}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Requested: ${DateFormat('MMM dd, yyyy - HH:mm').format(request.requestedAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _processCancellationRequest(request.id, true, orderProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Approve Cancellation'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _processCancellationRequest(request.id, false, orderProvider),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Deny Request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _processCancellationRequest(String requestId, bool approve, OrderProvider orderProvider) {
    String? adminNotes;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve Cancellation' : 'Deny Cancellation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(approve 
              ? 'Are you sure you want to approve this cancellation request? This action cannot be undone.'
              : 'Are you sure you want to deny this cancellation request?'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Admin Notes (Optional)',
                hintText: approve 
                  ? 'Reason for approval...'
                  : 'Reason for denial...',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => adminNotes = value.isEmpty ? null : value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final success = orderProvider.processCancellationRequest(
                requestId, 
                approve, 
                adminNotes: adminNotes,
              );
              
              Navigator.of(context).pop();
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(approve 
                      ? 'Cancellation request approved'
                      : 'Cancellation request denied'),
                    backgroundColor: approve ? Colors.red : Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to process cancellation request'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.red : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: Text(approve ? 'Approve' : 'Deny'),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cod:
        return Icons.money;
      case PaymentMethod.upi:
        return Icons.qr_code;
      case PaymentMethod.card:
        return Icons.credit_card;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.grey;
    }
  }
}