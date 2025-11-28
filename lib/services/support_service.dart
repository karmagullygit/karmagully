import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/support_ticket.dart';
import '../models/support_message.dart';
import '../models/order.dart';
import '../models/order_tracking.dart';

class SupportService {
  static const String _ticketsKey = 'support_tickets';
  static const String _messagesKey = 'support_messages';

  // Ticket Management
  static Future<List<SupportTicket>> getAllTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ticketsJson = prefs.getString(_ticketsKey);
      
      if (ticketsJson != null) {
        final List<dynamic> decoded = json.decode(ticketsJson);
        return decoded.map((item) => SupportTicket.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading tickets: $e');
      return [];
    }
  }

  static Future<List<SupportTicket>> getTicketsByCustomerId(String customerId) async {
    final allTickets = await getAllTickets();
    return allTickets.where((ticket) => ticket.customerId == customerId).toList();
  }

  static Future<SupportTicket?> getTicketById(String ticketId) async {
    final allTickets = await getAllTickets();
    try {
      return allTickets.firstWhere((ticket) => ticket.id == ticketId);
    } catch (e) {
      return null;
    }
  }

  static Future<String> createTicket({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String subject,
    required String initialMessage,
    String priority = 'medium',
    String? orderId,
  }) async {
    final ticketId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final ticket = SupportTicket(
      id: ticketId,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      subject: subject,
      priority: priority,
      orderId: orderId,
      createdAt: now,
      updatedAt: now,
    );

    // Save ticket
    final tickets = await getAllTickets();
    tickets.add(ticket);
    await _saveTickets(tickets);

    // Create initial message
    final messageId = '${ticketId}_${DateTime.now().millisecondsSinceEpoch}';
    final message = SupportMessage(
      id: messageId,
      ticketId: ticketId,
      senderId: customerId,
      senderName: customerName,
      senderType: 'customer',
      message: initialMessage,
      timestamp: now,
    );

    await addMessage(message);

    return ticketId;
  }

  static Future<void> updateTicketStatus(String ticketId, String status) async {
    final tickets = await getAllTickets();
    final ticketIndex = tickets.indexWhere((t) => t.id == ticketId);
    
    if (ticketIndex != -1) {
      final updatedTicket = tickets[ticketIndex].copyWith(
        status: status,
        updatedAt: DateTime.now(),
        resolvedAt: (status == 'resolved' || status == 'closed') ? DateTime.now() : null,
      );
      tickets[ticketIndex] = updatedTicket;
      await _saveTickets(tickets);
    }
  }

  static Future<void> assignTicketToAdmin(String ticketId, String adminId) async {
    final tickets = await getAllTickets();
    final ticketIndex = tickets.indexWhere((t) => t.id == ticketId);
    
    if (ticketIndex != -1) {
      final updatedTicket = tickets[ticketIndex].copyWith(
        assignedToAdminId: adminId,
        status: 'in_progress',
        updatedAt: DateTime.now(),
      );
      tickets[ticketIndex] = updatedTicket;
      await _saveTickets(tickets);
    }
  }

  static Future<void> updateTicketPriority(String ticketId, String priority) async {
    final tickets = await getAllTickets();
    final ticketIndex = tickets.indexWhere((t) => t.id == ticketId);
    
    if (ticketIndex != -1) {
      final updatedTicket = tickets[ticketIndex].copyWith(
        priority: priority,
        updatedAt: DateTime.now(),
      );
      tickets[ticketIndex] = updatedTicket;
      await _saveTickets(tickets);
    }
  }

  // Message Management
  static Future<List<SupportMessage>> getMessagesByTicketId(String ticketId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      if (messagesJson != null) {
        final List<dynamic> decoded = json.decode(messagesJson);
        final allMessages = decoded.map((item) => SupportMessage.fromJson(item)).toList();
        return allMessages.where((message) => message.ticketId == ticketId).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading messages: $e');
      return [];
    }
  }

