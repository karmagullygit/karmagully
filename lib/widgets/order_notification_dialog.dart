import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/whatsapp_service.dart';

class OrderNotificationDialog extends StatelessWidget {
  final Order order;
  final bool isAdmin;

  const OrderNotificationDialog({
    super.key,
    required this.order,
    this.isAdmin = false,
  });

  static void show(BuildContext context, Order order, {bool isAdmin = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderNotificationDialog(
        order: order,
        isAdmin: isAdmin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1F26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Order Placed!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAdmin
                ? 'New order from ${order.customerName}'
                : 'Your order has been placed successfully!',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.receipt, 'Order ID', order.id.substring(0, 8)),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.attach_money,
            'Total',
            '₹${order.totalAmount.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.shopping_bag,
            'Items',
            '${order.items.length} item(s)',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAdmin
                        ? 'Send WhatsApp notification?'
                        : 'Get order confirmation on WhatsApp?',
                    style: TextStyle(color: Colors.grey[300], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.of(context).pop();
            
            // Open WhatsApp with pre-filled message
            if (isAdmin) {
              await WhatsAppService.sendOrderNotificationToAdmin(order);
            } else {
              await WhatsAppService.sendOrderConfirmationToCustomer(order);
            }
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Opening WhatsApp... Click Send to notify'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          icon: const Icon(Icons.chat_bubble),
          label: const Text('Open WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
