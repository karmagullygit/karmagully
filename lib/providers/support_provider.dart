import 'package:flutter/material.dart';
import '../models/support_ticket.dart';
import '../models/support_message.dart';
import '../models/order.dart';
import '../services/support_service.dart';

class SupportProvider extends ChangeNotifier {
  List<SupportTicket> _tickets = [];
  List<SupportMessage> _messages = [];
  Map<String, int> _ticketStats = {};
  bool _isLoading = false;
  String? _currentTicketId;

  // Getters
  List<SupportTicket> get tickets => _tickets;
  List<SupportMessage> get messages => _messages;
  Map<String, int> get ticketStats => _ticketStats;
  bool get isLoading => _isLoading;
  String? get currentTicketId => _currentTicketId;

  // Get tickets for specific customer
  List<SupportTicket> getCustomerTickets(String customerId) {
    return _tickets.where((ticket) => ticket.customerId == customerId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // Get current ticket
  SupportTicket? get currentTicket {
    if (_currentTicketId == null) return null;
    try {
      return _tickets.firstWhere((ticket) => ticket.id == _currentTicketId);
    } catch (e) {
      return null;
    }
  }

  // Load all tickets (for admin)
  Future<void> loadAllTickets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tickets = await SupportService.getAllTickets();
      _tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      await loadTicketStats();
    } catch (e) {
      debugPrint('Error loading tickets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load tickets for specific customer
  Future<void> loadCustomerTickets(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tickets = await SupportService.getTicketsByCustomerId(customerId);
      _tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('Error loading customer tickets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load messages for specific ticket
  Future<void> loadMessages(String ticketId) async {
    _currentTicketId = ticketId;
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await SupportService.getMessagesByTicketId(ticketId);
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new support ticket
  Future<String?> createTicket({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String subject,
    required String initialMessage,
    String priority = 'medium',
    String? orderId,
  }) async {
    try {
      final ticketId = await SupportService.createTicket(
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        subject: subject,
        initialMessage: initialMessage,
        priority: priority,
        orderId: orderId,
      );

      // Reload tickets to include the new one
      await loadCustomerTickets(customerId);
      return ticketId;
    } catch (e) {
      debugPrint('Error creating ticket: $e');
      return null;
    }
  }

  // Send message
  Future<void> sendMessage({
    required String ticketId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String message,
    Map<String, dynamic>? orderDetails,
  }) async {
    try {
      final messageId = '${ticketId}_${DateTime.now().millisecondsSinceEpoch}';
      final supportMessage = SupportMessage(
        id: messageId,
        ticketId: ticketId,
        senderId: senderId,
        senderName: senderName,
        senderType: senderType,
        message: message,
        timestamp: DateTime.now(),
        orderDetails: orderDetails,
      );

      await SupportService.addMessage(supportMessage);
      
      // Reload messages to include the new one
      await loadMessages(ticketId);
      
      // Reload tickets to update timestamp
      if (senderType == 'customer') {
        await loadCustomerTickets(senderId);
      } else {
        await loadAllTickets();
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  // Send message with order details
  Future<void> sendMessageWithOrderDetails({
    required String ticketId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String message,
    required Order order,
  }) async {
    final orderDetails = SupportService.formatOrderDetailsForMessage(order);
    final orderSummary = SupportService.generateOrderSummaryMessage(order);
    
    // Combine user message with order summary
    final fullMessage = '$message\n\n$orderSummary';
    
    await sendMessage(
      ticketId: ticketId,
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      message: fullMessage,
      orderDetails: orderDetails,
    );
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String ticketId, String readerId) async {
    try {
      await SupportService.markMessagesAsRead(ticketId, readerId);
      
      // Reload messages to update read status
      await loadMessages(ticketId);
      
      // Reload tickets to update unread count
      await loadAllTickets();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Update ticket status (admin only)
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      await SupportService.updateTicketStatus(ticketId, status);
      await loadAllTickets();
    } catch (e) {
      debugPrint('Error updating ticket status: $e');
    }
  }

  // Assign ticket to admin
  Future<void> assignTicketToAdmin(String ticketId, String adminId) async {
    try {
      await SupportService.assignTicketToAdmin(ticketId, adminId);
      await loadAllTickets();
    } catch (e) {
      debugPrint('Error assigning ticket: $e');
    }
  }

  // Update ticket priority
  Future<void> updateTicketPriority(String ticketId, String priority) async {
    try {
      await SupportService.updateTicketPriority(ticketId, priority);
      await loadAllTickets();
    } catch (e) {
      debugPrint('Error updating ticket priority: $e');
    }
  }

  // Load ticket statistics
  Future<void> loadTicketStats() async {
    try {
      _ticketStats = await SupportService.getTicketStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading ticket stats: $e');
    }
  }

  // Get ticket by ID
  Future<SupportTicket?> getTicketById(String ticketId) async {
    try {
      return await SupportService.getTicketById(ticketId);
    } catch (e) {
      debugPrint('Error getting ticket: $e');
      return null;
    }
  }

  // Clear current ticket
  void clearCurrentTicket() {
    _currentTicketId = null;
    _messages.clear();
    notifyListeners();
  }

  // Filter tickets by status
  List<SupportTicket> getTicketsByStatus(String status) {
    return _tickets.where((ticket) => ticket.status == status).toList();
  }

  // Filter tickets by priority
  List<SupportTicket> getTicketsByPriority(String priority) {
    return _tickets.where((ticket) => ticket.priority == priority).toList();
  }

  // Get unread tickets count
  int get unreadTicketsCount {
    return _tickets.where((ticket) => ticket.unreadMessages > 0).length;
  }

  // Get tickets with unread messages
  List<SupportTicket> get unreadTickets {
    return _tickets.where((ticket) => ticket.unreadMessages > 0).toList();
  }
}