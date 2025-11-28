class SupportTicket {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String subject;
  final String status; // 'open', 'in_progress', 'resolved', 'closed'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String? orderId; // Optional order ID if query is related to an order
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? assignedToAdminId;
  final int unreadMessages; // Count of unread messages from customer

  SupportTicket({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.subject,
    this.status = 'open',
    this.priority = 'medium',
    this.orderId,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.assignedToAdminId,
    this.unreadMessages = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'subject': subject,
      'status': status,
      'priority': priority,
      'orderId': orderId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'assignedToAdminId': assignedToAdminId,
      'unreadMessages': unreadMessages,
    };
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      subject: json['subject'],
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      orderId: json['orderId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      assignedToAdminId: json['assignedToAdminId'],
      unreadMessages: json['unreadMessages'] ?? 0,
    );
  }

  SupportTicket copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? subject,
    String? status,
    String? priority,
    String? orderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? assignedToAdminId,
    int? unreadMessages,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      assignedToAdminId: assignedToAdminId ?? this.assignedToAdminId,
      unreadMessages: unreadMessages ?? this.unreadMessages,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Medium';
    }
  }
}