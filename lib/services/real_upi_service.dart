import '../models/payment_method.dart';

class RealUPIService {
  // Your Demo Merchant UPI ID (replace with your real one for production)
  static const String merchantUPI = "demo@karmashop"; // Change this to your real UPI ID
  static const String merchantName = "KarmaShop Demo";
  
  /// Launch UPI apps with payment request using intent
  static Future<Map<String, dynamic>> launchUPIPayment({
    required String app,
    required double amount,
    required String orderId,
    String? note,
    String? customerUPIId,
  }) async {
    try {
      // For demo, we'll simulate opening apps without actual intent
      print('🔥 DEMO MODE: Would open $app with payment details:');
      print('   💰 Amount: ₹$amount');
      print('   🏪 Merchant: $merchantName ($merchantUPI)');
      print('   📝 Order ID: $orderId');
      print('   📄 Note: ${note ?? 'Payment for KarmaShop Order'}');
      
      // Simulate delay as if app is opening
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, return a simulated response
      // In real implementation, this would open the actual UPI app
      return _simulateUPIResponse(app, amount, orderId);
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to launch $app: $e',
        'transactionId': null,
      };
    }
  }
  
  /// Simulate UPI app response for demo
  static Map<String, dynamic> _simulateUPIResponse(String app, double amount, String orderId) {
    // 90% success rate for demo
    final isSuccess = (DateTime.now().millisecondsSinceEpoch % 10) < 9;
    
    if (isSuccess) {
      final txnId = '${app.toUpperCase()}${DateTime.now().millisecondsSinceEpoch}';
      return {
        'success': true,
        'transactionId': txnId,
        'responseCode': 'Success',
        'status': 'SUCCESS',
        'amount': amount,
        'orderId': orderId,
        'payerVPA': 'customer@${app.toLowerCase()}',
        'payeeVPA': merchantUPI,
        'message': 'Payment completed successfully via $app',
        'app': app,
      };
    } else {
      return {
        'success': false,
        'error': _getRandomUPIError(),
        'transactionId': null,
        'responseCode': 'Failure',
        'status': 'FAILED',
        'message': 'Payment failed. Please try again.',
        'app': app,
      };
    }
  }
  
  /// Get available UPI apps (demo list)
  static List<UPIApp> getAvailableUPIApps() {
    return [
      UPIApp(
        name: 'PhonePe',
        packageName: 'com.phonepe.app',
        icon: '📱',
        color: '#5F259F',
        isInstalled: true, // Assume installed for demo
      ),
      UPIApp(
        name: 'Google Pay',
        packageName: 'com.google.android.apps.nbu.paisa.user',
        icon: '🎨',
        color: '#4285F4',
        isInstalled: true,
      ),
      UPIApp(
        name: 'Paytm',
        packageName: 'net.one97.paytm',
        icon: '💙',
        color: '#00BAF2',
        isInstalled: true,
      ),
      UPIApp(
        name: 'BHIM',
        packageName: 'in.org.npci.upiapp',
        icon: '🏛️',
        color: '#FF6B35',
        isInstalled: true,
      ),
      UPIApp(
        name: 'Amazon Pay',
        packageName: 'in.amazon.mShop.android.shopping',
        icon: '📦',
        color: '#FF9900',
        isInstalled: true,
      ),
    ];
  }
  
  /// Build UPI payment URL for web/fallback
  static String buildUPIURL({
    required double amount,
    required String orderId,
    String? note,
  }) {
    final encodedNote = Uri.encodeComponent(note ?? 'Payment for KarmaShop Order');
    return 'upi://pay?pa=$merchantUPI&pn=${Uri.encodeComponent(merchantName)}&am=$amount&tr=$orderId&tn=$encodedNote&cu=INR';
  }
  
  /// Process UPI payment result
  static PaymentResult processUPIResult(Map<String, dynamic> upiResult) {
    if (upiResult['success'] == true) {
      return PaymentResult(
        isSuccess: true,
        transactionId: upiResult['transactionId'],
        status: PaymentStatus.completed,
        message: upiResult['message'] ?? 'UPI payment successful!',
        processedAt: DateTime.now(),
        gatewayResponse: {
          'upi_app': upiResult['app'],
          'payer_vpa': upiResult['payerVPA'],
          'payee_vpa': upiResult['payeeVPA'],
          'transaction_ref': upiResult['transactionId'],
          'response_code': upiResult['responseCode'],
          'status': upiResult['status'],
        },
      );
    } else {
      return PaymentResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        message: upiResult['message'] ?? 'UPI payment failed',
        failureReason: upiResult['error'],
        gatewayResponse: {
          'upi_app': upiResult['app'],
          'response_code': upiResult['responseCode'],
          'status': upiResult['status'],
          'error': upiResult['error'],
        },
      );
    }
  }
  
  static String _getRandomUPIError() {
    final errors = [
      'Transaction cancelled by user',
      'Insufficient balance in account',
      'Bank server temporarily unavailable',
      'UPI PIN limit exceeded',
      'Network connectivity issue',
      'Payment app temporarily unavailable',
      'Transaction timeout',
      'Invalid UPI PIN entered',
    ];
    return errors[DateTime.now().millisecondsSinceEpoch % errors.length];
  }
}

class UPIApp {
  final String name;
  final String packageName;
  final String icon;
  final String color;
  final bool isInstalled;

  UPIApp({
    required this.name,
    required this.packageName,
    required this.icon,
    required this.color,
    this.isInstalled = false,
  });

  @override
  String toString() => name;
}

// Add this to your existing PaymentResult class (if not already present)
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
}