import 'cart_item.dart';
import 'order_tracking.dart';
import 'payment_method.dart';

class Order {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? notes;
  final TrackingInfo? trackingInfo;
  final CancellationRequest? cancellationRequest;
  final PaymentInfo? paymentInfo;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    this.deliveredAt,
    this.notes,
    this.trackingInfo,
    this.cancellationRequest,
    this.paymentInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: json['shippingAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      notes: json['notes'],
      trackingInfo: json['trackingInfo'] != null
          ? TrackingInfo.fromJson(json['trackingInfo'])
          : null,
      cancellationRequest: json['cancellationRequest'] != null
          ? CancellationRequest.fromJson(json['cancellationRequest'])
          : null,
      paymentInfo: json['paymentInfo'] != null
          ? PaymentInfo.fromJson(json['paymentInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'notes': notes,
      'trackingInfo': trackingInfo?.toJson(),
      'cancellationRequest': cancellationRequest?.toJson(),
      'paymentInfo': paymentInfo?.toJson(),
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<CartItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? shippingAddress,
    DateTime? createdAt,
    DateTime? deliveredAt,
    String? notes,
    TrackingInfo? trackingInfo,
    CancellationRequest? cancellationRequest,
    PaymentInfo? paymentInfo,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
      trackingInfo: trackingInfo ?? this.trackingInfo,
      cancellationRequest: cancellationRequest ?? this.cancellationRequest,
      paymentInfo: paymentInfo ?? this.paymentInfo,
    );
  }
}

