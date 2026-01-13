import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../../providers/cart_provider.dart';
import '../../config/keys.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late Razorpay _razorpay;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _couponController = TextEditingController();

  String _selectedPaymentMethod = 'Online'; // Online (Razorpay), COD
  bool _isProcessing = false;
  String? _currentOrderId;
  String? _currentOrderDbId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);

    try {
      debugPrint('=== PAYMENT SUCCESS ===');
      debugPrint('Order ID: ${response.orderId}');
      debugPrint('Payment ID: ${response.paymentId}');
      debugPrint('Signature: ${response.signature}');
      debugPrint('DB Order ID: $_currentOrderDbId');

      // Verify payment with backend
      final verifyRes = await http.post(
        Uri.parse('${AppKeys.backendBaseUrl}/api/payment/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'order_db_id': _currentOrderDbId,
        }),
      );

      debugPrint('Verification response status: ${verifyRes.statusCode}');
      debugPrint('Verification response body: ${verifyRes.body}');

      if (verifyRes.statusCode == 200) {
        final data = jsonDecode(verifyRes.body);
        if (data['verified'] == true) {
          _showSuccessAndNavigate('Payment successful! Order placed.');
        } else {
          _showError(
            'Payment verification failed: ${data['error'] ?? 'Unknown error'}',
          );
        }
      } else {
        final data = jsonDecode(verifyRes.body);
        _showError(
          'Payment verification failed: ${data['error'] ?? 'Status ${verifyRes.statusCode}'}',
        );
      }
    } catch (e) {
      debugPrint('Error in payment verification: $e');
      _showError('Error verifying payment: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    _showError('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet selected: ${response.walletName}');
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final amountPaise = (cartProvider.totalAmount * 100).toInt();

      if (amountPaise == 0) {
        _showError('Cart is empty');
        setState(() => _isProcessing = false);
        return;
      }

      // Prepare customer data
      final customerData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'shippingAddress': {
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          'country': _countryController.text.trim(),
        },
      };

      // Prepare items data
      final items = cartProvider.items
          .map(
            (item) => {
              'productId': item.product.id,
              'name': item.product.name,
              'quantity': item.quantity,
              'price': (item.product.price * 100).toInt(), // in paise
              'image': item.product.imageUrl,
            },
          )
          .toList();

      if (_selectedPaymentMethod == 'COD') {
        // Place COD order directly
        await _placeCODOrder(items, amountPaise, customerData);
      } else {
        // Create Razorpay order and open gateway
        await _createRazorpayOrder(items, amountPaise, customerData);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('Error placing order: $e');
    }
  }

  Future<void> _placeCODOrder(
    List<Map<String, dynamic>> items,
    int amountPaise,
    Map<String, dynamic> customerData,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('${AppKeys.backendBaseUrl}/api/payment/create-cod-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'items': items,
          'amount': amountPaise,
          'currency': 'INR',
          'customer': customerData,
          'paymentMethod': 'COD',
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Clear cart
        Provider.of<CartProvider>(context, listen: false).clear();
        _showSuccessAndNavigate(
          'Order placed successfully! Order ID: ${data['orderId']}',
        );
      } else {
        _showError('Failed to place COD order: ${res.body}');
      }
    } catch (e) {
      _showError('Error placing COD order: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _createRazorpayOrder(
    List<Map<String, dynamic>> items,
    int amountPaise,
    Map<String, dynamic> customerData,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('${AppKeys.backendBaseUrl}/api/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'items': items,
          'amount': amountPaise,
          'currency': 'INR',
          'customer': customerData,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception('Backend error: ${res.body}');
      }

      final data = jsonDecode(res.body);
      _currentOrderId = data['id'];
      _currentOrderDbId = data['order_db_id'];

      // Open Razorpay gateway with all payment options
      var options = {
        'key': AppKeys.razorpayKey,
        'order_id': _currentOrderId,
        'amount': amountPaise,
        'currency': 'INR',
        'name': 'KarmaShop',
        'description': 'Order Payment',
        'prefill': {
          'name': customerData['name'],
          'email': customerData['email'],
          'contact': customerData['phone'],
        },
        'theme': {'color': '#7C3AED'},
        // Don't restrict payment methods - let Razorpay show all options
      };

      _razorpay.open(options);
      setState(() => _isProcessing = false);
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('Error creating order: $e');
    }
  }

  void _showSuccessAndNavigate(String message) {
    // Clear cart
    Provider.of<CartProvider>(context, listen: false).clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate back to home or orders screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF7C3AED)),
                  SizedBox(height: 20),
                  Text(
                    'Processing your order...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    _buildSectionTitle('Order Summary'),
                    _buildOrderSummary(cartProvider),
                    const SizedBox(height: 24),

                    // Customer Details
                    _buildSectionTitle('Customer Details'),
                    _buildTextField(
                      'Full Name',
                      _nameController,
                      TextInputType.name,
                    ),
                    _buildTextField(
                      'Email',
                      _emailController,
                      TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      'Phone Number',
                      _phoneController,
                      TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    // Shipping Address
                    _buildSectionTitle('Shipping Address'),
                    _buildTextField(
                      'Address',
                      _addressController,
                      TextInputType.streetAddress,
                      maxLines: 3,
                    ),
                    _buildTextField(
                      'City',
                      _cityController,
                      TextInputType.text,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'State',
                            _stateController,
                            TextInputType.text,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            'Pincode',
                            _pincodeController,
                            TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      'Country',
                      _countryController,
                      TextInputType.text,
                    ),
                    const SizedBox(height: 24),

                    // Coupon Code
                    _buildSectionTitle('Coupon Code (Optional)'),
                    _buildCouponField(),
                    const SizedBox(height: 24),

                    // Payment Method
                    _buildSectionTitle('Payment Method'),
                    _buildPaymentMethods(),
                    const SizedBox(height: 32),

                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _selectedPaymentMethod == 'COD'
                              ? 'Place Order (₹${cartProvider.totalAmount.toStringAsFixed(2)})'
                              : 'Proceed to Payment (₹${cartProvider.totalAmount.toStringAsFixed(2)})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          ...cartProvider.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: const Color(0xFF334155),
                        child: const Icon(Icons.image, color: Colors.white30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${cartProvider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Email' && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          if (label == 'Phone Number' && value.length < 10) {
            return 'Please enter a valid phone number';
          }
          if (label == 'Pincode' && value.length != 6) {
            return 'Please enter a valid 6-digit pincode';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCouponField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _couponController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter coupon code',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF7C3AED),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement coupon validation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coupon feature coming soon!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF334155),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildPaymentOption(
          'Online',
          Icons.payment,
          'UPI, Cards, NetBanking, Wallets & More',
        ),
        _buildPaymentOption('COD', Icons.money, 'Cash on Delivery'),
      ],
    );
  }

  Widget _buildPaymentOption(String method, IconData icon, String subtitle) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C3AED).withOpacity(0.1)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF7C3AED)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF7C3AED),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
