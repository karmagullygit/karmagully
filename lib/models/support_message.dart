class SupportMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final String senderType; // 'customer' or 'admin'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? orderDetails; // New field for order information
  final List<String>? attachments; // New field for attachments

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.orderDetails,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'orderDetails': orderDetails,
      'attachments': attachments,
    };
  }

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'],
      ticketId: json['ticketId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderType: json['senderType'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      orderDetails: json['orderDetails'] != null 
          ? Map<String, dynamic>.from(json['orderDetails'])
          : null,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
    );
  }

  SupportMessage copyWith({
    String? id,
    String? ticketId,
    String? senderId,
    String? senderName,
    String? senderType,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? orderDetails,
    List<String>? attachments,
  }) {
    return SupportMessage(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      orderDetails: orderDetails ?? this.orderDetails,
      attachments: attachments ?? this.attachments,
    );
  }
}