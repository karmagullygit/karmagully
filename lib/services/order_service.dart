import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/order_tracking.dart';
import '../models/payment_method.dart';

class OrderService {
  static final List<Order> _mockOrders = [];

  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockOrders);
  }

  Future<List<Order>> getOrdersByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockOrders.where((order) => order.userId == userId).toList();
  }

  Future<String> createOrder({
    required String userId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required List<CartItem> items,
    required String shippingAddress,
    PaymentInfo? paymentInfo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      items: items,
      totalAmount: items.fold(0.0, (total, item) => total + item.totalPrice),
      status: OrderStatus.pending,
      shippingAddress: shippingAddress,
      createdAt: DateTime.now(),
      paymentInfo: paymentInfo,
    );
    
    _mockOrders.add(order);
    return order.id;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _mockOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(
        status: status,
        deliveredAt: status == OrderStatus.delivered ? DateTime.now() : null,
      );
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  Future<Map<String, int>> getOrderStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final total = _mockOrders.length;
    final pending = _mockOrders.where((o) => o.status == OrderStatus.pending).length;
    final confirmed = _mockOrders.where((o) => o.status == OrderStatus.confirmed).length;
    final shipped = _mockOrders.where((o) => o.status == OrderStatus.shipped).length;
    final delivered = _mockOrders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelled = _mockOrders.where((o) => o.status == OrderStatus.cancelled).length;
    
    return {
      'total': total,
      'pending': pending,
      'confirmed': confirmed,
      'shipped': shipped,
      'delivered': delivered,
      'cancelled': cancelled,
    };
  }
}