import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../models/order_tracking.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (orderProvider.orders.isEmpty) {
        // Load sample orders if none exist
        _loadSampleOrders();
      }
    });
  }

  void _loadSampleOrders() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    // Add sample orders
    orderProvider.addOrder(Order(
      id: 'ORD001',
      userId: 'user123',
      customerName: 'John Doe',
      customerEmail: 'john@example.com',
      customerPhone: '+1234567890',
      items: [],
      totalAmount: 299.99,
      status: OrderStatus.delivered,
      shippingAddress: '123 Main St, City, State 12345',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 1)),
    ));
    
    orderProvider.addOrder(Order(
      id: 'ORD002',
      userId: 'user123',
      customerName: 'John Doe',
      customerEmail: 'john@example.com',
      customerPhone: '+1234567890',
      items: [],
      totalAmount: 149.50,
      status: OrderStatus.shipped,
      shippingAddress: '123 Main St, City, State 12345',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ));
    
    orderProvider.addOrder(Order(
      id: 'ORD003',
      userId: 'user123',
      customerName: 'John Doe',
      customerEmail: 'john@example.com',
      customerPhone: '+1234567890',
      items: [],
      totalAmount: 75.25,
      status: OrderStatus.confirmed,
      shippingAddress: '123 Main St, City, State 12345',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(themeProvider.isDarkMode),
          appBar: AppBar(
            title: Text(
              'Order History',
              style: TextStyle(
                color: AppColors.getTextColor(themeProvider.isDarkMode),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.getBackgroundColor(themeProvider.isDarkMode),
            elevation: 0,
            iconTheme: IconThemeData(
              color: AppColors.getTextColor(themeProvider.isDarkMode),
            ),
          ),
          body: Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              if (orderProvider.orders.isEmpty) {
                return _buildEmptyState(themeProvider.isDarkMode);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderProvider.orders.length,
                itemBuilder: (context, index) {
                  final order = orderProvider.orders[index];
                  return _buildOrderCard(order, themeProvider.isDarkMode);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDarkMode),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              _buildStatusChip(order.status, isDarkMode),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Placed on ${_formatDate(order.createdAt)}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to order details
                },
                child: const Text(
                  'View Details',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          if (order.status == OrderStatus.delivered && order.deliveredAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Delivered on ${_formatDate(order.deliveredAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status, bool isDarkMode) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        text = 'Confirmed';
        break;
      case OrderStatus.processing:
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        text = 'Processing';
        break;
      case OrderStatus.shipped:
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        text = 'Shipped';
        break;
      case OrderStatus.outForDelivery:
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        text = 'Out for Delivery';
        break;
      case OrderStatus.delivered:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = 'Cancelled';
        break;
      case OrderStatus.returned:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = 'Returned';
        break;
      case OrderStatus.refunded:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        text = 'Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}