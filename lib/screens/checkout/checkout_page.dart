import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../../config/keys.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items; // [{productId,name,quantity,price,image}]
  final String backendBaseUrl; // e.g. https://your-backend.example.com

  const CheckoutPage({super.key, required this.items, required this.backendBaseUrl});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  Razorpay? _razorpay;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  int calculateAmountPaise() {
    int total = 0;
    for (final it in widget.items) {
      final p = (it['price'] as num).toInt();
      final q = (it['quantity'] as num).toInt();
      total += p * q;
    }
    return total * 100; // paise
  }

  Future<void> _payNow() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final amountPaise = calculateAmountPaise();

    final body = {
      'items': widget.items,
      'amount': amountPaise,
      'currency': 'INR',
      'customer': {
        'name': _name.text,
        'email': _email.text,
        'phone': _phone.text,
      }
    };

    try {
      final res = await http.post(
        Uri.parse('${widget.backendBaseUrl}/api/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        throw Exception('Create order failed: ${res.body}');
      }

      final data = jsonDecode(res.body);
      final razorpayOrderId = data['id'];
      final orderDbId = data['order_db_id'];

      // Determine publishable key: prefer AppKeys, fall back to env var used previously
      final publishableKey = AppKeys.razorpayKey.isNotEmpty
          ? AppKeys.razorpayKey
          : const String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');

      if (publishableKey.isEmpty) {
        throw Exception('Razorpay publishable key not configured. Provide via --dart-define=RAZORPAY_KEY or set AppKeys.razorpayKey.');
      }

      final options = {
        'key': publishableKey,
        'amount': amountPaise,
        'currency': 'INR',
        'name': _name.text,
        'description': 'Karma Shop Order',
        'order_id': razorpayOrderId,
        'prefill': {'contact': _phone.text, 'email': _email.text},
        'theme': {'color': '#F37254'}
      };

      // Debug: log and show options before opening Razorpay checkout
      debugPrint('Razorpay publishableKey configured: ${publishableKey.isNotEmpty}');
      debugPrint('Razorpay options: $options');

      final proceed = await _showOptionsAndConfirm(options, publishableKey);
      if (!proceed) {
        setState(() => _loading = false);
        return;
      }

      try {
        _razorpay!.open(options);
      } catch (e) {
        debugPrint('Error opening Razorpay: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open payment gateway')));
      }

      // store orderDbId in state so verify can reference it
      // We'll capture payment success in handler and call verify endpoint
      _currentOrderDbId = orderDbId;
    } catch (err) {
      print('pay error $err');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment initiation failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  String? _currentOrderDbId;

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Send to backend for verification
    final payload = {
      'razorpay_order_id': response.orderId,
      'razorpay_payment_id': response.paymentId,
      'razorpay_signature': response.signature,
      'order_db_id': _currentOrderDbId
    };

    try {
      final base = widget.backendBaseUrl.isNotEmpty ? widget.backendBaseUrl : AppKeys.backendBaseUrl;
      final res = await http.post(
        Uri.parse('${base}/api/payment/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment verified and order placed')));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment verification failed')));
      }
    } catch (err) {
      print('verify error $err');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification error')));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: ${response.message}')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('External wallet: ${response.walletName}')));
  }

  Future<bool> _showOptionsAndConfirm(Map<String, dynamic> options, String publishableKey) async {
    final pretty = const JsonEncoder.withIndent('  ').convert(options);
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Razorpay Options (debug)'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Publishable key present: ${publishableKey.isNotEmpty}'),
                    const SizedBox(height: 8),
                    SelectableText(pretty),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Open Checkout')),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final amountPaise = calculateAmountPaise();
    final amountRs = (amountPaise / 100).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text('Items', style: Theme.of(context).textTheme.titleLarge),
                    ...widget.items.map((it) => ListTile(
                          leading: it['image'] != null ? Image.network(it['image'], width: 48, height: 48) : null,
                          title: Text(it['name'] ?? ''),
                          subtitle: Text('₹${it['price']} x ${it['quantity']}'),
                        )),
                    const SizedBox(height: 12),
                    TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'required' : null),
                    TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'required' : null),
                    TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'), validator: (v) => v!.isEmpty ? 'required' : null),
                  ],
                ),
              ),
            ),
            Text('Total: ₹$amountRs', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _payNow,
              child: _loading ? const CircularProgressIndicator() : const Text('Pay Now'),
            )
          ],
        ),
      ),
    );
  }
}
