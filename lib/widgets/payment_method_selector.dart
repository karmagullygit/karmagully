import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_method.dart';
import 'upi_app_selector.dart';

class PaymentMethodSelector extends StatefulWidget {
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod method, Map<String, dynamic>? details) onPaymentMethodChanged;
  final double orderAmount;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onPaymentMethodChanged,
    required this.orderAmount,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  PaymentMethod? _selectedMethod;
  final _formKey = GlobalKey<FormState>();
  
  // UPI Controllers
  final _upiController = TextEditingController();
  
  // Card Controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  
  // COD Controllers
  final _cashAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
    _cashAmountController.text = widget.orderAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _cashAmountController.dispose();
    super.dispose();
  }

  void _onPaymentMethodChanged(PaymentMethod method) {
    setState(() {
      _selectedMethod = method;
    });

    Map<String, dynamic>? details;
    
    switch (method) {
      case PaymentMethod.cod:
        details = CODPaymentDetails(
          isConfirmed: true,
          cashAmount: double.tryParse(_cashAmountController.text) ?? widget.orderAmount,
          changeRequired: (double.tryParse(_cashAmountController.text) ?? widget.orderAmount) - widget.orderAmount,
          instructions: 'Please keep exact change ready for faster delivery',
        ).toJson();
        break;
      case PaymentMethod.upi:
        if (_upiController.text.isNotEmpty) {
          details = UPIPaymentDetails(
            upiId: _upiController.text,
            payeeName: 'KarmaShop',
          ).toJson();
        }
        break;
      case PaymentMethod.card:
        if (_cardNumberController.text.isNotEmpty && _cardHolderController.text.isNotEmpty) {
          details = CardPaymentDetails(
            cardNumber: _maskCardNumber(_cardNumberController.text),
            cardHolderName: _cardHolderController.text,
            expiryMonth: _expiryMonthController.text,
            expiryYear: _expiryYearController.text,
            cardType: _getCardType(_cardNumberController.text),
          ).toJson();
        }
        break;
    }

    widget.onPaymentMethodChanged(method, details);
  }

  String _maskCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.length >= 4) {
      return '**** **** **** ${cleanNumber.substring(cleanNumber.length - 4)}';
    }
    return cleanNumber;
  }

  String? _getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) {
      return 'Mastercard';
    } else if (cleanNumber.startsWith('3')) {
      return 'Amex';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // COD Option
              _buildPaymentOption(
                method: PaymentMethod.cod,
                icon: Icons.money,
                color: Colors.green,
              ),
              
              if (_selectedMethod == PaymentMethod.cod)
                _buildCODDetails(),
              
              const SizedBox(height: 12),
              
              // UPI Option
              _buildPaymentOption(
                method: PaymentMethod.upi,
                icon: Icons.qr_code,
                color: Colors.blue,
              ),
              
              if (_selectedMethod == PaymentMethod.upi)
                _buildUPIDetails(),
              
              const SizedBox(height: 12),
              
              // Card Option
              _buildPaymentOption(
                method: PaymentMethod.card,
                icon: Icons.credit_card,
                color: Colors.purple,
              ),
              
              if (_selectedMethod == PaymentMethod.card)
                _buildCardDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedMethod == method ? color : Colors.grey.shade300,
          width: _selectedMethod == method ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: _selectedMethod == method ? color.withOpacity(0.1) : null,
      ),
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: _selectedMethod,
        onChanged: (PaymentMethod? value) {
          if (value != null) {
            _onPaymentMethodChanged(value);
          }
        },
        title: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        activeColor: color,
      ),
    );
  }

  Widget _buildCODDetails() {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cash Payment Details',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cashAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cash Amount (₹)',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter cash amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount < widget.orderAmount) {
                      return 'Amount must be at least ₹${widget.orderAmount}';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _onPaymentMethodChanged(PaymentMethod.cod);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Change Required:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '₹${((double.tryParse(_cashAmountController.text) ?? widget.orderAmount) - widget.orderAmount).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Please keep exact change ready for faster delivery',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUPIDetails() {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UPI Payment - Choose Your App',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          
          // UPI App Selector
          UPIAppSelector(
            amount: widget.orderAmount,
            orderId: 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
            onAppSelected: (app) {
              // Update payment details when app is selected
              _onPaymentMethodChanged(PaymentMethod.upi);
            },
          ),
          
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          
          // Manual UPI ID Entry (Alternative)
          const Text(
            'Or enter UPI ID manually:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _upiController,
            decoration: const InputDecoration(
              labelText: 'UPI ID (Optional)',
              hintText: 'yourname@paytm / yourname@gpay',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance_wallet),
            ),
            validator: (value) {
              // UPI ID is now optional since we have app selector
              if (value != null && value.isNotEmpty && !value.contains('@')) {
                return 'Enter a valid UPI ID (e.g., yourname@paytm)';
              }
              return null;
            },
            onChanged: (value) {
              _onPaymentMethodChanged(PaymentMethod.upi);
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, size: 16, color: Colors.green),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'DEMO: Real apps open but no actual money is charged',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails() {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Payment Details',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter card number';
              }
              final cleanNumber = value.replaceAll(' ', '');
              if (cleanNumber.length < 13) {
                return 'Enter a valid card number';
              }
              return null;
            },
            onChanged: (value) {
              _onPaymentMethodChanged(PaymentMethod.card);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardHolderController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter cardholder name';
              }
              return null;
            },
            onChanged: (value) {
              _onPaymentMethodChanged(PaymentMethod.card);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryMonthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'MM',
                    hintText: '12',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'MM';
                    }
                    final month = int.tryParse(value);
                    if (month == null || month < 1 || month > 12) {
                      return 'Invalid';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _onPaymentMethodChanged(PaymentMethod.card);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _expiryYearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'YY',
                    hintText: '25',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'YY';
                    }
                    final year = int.tryParse(value);
                    final currentYear = DateTime.now().year % 100;
                    if (year == null || year < currentYear) {
                      return 'Invalid';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _onPaymentMethodChanged(PaymentMethod.card);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CVV';
                    }
                    if (value.length < 3) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock, size: 16, color: Colors.blue),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Your card information is processed securely',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool validateForm() {
    if (_selectedMethod == null) return false;
    
    switch (_selectedMethod!) {
      case PaymentMethod.cod:
        final amount = double.tryParse(_cashAmountController.text);
        return amount != null && amount >= widget.orderAmount;
      case PaymentMethod.upi:
        return _upiController.text.isNotEmpty && _upiController.text.contains('@');
      case PaymentMethod.card:
        return _cardNumberController.text.replaceAll(' ', '').length >= 13 &&
               _cardHolderController.text.isNotEmpty &&
               _expiryMonthController.text.isNotEmpty &&
               _expiryYearController.text.isNotEmpty &&
               _cvvController.text.length >= 3;
    }
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    
    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}