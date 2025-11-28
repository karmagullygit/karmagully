enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returned,
  refunded,
}

enum CancellationReason {
  changeOfMind,
  foundBetterPrice,
  orderByMistake,
  duplicateOrder,
  productNotNeeded,
  deliveryDelay,
  other,
}

class OrderStatusUpdate {
  final String id;
  final OrderStatus status;
  final DateTime timestamp;
  final String? description;
  final String? location;
  final String? notes;

  OrderStatusUpdate({
    required this.id,
    required this.status,
    required this.timestamp,
    this.description,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'location': location,
      'notes': notes,
    };
  }

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      id: json['id'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      location: json['location'],
      notes: json['notes'],
    );
  }
}

class TrackingInfo {
  final String trackingNumber;
  final String? carrierName;
  final String? carrierUrl;
  final DateTime? estimatedDelivery;
  final List<OrderStatusUpdate> statusHistory;

  TrackingInfo({
    required this.trackingNumber,
    this.carrierName,
    this.carrierUrl,
    this.estimatedDelivery,
    required this.statusHistory,
  });

  OrderStatus get currentStatus {
    if (statusHistory.isEmpty) return OrderStatus.pending;
    return statusHistory.last.status;
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingNumber': trackingNumber,
      'carrierName': carrierName,
      'carrierUrl': carrierUrl,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
    };
  }

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      trackingNumber: json['trackingNumber'],
      carrierName: json['carrierName'],
      carrierUrl: json['carrierUrl'],
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => OrderStatusUpdate.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CancellationRequest {
  final String id;
  final String orderId;
  final CancellationReason reason;
  final String? customReason;
  final DateTime requestedAt;
  final bool isApproved;
  final String? adminNotes;
  final DateTime? processedAt;

  CancellationRequest({
    required this.id,
    required this.orderId,
    required this.reason,
    this.customReason,
    required this.requestedAt,
    this.isApproved = false,
    this.adminNotes,
    this.processedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'reason': reason.name,
      'customReason': customReason,
      'requestedAt': requestedAt.toIso8601String(),
      'isApproved': isApproved,
      'adminNotes': adminNotes,
      'processedAt': processedAt?.toIso8601String(),
    };
  }

  factory CancellationRequest.fromJson(Map<String, dynamic> json) {
    return CancellationRequest(
      id: json['id'],
      orderId: json['orderId'],
      reason: CancellationReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => CancellationReason.other,
      ),
      customReason: json['customReason'],
      requestedAt: DateTime.parse(json['requestedAt']),
      isApproved: json['isApproved'] ?? false,
      adminNotes: json['adminNotes'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
    );
  }
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
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

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Your order has been received and is waiting for confirmation';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed and is being prepared';
      case OrderStatus.processing:
        return 'Your order is being processed and prepared for shipment';
      case OrderStatus.shipped:
        return 'Your order has been shipped and is on its way';
      case OrderStatus.outForDelivery:
        return 'Your order is out for delivery and will arrive soon';
      case OrderStatus.delivered:
        return 'Your order has been successfully delivered';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
      case OrderStatus.returned:
        return 'Your order has been returned';
      case OrderStatus.refunded:
        return 'Your order amount has been refunded';
    }
  }

  bool get canBeCancelled {
    return this == OrderStatus.pending ||
        this == OrderStatus.confirmed ||
        this == OrderStatus.processing;
  }

  bool get isCompleted {
    return this == OrderStatus.delivered ||
        this == OrderStatus.cancelled ||
        this == OrderStatus.returned ||
        this == OrderStatus.refunded;
  }
}

extension CancellationReasonExtension on CancellationReason {
  String get displayName {
    switch (this) {
      case CancellationReason.changeOfMind:
        return 'Change of mind';
      case CancellationReason.foundBetterPrice:
        return 'Found better price elsewhere';
      case CancellationReason.orderByMistake:
        return 'Ordered by mistake';
      case CancellationReason.duplicateOrder:
        return 'Duplicate order';
      case CancellationReason.productNotNeeded:
        return 'Product no longer needed';
      case CancellationReason.deliveryDelay:
        return 'Delivery taking too long';
      case CancellationReason.other:
        return 'Other reason';
    }
  }
}