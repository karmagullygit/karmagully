import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../config/keys.dart';

class MinimalCheckoutPage extends StatefulWidget {
  final String orderId;   // from backend
  final int amount;       // IN PAISE (e.g. 19999)

  const MinimalCheckoutPage({
    super.key,
    required this.orderId,
    required this.amount,
  });

  @override
  State<MinimalCheckoutPage> createState() => _MinimalCheckoutPageState();
}

class _MinimalCheckoutPageState extends State<MinimalCheckoutPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Using Future.delayed to ensure the widget is mounted before opening checkout
    Future.delayed(const Duration(milliseconds: 500), () {
      openCheckout();
    });
  }

  void openCheckout() {
    var options = {
      'key': AppKeys.razorpayKey, // 🟢 Using your real key
      'order_id': widget.orderId,   // 🟢 From backend
      'amount': widget.amount,      // 🟢 In paise
      'currency': 'INR',
      'name': 'KarmaShop Test',
      'description': 'Minimal Test Checkout',
      'retry': {'enabled': true, 'max_count': 1},
      'prefill': {
        'email': 'test@karmagully.com',
        'contact': '9999999999',
      },
      'theme': {
        'color': '#7C4DFF',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    debugPrint('SUCCESS: ${response.paymentId}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}')),
    );
  }

  void _handleError(PaymentFailureResponse response) {
    debugPrint('ERROR: ${response.code} | ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('WALLET: ${response.walletName}');
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minimal Razorpay Test')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Opening Razorpay Checkout...'),
          ],
        ),
      ),
    );
  }
}
