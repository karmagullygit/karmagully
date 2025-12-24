import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/keys.dart';

/// Lightweight Razorpay helper. Use this from places where you want to open checkout.
/// IMPORTANT: Only the Razorpay _key_ (publishable/test key) is used on the client.
/// Keep the Razorpay secret on your server and create orders there.
class RazorpayService {
  late Razorpay _razorpay;

  void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> openCheckout({
    required double amountInRupees,
    String? orderId,
    String customerName = '',
    String customerEmail = '',
    String customerContact = '',
  }) async {
    final int amountInPaise = (amountInRupees * 100).round();
    String? usedOrderId = orderId;

    // If a secret key is available (for local testing only), create the order via Razorpay REST API.
    if ((AppKeys.razorpaySecret ?? '').isNotEmpty) {
      try {
        final created = await _createOrderViaSecret(amountInPaise);
        if (created != null && created['id'] != null) {
          usedOrderId = created['id'];
        }
      } catch (e) {
        // Fall back to client-only checkout without server-created order
        debugPrint('Failed to create order via secret: $e');
      }
    }

    final options = {
      'key': AppKeys.razorpayKey,
      'amount': amountInPaise,
      'name': 'KarmaGully',
      'description': 'Order: ${usedOrderId ?? ''}',
      'prefill': {'contact': customerContact, 'email': customerEmail},
      'theme': {'color': '#F37021'},
    };

    if (usedOrderId != null && usedOrderId.isNotEmpty) {
      options['order_id'] = usedOrderId;
    }

    try {
      _razorpay.open(options);
    } on PlatformException catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _createOrderViaSecret(int amountInPaise) async {
    final secret = AppKeys.razorpaySecret;
    if (secret.isEmpty) return null;

    final uri = Uri.parse('https://api.razorpay.com/v1/orders');
    final body = json.encode({
      'amount': amountInPaise,
      'currency': 'INR',
      'receipt': 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
      'payment_capture': 1,
    });

    final auth = base64Encode(utf8.encode('$secret:'));

    final resp = await http.post(uri, body: body, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $auth',
    });

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Order creation failed: ${resp.statusCode} ${resp.body}');
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Notify backend to verify signature using secret key.
    print('Razorpay payment success: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Razorpay payment error: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('Razorpay external wallet: ${response.walletName}');
  }
}
