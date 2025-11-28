enum PaymentMethod {
  cod,
  upi,
  card,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
}

class PaymentInfo {
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime? processedAt;
  final Map<String, dynamic>? details;
  final String? failureReason;

  PaymentInfo({
    required this.method,
    required this.status,
    this.transactionId,
    this.processedAt,
    this.details,
    this.failureReason,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.cod,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      details: json['details'],
      failureReason: json['failureReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.name,
      'status': status.name,
      'transactionId': transactionId,
      'processedAt': processedAt?.toIso8601String(),
      'details': details,
      'failureReason': failureReason,
    };
  }

  PaymentInfo copyWith({
    PaymentMethod? method,
    PaymentStatus? status,
    String? transactionId,
    DateTime? processedAt,
    Map<String, dynamic>? details,
    String? failureReason,
  }) {
    return PaymentInfo(
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      processedAt: processedAt ?? this.processedAt,
      details: details ?? this.details,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}

// COD Payment Details
class CODPaymentDetails {
  final bool isConfirmed;
  final String? instructions;
  final double cashAmount;
  final double changeRequired;

  CODPaymentDetails({
    required this.isConfirmed,
    this.instructions,
    required this.cashAmount,
    this.changeRequired = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'isConfirmed': isConfirmed,
      'instructions': instructions,
      'cashAmount': cashAmount,
      'changeRequired': changeRequired,
    };
  }

  factory CODPaymentDetails.fromJson(Map<String, dynamic> json) {
    return CODPaymentDetails(
      isConfirmed: json['isConfirmed'] ?? false,
      instructions: json['instructions'],
      cashAmount: json['cashAmount']?.toDouble() ?? 0.0,
      changeRequired: json['changeRequired']?.toDouble() ?? 0.0,
    );
  }
}

// UPI Payment Details
class UPIPaymentDetails {
  final String upiId;
  final String? payeeName;
  final String? qrCodeData;
  final String? referenceNumber;

  UPIPaymentDetails({
    required this.upiId,
    this.payeeName,
    this.qrCodeData,
    this.referenceNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'upiId': upiId,
      'payeeName': payeeName,
      'qrCodeData': qrCodeData,
      'referenceNumber': referenceNumber,
    };
  }

  factory UPIPaymentDetails.fromJson(Map<String, dynamic> json) {
    return UPIPaymentDetails(
      upiId: json['upiId'] ?? '',
      payeeName: json['payeeName'],
      qrCodeData: json['qrCodeData'],
      referenceNumber: json['referenceNumber'],
    );
  }
}

// Card Payment Details
class CardPaymentDetails {
  final String cardNumber; // Masked for security
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String? cardType; // Visa, Mastercard, etc.
  final String? authCode;
  final String? merchantId;

  CardPaymentDetails({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    this.cardType,
    this.authCode,
    this.merchantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardType': cardType,
      'authCode': authCode,
      'merchantId': merchantId,
    };
  }

  factory CardPaymentDetails.fromJson(Map<String, dynamic> json) {
    return CardPaymentDetails(
      cardNumber: json['cardNumber'] ?? '',
      cardHolderName: json['cardHolderName'] ?? '',
      expiryMonth: json['expiryMonth'] ?? '',
      expiryYear: json['expiryYear'] ?? '',
      cardType: json['cardType'],
      authCode: json['authCode'],
      merchantId: json['merchantId'],
    );
  }

  // Helper method to get masked card number for display
  String get maskedCardNumber {
    if (cardNumber.length >= 4) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }

  // Validate card number format (basic validation)
  bool get isValid {
    return cardNumber.isNotEmpty && 
           cardHolderName.isNotEmpty && 
           expiryMonth.isNotEmpty && 
           expiryYear.isNotEmpty &&
           cardNumber.replaceAll(' ', '').length >= 13;
  }
}

// Helper extensions
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.upi:
        return 'UPI Payment';
      case PaymentMethod.card:
        return 'Card Payment';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.cod:
        return 'Pay when your order is delivered';
      case PaymentMethod.upi:
        return 'Pay instantly using UPI apps like GPay, PhonePe, Paytm';
      case PaymentMethod.card:
        return 'Pay using Credit/Debit card';
    }
  }

  bool get requiresUpfrontPayment {
    switch (this) {
      case PaymentMethod.cod:
        return false;
      case PaymentMethod.upi:
      case PaymentMethod.card:
        return true;
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.processing:
        return 'Processing Payment';
      case PaymentStatus.completed:
        return 'Payment Successful';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Payment Refunded';
      case PaymentStatus.cancelled:
        return 'Payment Cancelled';
    }
  }

  bool get isSuccessful {
    return this == PaymentStatus.completed;
  }

  bool get isFailed {
    return this == PaymentStatus.failed || this == PaymentStatus.cancelled;
  }

  bool get isProcessing {
    return this == PaymentStatus.pending || this == PaymentStatus.processing;
  }
}