  static Future<void> addMessage(SupportMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      List<SupportMessage> messages = [];
      if (messagesJson != null) {
        final List<dynamic> decoded = json.decode(messagesJson);
        messages = decoded.map((item) => SupportMessage.fromJson(item)).toList();
      }
      
      messages.add(message);
      await _saveMessages(messages);

      // Update ticket's unread count if message is from customer
      if (message.senderType == 'customer') {
        await _incrementUnreadCount(message.ticketId);
      }

      // Update ticket's last updated time
      final tickets = await getAllTickets();
      final ticketIndex = tickets.indexWhere((t) => t.id == message.ticketId);
      if (ticketIndex != -1) {
        final updatedTicket = tickets[ticketIndex].copyWith(
          updatedAt: DateTime.now(),
        );
        tickets[ticketIndex] = updatedTicket;
        await _saveTickets(tickets);
      }
    } catch (e) {
      print('Error adding message: $e');
    }
  }

  static Future<void> markMessagesAsRead(String ticketId, String readerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      if (messagesJson != null) {
        final List<dynamic> decoded = json.decode(messagesJson);
        final messages = decoded.map((item) => SupportMessage.fromJson(item)).toList();
        
        for (int i = 0; i < messages.length; i++) {
          if (messages[i].ticketId == ticketId && 
              messages[i].senderId != readerId && 
              !messages[i].isRead) {
            messages[i] = messages[i].copyWith(isRead: true);
          }
        }
        
        await _saveMessages(messages);

        // Reset unread count for the ticket
        await _resetUnreadCount(ticketId);
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Helper methods
  static Future<void> _saveTickets(List<SupportTicket> tickets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ticketsJson = json.encode(tickets.map((t) => t.toJson()).toList());
      await prefs.setString(_ticketsKey, ticketsJson);
    } catch (e) {
      print('Error saving tickets: $e');
    }
  }

  static Future<void> _saveMessages(List<SupportMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      await prefs.setString(_messagesKey, messagesJson);
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  static Future<void> _incrementUnreadCount(String ticketId) async {
    final tickets = await getAllTickets();
    final ticketIndex = tickets.indexWhere((t) => t.id == ticketId);
    
    if (ticketIndex != -1) {
      final updatedTicket = tickets[ticketIndex].copyWith(
        unreadMessages: tickets[ticketIndex].unreadMessages + 1,
      );
      tickets[ticketIndex] = updatedTicket;
      await _saveTickets(tickets);
    }
  }

  static Future<void> _resetUnreadCount(String ticketId) async {
    final tickets = await getAllTickets();
    final ticketIndex = tickets.indexWhere((t) => t.id == ticketId);
    
    if (ticketIndex != -1) {
      final updatedTicket = tickets[ticketIndex].copyWith(
        unreadMessages: 0,
      );
      tickets[ticketIndex] = updatedTicket;
      await _saveTickets(tickets);
    }
  }

  // Statistics for admin dashboard
  static Future<Map<String, int>> getTicketStats() async {
    final tickets = await getAllTickets();
    
    return {
      'total': tickets.length,
      'open': tickets.where((t) => t.status == 'open').length,
      'in_progress': tickets.where((t) => t.status == 'in_progress').length,
      'resolved': tickets.where((t) => t.status == 'resolved').length,
      'closed': tickets.where((t) => t.status == 'closed').length,
      'unread': tickets.where((t) => t.unreadMessages > 0).length,
    };
  }

  // Clear all data (for testing/debugging)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ticketsKey);
    await prefs.remove(_messagesKey);
  }

  // Order Integration Methods
  static Map<String, dynamic> formatOrderDetailsForMessage(Order order) {
    return {
      'orderId': order.id,
      'orderDate': order.createdAt.toIso8601String(),
      'status': order.status.toString().split('.').last,
      'totalAmount': order.totalAmount,
      'customerName': order.customerName,
      'customerEmail': order.customerEmail,
      'customerPhone': order.customerPhone,
      'shippingAddress': order.shippingAddress,
      'deliveredAt': order.deliveredAt?.toIso8601String(),
      'notes': order.notes,
      'items': order.items.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'productImage': item.product.imageUrl,
        'quantity': item.quantity,
        'price': item.product.price,
        'totalPrice': item.totalPrice,
      }).toList(),
      'paymentStatus': _getPaymentStatus(order),
      'itemsCount': order.items.length,
      'totalItems': order.items.fold(0, (sum, item) => sum + item.quantity),
    };
  }

  static String _getPaymentStatus(Order order) {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Pending Payment';
      case OrderStatus.confirmed:
        return 'Payment Confirmed';
      case OrderStatus.processing:
        return 'Payment Confirmed';
      case OrderStatus.shipped:
        return 'Paid';
      case OrderStatus.outForDelivery:
        return 'Paid';
      case OrderStatus.delivered:
        return 'Paid & Delivered';
      case OrderStatus.cancelled:
        return 'Refunded';
      case OrderStatus.returned:
        return 'Refunded';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  static String generateOrderSummaryMessage(Order order) {
    final buffer = StringBuffer();
    buffer.writeln('📦 **Order Details**');
    buffer.writeln('Order ID: ${order.id}');
    buffer.writeln('Date: ${_formatDate(order.createdAt)}');
    buffer.writeln('Status: ${_formatOrderStatus(order.status)}');
    buffer.writeln('Payment: ${_getPaymentStatus(order)}');
    buffer.writeln('Total: ₹${order.totalAmount.toStringAsFixed(2)}');
    buffer.writeln('');
    
    buffer.writeln('🛍️ **Items (${order.items.length})**');
    for (var item in order.items) {
      buffer.writeln('• ${item.product.name}');
      buffer.writeln('  Qty: ${item.quantity} × ₹${item.product.price}');
      buffer.writeln('  Total: ₹${item.totalPrice}');
      buffer.writeln('');
    }
    
    buffer.writeln('🚚 **Shipping Address**');
    buffer.writeln(order.shippingAddress);
    
    if (order.deliveredAt != null) {
      buffer.writeln('');
      buffer.writeln('✅ **Delivered**');
      buffer.writeln('Date: ${_formatDate(order.deliveredAt!)}');
    }
    
    if (order.notes?.isNotEmpty == true) {
      buffer.writeln('');
      buffer.writeln('📝 **Notes**');
      buffer.writeln(order.notes);
    }
    
    return buffer.toString();
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '⏳ Pending';
      case OrderStatus.confirmed:
        return '✅ Confirmed';
      case OrderStatus.processing:
        return '⚙️ Processing';
      case OrderStatus.shipped:
        return '🚚 Shipped';
      case OrderStatus.outForDelivery:
        return '🚛 Out for Delivery';
      case OrderStatus.delivered:
        return '📦 Delivered';
      case OrderStatus.cancelled:
        return '❌ Cancelled';
      case OrderStatus.returned:
        return '↩️ Returned';
      case OrderStatus.refunded:
        return '💰 Refunded';
    }
  }
}