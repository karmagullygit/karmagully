import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/keys.dart';

/// Lightweight Razorpay helper. Use this from places where you want to open checkout.
/// IMPORTANT: Only the Razorpay _key_ (publishable/test key) is used on the client.
/// Keep the Razorpay secret on your server and create orders there.
class RazorpayService {
  late Razorpay _razorpay;
  String? _currentOrderDbId;

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

    // Preferred: create order on your secure backend which uses the Razorpay secret.
    if (AppKeys.backendBaseUrl.isNotEmpty) {
      try {
        final created = await _createOrderOnBackend(amountInPaise);
        if (created != null && created['id'] != null) {
          usedOrderId = created['id'];
          _currentOrderDbId = created['order_db_id']?.toString();
        }
      } catch (e) {
        debugPrint('Failed to create order on backend: $e');
      }
    } else if (AppKeys.razorpaySecret.isNotEmpty) {
      // Fallback (local testing only): create order directly using secret (NOT for production)
      try {
        final created = await _createOrderViaSecret(amountInPaise);
        if (created != null && created['id'] != null) {
          usedOrderId = created['id'];
        }
      } catch (e) {
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

    // NOTE: This uses Basic auth with key_id:key_secret. We expect the secret to be the key_secret
    // and the key id must be provided via AppKeys.razorpayKey when using this method.
    final keyId = AppKeys.razorpayKey;
    final auth = base64Encode(utf8.encode('$keyId:$secret'));

    final resp = await http.post(uri, body: body, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $auth',
    });

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Order creation failed: ${resp.statusCode} ${resp.body}');
  }

  Future<Map<String, dynamic>?> _createOrderOnBackend(int amountInPaise) async {
    final base = AppKeys.backendBaseUrl;
    if (base.isEmpty) return null;

    final uri = Uri.parse(base).resolve('/api/payment/create-order');

    final body = json.encode({
      'items': [],
      'amount': amountInPaise,
      'currency': 'INR',
      'customer': {},
    });

    final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Backend order creation failed: ${resp.statusCode} ${resp.body}');
  }

  Future<bool> _verifyPaymentOnBackend({required String razorpayOrderId, required String razorpayPaymentId, required String razorpaySignature}) async {
    final base = AppKeys.backendBaseUrl;
    if (base.isEmpty) return false;
    final uri = Uri.parse(base).resolve('/api/payment/verify-payment');
    final body = json.encode({
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'order_db_id': _currentOrderDbId,
    });
    final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
    return resp.statusCode == 200;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Razorpay payment success: ${response.paymentId}');
    // If backend is configured, call verify endpoint to validate signature and mark order PAID
    if (AppKeys.backendBaseUrl.isNotEmpty) {
      () async {
        try {
          final ok = await _verifyPaymentOnBackend(
            razorpayOrderId: response.orderId ?? '',
            razorpayPaymentId: response.paymentId ?? '',
            razorpaySignature: response.signature ?? '',
          );
          if (ok) {
            debugPrint('Payment verified by backend');
          } else {
            debugPrint('Payment verification failed on backend');
          }
        } catch (e) {
          debugPrint('verify error: $e');
        }
      }();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Razorpay payment error: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay external wallet: ${response.walletName}');
  }
}
