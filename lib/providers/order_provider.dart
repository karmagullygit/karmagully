import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../models/order_tracking.dart';
import '../models/payment_method.dart';
import '../services/notification_service.dart';
import '../services/auto_whatsapp_service.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];
  final List<CancellationRequest> _cancellationRequests = [];
  final Uuid _uuid = const Uuid();

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> get allOrders => List.unmodifiable(_orders);

  List<CancellationRequest> get cancellationRequests => 
      List.unmodifiable(_cancellationRequests);

  List<Order> getUserOrders(String userId) {
    return _orders.where((order) => order.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get orders with pending cancellation requests
  List<Order> get ordersWithPendingCancellations {
    return _orders.where((order) => 
      order.cancellationRequest != null && 
      order.cancellationRequest!.processedAt == null
    ).toList()
      ..sort((a, b) => a.cancellationRequest!.requestedAt
          .compareTo(b.cancellationRequest!.requestedAt));
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  int get totalOrders => _orders.length;

  int get pendingOrdersCount => 
      _orders.where((order) => order.status == OrderStatus.pending).length;

  int get processingOrdersCount => 
      _orders.where((order) => order.status == OrderStatus.processing).length;

  int get shippedOrdersCount => 
      _orders.where((order) => order.status == OrderStatus.shipped).length;

  int get cancelledOrdersCount => 
      _orders.where((order) => order.status == OrderStatus.cancelled).length;

  int get deliveredOrdersCount => 
      _orders.where((order) => order.status == OrderStatus.delivered).length;

  double get totalRevenue => 
      _orders.where((order) => order.status == OrderStatus.delivered)
             .fold(0.0, (sum, order) => sum + order.totalAmount);

  /// Place a new order
  Future<String> placeOrder({
    required User user,
    required List<CartItem> cartItems,
    required String shippingAddress,
    String? notes,
    PaymentInfo? paymentInfo,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Cannot place order with empty cart');
    }

    final orderId = _uuid.v4();
    final totalAmount = cartItems.fold(
      0.0, 
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    final order = Order(
      id: orderId,
      userId: user.id,
      customerName: user.name,
      customerEmail: user.email,
      customerPhone: user.phone,
      items: List.from(cartItems),
      totalAmount: totalAmount,
      status: OrderStatus.pending,
      shippingAddress: shippingAddress,
      createdAt: DateTime.now(),
      notes: notes,
      paymentInfo: paymentInfo,
    );

    _orders.add(order);
    
    // Send email notification (silent - best effort)
    try {
      NotificationService.sendOrderNotification(order);
    } catch (e) {
      debugPrint('Failed to send email notification: $e');
    }
    
    // Send AUTOMATIC WhatsApp notification to admin
    try {
      final sent = await AutoWhatsAppService.sendOrderNotification(order);
      if (sent) {
        debugPrint('✅ WhatsApp notification sent automatically to admin');
      } else {
        debugPrint('⚠️ WhatsApp notification failed - check Twilio configuration');
      }
    } catch (e) {
      debugPrint('Failed to send auto WhatsApp notification: $e');
    }
    
    notifyListeners();

    return orderId;
  }

  /// Update order status (admin function)
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) return false;

      final updatedOrder = _orders[orderIndex].copyWith(
        status: newStatus,
        deliveredAt: newStatus == OrderStatus.delivered ? DateTime.now() : null,
      );

      _orders[orderIndex] = updatedOrder;
      
      // Send AUTOMATIC WhatsApp status update to customer
      try {
        String statusMessage = _getStatusMessage(newStatus);
        final sent = await AutoWhatsAppService.sendStatusUpdate(
          updatedOrder,
          statusMessage,
        );
        if (sent) {
          debugPrint('✅ WhatsApp status update sent automatically to customer');
        } else {
          debugPrint('⚠️ WhatsApp status update failed - check Twilio configuration');
        }
      } catch (e) {
        debugPrint('Failed to send auto WhatsApp status update: $e');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  /// Get user-friendly status message
  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '⏳ Pending - Your order is being processed';
      case OrderStatus.confirmed:
        return '✅ Confirmed - Your order has been confirmed';
      case OrderStatus.processing:
        return '📦 Processing - Your order is being prepared';
      case OrderStatus.shipped:
        return '🚚 Shipped - Your order is on the way';
      case OrderStatus.delivered:
        return '✨ Delivered - Your order has been delivered';
      case OrderStatus.cancelled:
        return '❌ Cancelled - Your order has been cancelled';
      default:
        return 'Order status updated';
    }
  }

  /// Cancel an order (customer can cancel pending orders)
  bool cancelOrder(String orderId, String userId) {
    try {
      final orderIndex = _orders.indexWhere(
        (order) => order.id == orderId && order.userId == userId,
      );
      if (orderIndex == -1) return false;

      final order = _orders[orderIndex];
      
      // Only allow cancellation of pending orders
      if (order.status != OrderStatus.pending) {
        return false;
      }

      final updatedOrder = order.copyWith(status: OrderStatus.cancelled);
      _orders[orderIndex] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }

  /// Load orders (simulated - in real app would fetch from backend)
  Future<void> loadOrders() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Add some dummy orders for demonstration
    if (_orders.isEmpty) {
      _loadDummyOrders();
    }
    
    notifyListeners();
  }

  void _loadDummyOrders() {
    // This would normally come from a backend API
    // Adding some sample orders for demonstration
    final sampleOrders = [
      Order(
        id: _uuid.v4(),
        userId: 'customer_user_id',
        customerName: 'John Doe',
        customerEmail: 'john.doe@email.com',
        customerPhone: '+1234567890',
        items: [], // Would have actual cart items
        totalAmount: 299.99,
        status: OrderStatus.pending,
        shippingAddress: '123 Main St, City, State 12345',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Order(
        id: _uuid.v4(),
        userId: 'customer_user_id',
        customerName: 'Jane Smith',
        customerEmail: 'jane.smith@email.com',
        customerPhone: '+1987654321',
        items: [], // Would have actual cart items
        totalAmount: 149.50,
        status: OrderStatus.confirmed,
        shippingAddress: '456 Oak Ave, City, State 67890',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        // Add a pending cancellation request
        cancellationRequest: CancellationRequest(
          id: _uuid.v4(),
          orderId: '', // Will be filled in after order creation
          reason: CancellationReason.changeOfMind,
          customReason: 'Found a better deal elsewhere',
          requestedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ),
      Order(
        id: _uuid.v4(),
        userId: 'another_user_id',
        customerName: 'Bob Johnson',
        customerEmail: 'bob.johnson@email.com',
        customerPhone: '+1555123456',
        items: [], // Would have actual cart items
        totalAmount: 89.99,
        status: OrderStatus.shipped,
        shippingAddress: '789 Pine St, City, State 11111',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Order(
        id: _uuid.v4(),
        userId: 'customer_user_id',
        customerName: 'Alice Wilson',
        customerEmail: 'alice.wilson@email.com',
        customerPhone: '+1444987654',
        items: [], // Would have actual cart items
        totalAmount: 199.99,
        status: OrderStatus.delivered,
        shippingAddress: '321 Elm St, City, State 22222',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        deliveredAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      // Add another order with cancellation request
      Order(
        id: _uuid.v4(),
        userId: 'customer_user_id',
        customerName: 'Mike Davis',
        customerEmail: 'mike.davis@email.com',
        customerPhone: '+1666777888',
        items: [], // Would have actual cart items
        totalAmount: 75.25,
        status: OrderStatus.processing,
        shippingAddress: '555 Broadway, City, State 33333',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        // Add another pending cancellation request
        cancellationRequest: CancellationRequest(
          id: _uuid.v4(),
          orderId: '', // Will be filled in after order creation
          reason: CancellationReason.orderByMistake,
          customReason: 'Ordered wrong size by mistake',
          requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ),
    ];

    // Fix the cancellation request order IDs
    for (int i = 0; i < sampleOrders.length; i++) {
      if (sampleOrders[i].cancellationRequest != null) {
        final request = sampleOrders[i].cancellationRequest!;
        final updatedRequest = CancellationRequest(
          id: request.id,
          orderId: sampleOrders[i].id,
          reason: request.reason,
          customReason: request.customReason,
          requestedAt: request.requestedAt,
          isApproved: request.isApproved,
          adminNotes: request.adminNotes,
          processedAt: request.processedAt,
        );
        sampleOrders[i] = sampleOrders[i].copyWith(cancellationRequest: updatedRequest);
        _cancellationRequests.add(updatedRequest);
      }
    }

    _orders.addAll(sampleOrders);
    
    // Load sample tracking data for demo
    loadSampleTrackingData();
  }

  /// Clear all orders (for testing purposes)
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  /// Add order method for testing/demo purposes
  void addOrder(Order order) {
    _orders.insert(0, order); // Add to beginning for latest first
    notifyListeners();
  }

  /// Get orders statistics for admin dashboard
  Map<String, dynamic> getOrderStatistics() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrdersCount,
      'processingOrders': processingOrdersCount,
      'shippedOrders': shippedOrdersCount,
      'deliveredOrders': deliveredOrdersCount,
      'totalRevenue': totalRevenue,
    };
  }

  /// Search orders by customer name, email, or order ID
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return orders;
    
    final lowerQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.id.toLowerCase().contains(lowerQuery) ||
             order.userId.toLowerCase().contains(lowerQuery) ||
             order.shippingAddress.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ========== TRACKING METHODS ==========

  /// Update order tracking information
  bool updateOrderTracking(String orderId, TrackingInfo trackingInfo) {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) return false;

      final updatedOrder = _orders[orderIndex].copyWith(
        trackingInfo: trackingInfo,
      );

      _orders[orderIndex] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add tracking status update
  bool addTrackingUpdate(String orderId, OrderStatusUpdate statusUpdate) {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) return false;

      final order = _orders[orderIndex];
      if (order.trackingInfo == null) return false;

      final updatedHistory = [...order.trackingInfo!.statusHistory, statusUpdate];
      final updatedTracking = TrackingInfo(
        trackingNumber: order.trackingInfo!.trackingNumber,
        carrierName: order.trackingInfo!.carrierName,
        carrierUrl: order.trackingInfo!.carrierUrl,
        estimatedDelivery: order.trackingInfo!.estimatedDelivery,
        statusHistory: updatedHistory,
      );

      final updatedOrder = order.copyWith(
        trackingInfo: updatedTracking,
        status: statusUpdate.status,
        deliveredAt: statusUpdate.status == OrderStatus.delivered 
            ? statusUpdate.timestamp 
            : order.deliveredAt,
      );

      _orders[orderIndex] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create initial tracking info for an order
  bool createTrackingInfo(String orderId, String trackingNumber, 
      {String? carrierName, DateTime? estimatedDelivery}) {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) return false;

      final initialUpdate = OrderStatusUpdate(
        id: _uuid.v4(),
        status: OrderStatus.confirmed,
        timestamp: DateTime.now(),
        description: 'Order confirmed and tracking initiated',
      );

      final trackingInfo = TrackingInfo(
        trackingNumber: trackingNumber,
        carrierName: carrierName,
        estimatedDelivery: estimatedDelivery,
        statusHistory: [initialUpdate],
      );

      final updatedOrder = _orders[orderIndex].copyWith(
        trackingInfo: trackingInfo,
        status: OrderStatus.confirmed,
      );

      _orders[orderIndex] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== CANCELLATION METHODS ==========

  /// Submit order cancellation request
  String? requestOrderCancellation(String orderId, CancellationReason reason, 
      {String? customReason}) {
    try {
      final order = getOrderById(orderId);
      if (order == null || !order.status.canBeCancelled) return null;

      final requestId = _uuid.v4();
      final cancellationRequest = CancellationRequest(
        id: requestId,
        orderId: orderId,
        reason: reason,
        customReason: customReason,
        requestedAt: DateTime.now(),
      );

      _cancellationRequests.add(cancellationRequest);

      // Update order with cancellation request
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      final updatedOrder = _orders[orderIndex].copyWith(
        cancellationRequest: cancellationRequest,
      );
      _orders[orderIndex] = updatedOrder;

      notifyListeners();
      return requestId;
    } catch (e) {
      return null;
    }
  }

  /// Process cancellation request (admin function)
  bool processCancellationRequest(String requestId, bool approve, 
      {String? adminNotes}) {
    try {
      final requestIndex = _cancellationRequests
          .indexWhere((req) => req.id == requestId);
      if (requestIndex == -1) return false;

      final request = _cancellationRequests[requestIndex];
      final updatedRequest = CancellationRequest(
        id: request.id,
        orderId: request.orderId,
        reason: request.reason,
        customReason: request.customReason,
        requestedAt: request.requestedAt,
        isApproved: approve,
        adminNotes: adminNotes,
        processedAt: DateTime.now(),
      );

      _cancellationRequests[requestIndex] = updatedRequest;

      // Update order status if approved
      if (approve) {
        final orderIndex = _orders.indexWhere((o) => o.id == request.orderId);
        if (orderIndex != -1) {
          final updatedOrder = _orders[orderIndex].copyWith(
            status: OrderStatus.cancelled,
            cancellationRequest: updatedRequest,
          );
          _orders[orderIndex] = updatedOrder;

          // Add tracking update if tracking exists
          if (updatedOrder.trackingInfo != null) {
            addTrackingUpdate(request.orderId, OrderStatusUpdate(
              id: _uuid.v4(),
              status: OrderStatus.cancelled,
              timestamp: DateTime.now(),
              description: 'Order cancelled at customer request',
              notes: adminNotes,
            ));
          }
        }
      } else {
        // Update order to remove cancellation request if denied
        final orderIndex = _orders.indexWhere((o) => o.id == request.orderId);
        if (orderIndex != -1) {
          final updatedOrder = _orders[orderIndex].copyWith(
            cancellationRequest: updatedRequest,
          );
          _orders[orderIndex] = updatedOrder;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get pending cancellation requests
  List<CancellationRequest> getPendingCancellationRequests() {
    return _cancellationRequests
        .where((req) => req.processedAt == null)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  /// Cancel order immediately (admin function)
  bool cancelOrderDirectly(String orderId, {String? reason}) {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) return false;

      final order = _orders[orderIndex];
      if (!order.status.canBeCancelled) return false;

      final updatedOrder = order.copyWith(status: OrderStatus.cancelled);
      _orders[orderIndex] = updatedOrder;

      // Add tracking update if tracking exists
      if (order.trackingInfo != null) {
        addTrackingUpdate(orderId, OrderStatusUpdate(
          id: _uuid.v4(),
          status: OrderStatus.cancelled,
          timestamp: DateTime.now(),
          description: 'Order cancelled by admin',
          notes: reason,
        ));
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load sample tracking data for demo
  void loadSampleTrackingData() {
    if (_orders.isNotEmpty) {
      // Add tracking to first few orders
      for (int i = 0; i < _orders.length && i < 3; i++) {
        final order = _orders[i];
        createTrackingInfo(
          order.id, 
          'TRK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          carrierName: ['DHL Express', 'FedEx', 'UPS'][i % 3],
          estimatedDelivery: DateTime.now().add(Duration(days: 2 + i)),
        );

        // Add some sample tracking updates
        final statuses = [OrderStatus.processing, OrderStatus.shipped];
        for (int j = 0; j < statuses.length; j++) {
          addTrackingUpdate(order.id, OrderStatusUpdate(
            id: _uuid.v4(),
            status: statuses[j],
            timestamp: DateTime.now().add(Duration(hours: j * 6)),
            description: statuses[j].description,
            location: ['Warehouse', 'Distribution Center'][j],
          ));
        }
      }
    }
  }
}