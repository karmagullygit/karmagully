import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/user_address.dart';
import '../../models/payment_method.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/coupon.dart';
import '../../widgets/payment_method_selector.dart';
import '../../widgets/order_notification_dialog.dart';
import '../../services/payment_service.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _couponController = TextEditingController();

  bool _useProfileInfo = true;
  bool _isPlacingOrder = false;
  Coupon? _appliedCoupon;
  bool _isApplyingCoupon = false;
  String? _selectedAddressId;
  PaymentMethod? _selectedPaymentMethod;
  Map<String, dynamic>? _paymentDetails;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null && _useProfileInfo) {
      _nameController.text = authProvider.currentUser!.name;
      _emailController.text = authProvider.currentUser!.email;
      _phoneController.text = authProvider.currentUser!.phone;
    }
  }

  // Validate phone number based on country
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    
    final phone = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final country = _countryController.text.trim().toLowerCase();
    
    if (country == 'india' || country == 'ind' || country == 'in') {
      final indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');
      if (!indianPhoneRegex.hasMatch(phone)) {
        return 'Enter valid 10-digit Indian phone (starts with 6-9)';
      }
    } else if (country.contains('usa') || country.contains('united states') || country == 'us') {
      final usPhoneRegex = RegExp(r'^\d{10}$');
      if (!usPhoneRegex.hasMatch(phone)) {
        return 'Enter valid 10-digit US phone number';
      }
    } else if (country.contains('uk') || country.contains('united kingdom') || country.contains('britain')) {
      if (phone.length < 10 || phone.length > 11 || !RegExp(r'^\d+$').hasMatch(phone)) {
        return 'Enter valid UK phone (10-11 digits)';
      }
    } else {
      final generalPhoneRegex = RegExp(r'^\+?\d{7,15}$');
      if (!generalPhoneRegex.hasMatch(phone)) {
        return 'Enter valid phone number (7-15 digits)';
      }
    }
    
    return null;
  }

  // Validate postal code based on country
  String? _validatePinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter postal code';
    }
    
    final postalCode = value.trim();
    final country = _countryController.text.trim().toLowerCase();
    
    if (country == 'india' || country == 'ind' || country == 'in') {
      final indianPinRegex = RegExp(r'^\d{6}$');
      if (!indianPinRegex.hasMatch(postalCode)) {
        return 'Enter valid 6-digit PIN code';
      }
    } else if (country.contains('usa') || country.contains('united states') || country == 'us') {
      final usZipRegex = RegExp(r'^\d{5}(-\d{4})?$');
      if (!usZipRegex.hasMatch(postalCode)) {
        return 'Enter valid US ZIP (12345 or 12345-6789)';
      }
    } else if (country.contains('uk') || country.contains('united kingdom') || country.contains('britain')) {
      final ukPostcodeRegex = RegExp(r'^[A-Z]{1,2}\d{1,2}[A-Z]?\s?\d[A-Z]{2}$', caseSensitive: false);
      if (!ukPostcodeRegex.hasMatch(postalCode)) {
        return 'Enter valid UK postcode';
      }
    } else if (country.contains('canada') || country == 'ca') {
      final canadaPostalRegex = RegExp(r'^[A-Z]\d[A-Z]\s?\d[A-Z]\d$', caseSensitive: false);
      if (!canadaPostalRegex.hasMatch(postalCode)) {
        return 'Enter valid Canadian postal code (A1A 1A1)';
      }
    } else {
      if (postalCode.length < 3 || postalCode.length > 10) {
        return 'Enter valid postal code (3-10 characters)';
      }
    }
    
    return null;
  }

  // Indian states for validation
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  // Validate state based on country
  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter state/province';
    }
    
    final state = value.trim();
    final country = _countryController.text.trim().toLowerCase();
    
    if (country == 'india' || country == 'ind' || country == 'in') {
      final isValidIndianState = _indianStates.any(
        (s) => s.toLowerCase() == state.toLowerCase()
      );
      
      if (!isValidIndianState) {
        return 'Enter valid Indian state/UT';
      }
    } else if (state.length < 2) {
      return 'State name too short';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for button
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              _buildOrderSummary(),
              const SizedBox(height: 24),
              
              // COUPON SECTION - Highly Visible
              _buildCouponSection(),
              const SizedBox(height: 24),
              
              // Customer Information
              _buildCustomerInfo(),
              const SizedBox(height: 24),
              
              // Delivery Address
              _buildDeliveryAddress(),
              const SizedBox(height: 24),
              
              // Payment Method Selection
              _buildPaymentMethodSelector(),
              const SizedBox(height: 32),
              
              // Place Order Button
              _buildPlaceOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final subtotal = cartProvider.totalAmount;
        final discount = _appliedCoupon?.calculateDiscount(subtotal) ?? 0.0;
        final total = subtotal - discount;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...cartProvider.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${item.product.name} x${item.quantity}'),
                      ),
                      Text('₹${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  children: [
                    const Expanded(child: Text('Subtotal:')),
                    Text('₹${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                if (_appliedCoupon != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Discount (${_appliedCoupon!.code}):',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                      Text(
                        '-₹${discount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCouponSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        border: Border.all(color: Colors.orange, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text(
                'APPLY COUPON CODE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_appliedCoupon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coupon "${_appliedCoupon!.code}" applied successfully!',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _appliedCoupon = null;
                        _couponController.clear();
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code (e.g., WELCOME20)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.local_offer, color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isApplyingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: _isApplyingCoupon
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('APPLY'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Coupons:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text('• WELCOME20 - 20% off on all items'),
                  const Text('• SAVE50 - ₹50 off on orders above ₹500'),
                  const Text('• ELECTRONICS25 - 25% off on electronics'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Use profile information'),
              value: _useProfileInfo,
              onChanged: (value) {
                setState(() {
                  _useProfileInfo = value ?? false;
                  if (_useProfileInfo) {
                    _loadUserInfo();
                  } else {
                    _nameController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\s\(\)]')),
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: '10-digit number',
                border: OutlineInputBorder(),
              ),
              validator: _validatePhoneNumber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Saved addresses selector
            Consumer2<AddressProvider, AuthProvider>(
              builder: (context, addressProvider, authProvider, child) {
                final userId = authProvider.currentUser?.id ?? '';
                final addresses = addressProvider.getAddressesByUserId(userId);

                if (addresses.isEmpty) {
                  // load sample addresses for demo purposes (non-destructive)
                  // don't force in production; only load if none exist
                  addressProvider.loadSampleAddresses(userId);
                }

                return Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: addresses.isEmpty ? null : () => _showAddressSelectionDialog(addresses),
                      icon: const Icon(Icons.location_on),
                      label: const Text('Select Saved Address'),
                    ),
                    const SizedBox(width: 12),
                    if (_selectedAddressId != null)
                      Expanded(
                        child: FutureBuilder<UserAddress?>(
                          future: Future.value(addressProvider.getAddressById(_selectedAddressId!)),
                          builder: (context, snap) {
                            final a = snap.data;
                            if (a == null) return const SizedBox.shrink();
                            return Text(
                              '${a.label} • ${a.fullAddress}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'State *',
                      hintText: 'e.g., Maharashtra',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateState,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      labelText: _countryController.text.toLowerCase().contains('india')
                          ? 'PIN Code *'
                          : 'Postal Code *',
                      hintText: _countryController.text.toLowerCase().contains('india')
                          ? '6-digit PIN'
                          : 'Postal code',
                      border: const OutlineInputBorder(),
                    ),
                    validator: _validatePinCode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Country *',
                      hintText: 'e.g., India',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (value.trim().length < 2) {
                        return 'Invalid';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {}); // Refresh hints and labels
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final subtotal = cartProvider.totalAmount;
        final discount = _appliedCoupon?.calculateDiscount(subtotal) ?? 0.0;
        final total = subtotal - discount;

        return PaymentMethodSelector(
          selectedMethod: _selectedPaymentMethod,
          orderAmount: total,
          onPaymentMethodChanged: (method, details) {
            setState(() {
              _selectedPaymentMethod = method;
              _paymentDetails = details;
            });
          },
        );
      },
    );
  }

  Widget _buildPlaceOrderButton() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final subtotal = cartProvider.totalAmount;
        final discount = _appliedCoupon?.calculateDiscount(subtotal) ?? 0.0;
        final total = subtotal - discount;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isPlacingOrder ? null : () => _placeOrder(total),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isPlacingOrder
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Placing Order...'),
                    ],
                  )
                : Text(
                    'Place Order - ₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  void _applyCoupon() async {
    final couponCode = _couponController.text.trim().toUpperCase();
    if (couponCode.isEmpty) {
      _showSnackBar('Please enter a coupon code', Colors.red);
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
    });

    try {
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final result = await couponProvider.applyCoupon(couponCode, cartProvider.items, authProvider.currentUser?.id);
      
      if (result == null) {
        // Success
        setState(() {
          _appliedCoupon = couponProvider.appliedCoupon;
        });
        final discount = _appliedCoupon!.calculateDiscount(cartProvider.totalAmount);
        _showSnackBar('Coupon applied! You saved ₹${discount.toStringAsFixed(2)}', Colors.green);
      } else {
        _showSnackBar(result, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error applying coupon: $e', Colors.red);
    } finally {
      setState(() {
        _isApplyingCoupon = false;
      });
    }
  }

  void _placeOrder(double total) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate payment method selection
    if (_selectedPaymentMethod == null) {
      _showSnackBar('Please select a payment method', Colors.red);
      return;
    }

    // Additional payment method validation
    if (_selectedPaymentMethod == PaymentMethod.upi && _paymentDetails == null) {
      _showSnackBar('Please enter UPI details', Colors.red);
      return;
    }
    
    if (_selectedPaymentMethod == PaymentMethod.card && _paymentDetails == null) {
      _showSnackBar('Please enter card details', Colors.red);
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (cartProvider.items.isEmpty) {
        _showSnackBar('Your cart is empty', Colors.red);
        return;
      }

      final address = UserAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authProvider.currentUser?.id ?? '',
        label: 'Delivery Address',
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine1: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _zipController.text.trim(),
        country: 'India',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create payment info
      PaymentInfo? paymentInfo;
      String? orderId;
      
      if (_selectedPaymentMethod != null) {
        // Process payment first
        final paymentService = PaymentService();
        final paymentResult = await paymentService.processPayment(
          method: _selectedPaymentMethod!,
          amount: total,
          details: _paymentDetails,
        );

        paymentInfo = paymentResult.toPaymentInfo(_selectedPaymentMethod!, _paymentDetails);

        // Show payment processing feedback
        if (paymentResult.isSuccess) {
          _showSnackBar(paymentResult.message, Colors.green);
          
          // Create order with successful payment info
          orderId = await orderProvider.placeOrder(
            user: authProvider.currentUser!,
            cartItems: cartProvider.items,
            shippingAddress: address.fullAddress,
            paymentInfo: paymentInfo,
          );

          // Get the placed order
          final placedOrder = orderProvider.getOrderById(orderId);

          // Clear cart after successful order
          cartProvider.clear();

          // Show WhatsApp notification dialog
          if (placedOrder != null && mounted) {
            OrderNotificationDialog.show(context, placedOrder, isAdmin: false);
          }

          // Navigate to order success screen with loading transition
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => _OrderLoadingScreen(orderId: orderId!),
            ),
          );
          return;
        } else {
          // Payment failed
          _showSnackBar(paymentResult.message, Colors.red);
          if (paymentResult.failureReason != null) {
            _showSnackBar('Reason: ${paymentResult.failureReason}', Colors.orange);
          }
          return;
        }
      } else {
        // Fallback - shouldn't reach here due to validation
        _showSnackBar('Payment method not selected', Colors.red);
        return;
      }
      
    } catch (e) {
      _showSnackBar('Error placing order: $e', Colors.red);
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAddressSelectionDialog(List<UserAddress> addresses) {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final presetAddresses = addressProvider.presetAddresses;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Delivery Address'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Address Options
                if (presetAddresses.isNotEmpty) ...[
                  const Text(
                    'Quick Address Options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...presetAddresses.map((preset) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.flash_on, color: Colors.orange),
                      title: Text(preset.label),
                      subtitle: Text('${preset.addressLine1}, ${preset.city}'),
                      onTap: () async {
                        // Add preset as a temporary saved address for this user so it's selectable later
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                        final userId = authProvider.currentUser?.id ?? '';

                        if (userId.isNotEmpty) {
                          final newId = await addressProvider.addPresetAddress(userId: userId, presetId: preset.id, isDefault: false);
                          final newAddress = addressProvider.getAddressById(newId);
                          if (newAddress != null) {
                            setState(() {
                              _selectedAddressId = newId;
                              _nameController.text = newAddress.fullName;
                              _phoneController.text = newAddress.phone;
                              _addressController.text = newAddress.addressLine1 + 
                                  (newAddress.addressLine2.isNotEmpty ? '\n${newAddress.addressLine2}' : '');
                              _cityController.text = newAddress.city;
                              _stateController.text = newAddress.state;
                              _zipController.text = newAddress.postalCode;
                            });
                          }
                        } else {
                          // If not logged in, just populate fields without saving
                          setState(() {
                            _selectedAddressId = null;
                            _nameController.text = preset.fullName;
                            _phoneController.text = preset.phone;
                            _addressController.text = preset.addressLine1 + 
                                (preset.addressLine2.isNotEmpty ? '\n${preset.addressLine2}' : '');
                            _cityController.text = preset.city;
                            _stateController.text = preset.state;
                            _zipController.text = preset.postalCode;
                          });
                        }

                        Navigator.of(context).pop();
                      },
                    ),
                  )),
                  const Divider(height: 24),
                ],
                
                // Saved Addresses
                if (addresses.isNotEmpty) ...[
                  const Text(
                    'Saved Addresses',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...addresses.map((address) => ListTile(
                    title: Text(address.label),
                    subtitle: Text(address.fullAddress),
                    trailing: address.isDefault ? const Chip(
                      label: Text('Default', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ) : null,
                    onTap: () {
                      setState(() {
                        _selectedAddressId = address.id;
                        _nameController.text = address.fullName;
                        _phoneController.text = address.phone;
                        _addressController.text = address.addressLine1 + 
                          (address.addressLine2.isNotEmpty ? '\n${address.addressLine2}' : '');
                        _cityController.text = address.city;
                        _stateController.text = address.state;
                        _zipController.text = address.postalCode;
                      });
                      Navigator.of(context).pop();
                    },
                  )),
                ] else ...[
                  const Text(
                    'No saved addresses found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _couponController.dispose();
    super.dispose();
  }
}

class _OrderLoadingScreen extends StatefulWidget {
  final String orderId;

  const _OrderLoadingScreen({required this.orderId});

  @override
  State<_OrderLoadingScreen> createState() => _OrderLoadingScreenState();
}

class _OrderLoadingScreenState extends State<_OrderLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Navigate to success screen after loading
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(orderId: widget.orderId),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2.0 * 3.14159,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Processing your order...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}