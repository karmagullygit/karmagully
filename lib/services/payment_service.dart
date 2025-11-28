import 'dart:math';
import '../models/payment_method.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Simulate payment processing for different methods
  Future<PaymentResult> processPayment({
    required PaymentMethod method,
    required double amount,
    required Map<String, dynamic>? details,
  }) async {
    print('🔄 Processing ${method.displayName} payment for ₹$amount');
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    switch (method) {
      case PaymentMethod.cod:
        return _processCODPayment(amount, details);
      case PaymentMethod.upi:
        return _processUPIPayment(amount, details);
      case PaymentMethod.card:
        return _processCardPayment(amount, details);
    }
  }

  Future<PaymentResult> _processCODPayment(double amount, Map<String, dynamic>? details) async {
    // COD is always successful since payment happens on delivery
    return PaymentResult(
      isSuccess: true,
      transactionId: 'COD_${DateTime.now().millisecondsSinceEpoch}',
      status: PaymentStatus.completed,
      message: 'Cash on Delivery confirmed. Pay when your order arrives.',
      processedAt: DateTime.now(),
    );
  }

  Future<PaymentResult> _processUPIPayment(double amount, Map<String, dynamic>? details) async {
    if (details == null) {
      return PaymentResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        message: 'UPI details missing',
        failureReason: 'No UPI ID provided',
      );
    }

    final upiId = details['upiId'] as String?;
    if (upiId == null || !upiId.contains('@')) {
      return PaymentResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        message: 'Invalid UPI ID format',
        failureReason: 'UPI ID must contain @ symbol',
      );
    }

    // Simulate UPI payment process
    print('📱 Processing UPI payment to $upiId');
    
    // Simulate success/failure (90% success rate for demo)
    final random = Random();
    final isSuccessful = random.nextDouble() > 0.1; // 90% success rate
    
    if (isSuccessful) {
      final transactionId = 'UPI_${random.nextInt(999999999).toString().padLeft(9, '0')}';
      return PaymentResult(
        isSuccess: true,
        transactionId: transactionId,
        status: PaymentStatus.completed,
        message: 'UPI payment successful! Transaction ID: $transactionId',
        processedAt: DateTime.now(),
        gatewayResponse: {
          'upi_ref': transactionId,
          'vpa': upiId,
          'amount': amount,
          'status': 'SUCCESS',
        },
      );
    } else {
      return PaymentResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        message: 'UPI payment failed. Please try again or use a different payment method.',
        failureReason: _getRandomUPIFailureReason(),
      );
    }
  }

  Future<PaymentResult> _processCardPayment(double amount, Map<String, dynamic>? details) async {
    if (details == null) {
      return PaymentResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        message: 'Card details missing',
        failureReason: 'No card information provided',
      );
    }

    final cardNumber = details['cardNumber'] as String?;
    final cardHolderName = details['cardHolderName'] as String?;
    
    if (cardNumber == null || cardHolderName == null) {
      return PaymentResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        message: 'Incomplete card details',
        failureReason: 'Card number and holder name required',
      );
    }

    // Simulate card payment process
    print('💳 Processing card payment for $cardHolderName');
    
    // Simulate success/failure (85% success rate for demo)
    final random = Random();
    final isSuccessful = random.nextDouble() > 0.15; // 85% success rate
    
    if (isSuccessful) {
      final transactionId = 'CARD_${random.nextInt(999999999).toString().padLeft(9, '0')}';
      final authCode = random.nextInt(999999).toString().padLeft(6, '0');
      
      return PaymentResult(
        isSuccess: true,
        transactionId: transactionId,
        status: PaymentStatus.completed,
        message: 'Card payment successful! Transaction ID: $transactionId',
        processedAt: DateTime.now(),
        gatewayResponse: {
          'txn_id': transactionId,
          'auth_code': authCode,
          'card_type': details['cardType'] ?? 'Unknown',
          'amount': amount,
          'status': 'APPROVED',
        },
      );
    } else {
      return PaymentResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        message: 'Card payment failed. Please check your card details and try again.',
        failureReason: _getRandomCardFailureReason(),
      );
    }
  }

  String _getRandomUPIFailureReason() {
    final reasons = [
      'Transaction timed out',
      'Insufficient balance',
      'UPI service unavailable',
      'Invalid UPI PIN',
      'Transaction declined by bank',
    ];
    return reasons[Random().nextInt(reasons.length)];
  }

  String _getRandomCardFailureReason() {
    final reasons = [
      'Card declined by bank',
      'Insufficient funds',
      'Invalid CVV',
      'Card expired',
      'Transaction limit exceeded',
      'Network error',
    ];
    return reasons[Random().nextInt(reasons.length)];
  }

  // Verify payment status (useful for pending payments)
  Future<PaymentResult> verifyPayment(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For demo, assume most payments can be verified successfully
    final random = Random();
    final isVerified = random.nextDouble() > 0.2; // 80% verification success
    
    if (isVerified) {
      return PaymentResult(
        isSuccess: true,
        transactionId: transactionId,
        status: PaymentStatus.completed,
        message: 'Payment verified successfully',
        processedAt: DateTime.now(),
      );
    } else {
      return PaymentResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        message: 'Payment verification failed',
        failureReason: 'Unable to verify payment status',
      );
    }
  }

  // Refund payment (for order cancellations)
  Future<PaymentResult> refundPayment({
    required String originalTransactionId,
    required double refundAmount,
    required PaymentMethod originalMethod,
  }) async {
    print('💰 Processing refund for $originalTransactionId');
    await Future.delayed(const Duration(seconds: 1));

    if (originalMethod == PaymentMethod.cod) {
      return PaymentResult(
        isSuccess: true,
        transactionId: 'REF_COD_${DateTime.now().millisecondsSinceEpoch}',
        status: PaymentStatus.refunded,
        message: 'COD order cancelled successfully. No refund needed.',
        processedAt: DateTime.now(),
      );
    }

    final refundId = 'REF_${DateTime.now().millisecondsSinceEpoch}';
    return PaymentResult(
      isSuccess: true,
      transactionId: refundId,
      status: PaymentStatus.refunded,
      message: 'Refund processed successfully. Amount: ₹${refundAmount.toStringAsFixed(2)}',
      processedAt: DateTime.now(),
      gatewayResponse: {
        'refund_id': refundId,
        'original_txn': originalTransactionId,
        'refund_amount': refundAmount,
        'status': 'REFUNDED',
      },
    );
  }
}

class PaymentResult {
  final bool isSuccess;
  final String? transactionId;
  final PaymentStatus status;
  final String message;
  final String? failureReason;
  final DateTime? processedAt;
  final Map<String, dynamic>? gatewayResponse;

  PaymentResult({
    required this.isSuccess,
    this.transactionId,
    required this.status,
    required this.message,
    this.failureReason,
    this.processedAt,
    this.gatewayResponse,
  });

  PaymentInfo toPaymentInfo(PaymentMethod method, Map<String, dynamic>? details) {
    return PaymentInfo(
      method: method,
      status: status,
      transactionId: transactionId,
      processedAt: processedAt,
      details: {
        ...?details,
        'gateway_response': gatewayResponse,
        'result_message': message,
        if (failureReason != null) 'failure_reason': failureReason,
      },
      failureReason: failureReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'transactionId': transactionId,
      'status': status.name,
      'message': message,
      'failureReason': failureReason,
      'processedAt': processedAt?.toIso8601String(),
      'gatewayResponse': gatewayResponse,
    };
  }
}