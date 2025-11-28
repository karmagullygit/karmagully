import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../models/order_tracking.dart';
import '../../models/payment_method.dart';
import '../../providers/order_provider.dart';
import '../../utils/navigation_helper.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePop(context),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final order = orderProvider.getOrderById(orderId);

          if (order == null) {
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
                    'Order not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => NavigationHelper.safePop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                _buildOrderHeader(order),
                const SizedBox(height: 24),
                
                // Customer Information
                _buildCustomerInfo(order),
                const SizedBox(height: 24),
                
                // Order Items
                _buildOrderItems(order),
                const SizedBox(height: 24),
                
                // Order Summary
                _buildOrderSummary(order),
                const SizedBox(height: 24),
                
                // Payment Information
                if (order.paymentInfo != null) ...[
                  _buildPaymentInfo(order, context),
                  const SizedBox(height: 24),
                ],
                
                // Order Timeline
                _buildOrderTimeline(order),
                const SizedBox(height: 24),
                
                // Admin Actions
                _buildAdminActions(order, orderProvider, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Placed on ${DateFormat('MMMM dd, yyyy \'at\' HH:mm').format(order.createdAt)}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Name', order.customerName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, 'Email', order.customerEmail),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Phone', order.customerPhone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.fingerprint, 'Customer ID', order.userId),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Shipping Address', order.shippingAddress),
            if (order.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.note, 'Notes', order.notes!),
            ],
            if (order.deliveredAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.check_circle,
                'Delivered',
                DateFormat('MMMM dd, yyyy \'at\' HH:mm').format(order.deliveredAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (order.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Order items not available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ...order.items.map((item) => _buildOrderItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                'Total: \$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Items:'),
                Text('${order.items.length}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('\$${order.totalAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping:'),
                const Text('Free'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(Order order, BuildContext context) {
    final paymentInfo = order.paymentInfo!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment Method
            Row(
              children: [
                const Text(
                  'Method:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor(paymentInfo.method),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    paymentInfo.method.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Payment Status
            Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(paymentInfo.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    paymentInfo.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Transaction ID
            if (paymentInfo.transactionId != null) ...[
              Row(
                children: [
                  const Text(
                    'Transaction ID:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      paymentInfo.transactionId!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      // Copy transaction ID to clipboard
                      Clipboard.setData(ClipboardData(text: paymentInfo.transactionId!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction ID copied to clipboard'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Processed At
            if (paymentInfo.processedAt != null) ...[
              Row(
                children: [
                  const Text(
                    'Processed At:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(paymentInfo.processedAt!),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Payment Details
            if (paymentInfo.details != null) ...[
              const Text(
                'Details:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildPaymentDetails(paymentInfo),
                ),
              ),
            ],
            
            // Failure Reason
            if (paymentInfo.failureReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Failure Reason:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            paymentInfo.failureReason!,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cod:
        return Colors.green;
      case PaymentMethod.upi:
        return Colors.blue;
      case PaymentMethod.card:
        return Colors.purple;
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

  List<Widget> _buildPaymentDetails(PaymentInfo paymentInfo) {
    final details = paymentInfo.details!;
    final widgets = <Widget>[];

    if (paymentInfo.method == PaymentMethod.upi && details['upiId'] != null) {
      widgets.add(
        Row(
          children: [
            const Text('UPI ID:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Expanded(child: Text(details['upiId'])),
          ],
        ),
      );
    }

    if (paymentInfo.method == PaymentMethod.card) {
      if (details['cardNumber'] != null) {
        widgets.add(
          Row(
            children: [
              const Text('Card:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(child: Text(details['cardNumber'])),
            ],
          ),
        );
      }
      if (details['cardType'] != null) {
        widgets.add(
          Row(
            children: [
              const Text('Type:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(child: Text(details['cardType'])),
            ],
          ),
        );
      }
    }

    if (paymentInfo.method == PaymentMethod.cod) {
      if (details['cashAmount'] != null) {
        widgets.add(
          Row(
            children: [
              const Text('Cash Amount:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(child: Text('₹${details['cashAmount']}')),
            ],
          ),
        );
      }
    }

    // Gateway Response
    if (details['gateway_response'] != null) {
      final gateway = details['gateway_response'] as Map<String, dynamic>;
      widgets.add(const Divider());
      widgets.add(
        const Text(
          'Gateway Response:',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
        ),
      );
      gateway.forEach((key, value) {
        widgets.add(
          Row(
            children: [
              Text('$key:', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(child: Text('$value', style: const TextStyle(fontSize: 12))),
            ],
          ),
        );
      });
    }

    return widgets;
  }

  Widget _buildOrderTimeline(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimelineItem(
              'Order Placed',
              DateFormat('MMM dd, yyyy - HH:mm').format(order.createdAt),
              true,
              Colors.blue,
            ),
            if (order.status.index >= OrderStatus.confirmed.index)
              _buildTimelineItem(
                'Order Confirmed',
                'Processing your order',
                true,
                Colors.blue,
              ),
            if (order.status.index >= OrderStatus.shipped.index)
              _buildTimelineItem(
                'Order Shipped',
                'Your order is on the way',
                true,
                Colors.blue,
              ),
            if (order.status == OrderStatus.delivered && order.deliveredAt != null)
              _buildTimelineItem(
                'Order Delivered',
                DateFormat('MMM dd, yyyy - HH:mm').format(order.deliveredAt!),
                true,
                Colors.green,
              ),
            if (order.status == OrderStatus.cancelled)
              _buildTimelineItem(
                'Order Cancelled',
                'Order was cancelled',
                true,
                Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool completed, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: completed ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: completed ? color : Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(Order order, OrderProvider orderProvider, BuildContext context) {
    if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showStatusUpdateDialog(order, orderProvider, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Order Status'),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showStatusUpdateDialog(Order order, OrderProvider orderProvider, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
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
}