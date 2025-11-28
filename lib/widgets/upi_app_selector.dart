import 'package:flutter/material.dart';
import '../services/real_upi_service.dart';

class UPIAppSelector extends StatefulWidget {
  final Function(UPIApp app) onAppSelected;
  final double amount;
  final String orderId;

  const UPIAppSelector({
    super.key,
    required this.onAppSelected,
    required this.amount,
    required this.orderId,
  });

  @override
  State<UPIAppSelector> createState() => _UPIAppSelectorState();
}

class _UPIAppSelectorState extends State<UPIAppSelector> {
  UPIApp? _selectedApp;
  bool _isProcessing = false;
  String? _paymentResult;

  @override
  Widget build(BuildContext context) {
    final availableApps = RealUPIService.getAvailableUPIApps();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Choose UPI App',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'Select your preferred UPI app to complete the payment:',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          
          // UPI Apps Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: availableApps.length,
            itemBuilder: (context, index) {
              final app = availableApps[index];
              final isSelected = _selectedApp == app;
              
              return GestureDetector(
                onTap: () => _selectApp(app),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        app.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (app.isInstalled) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Installed',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          
          if (_selectedApp != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount:'),
                      Text(
                        '₹${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Merchant:'),
                      Text(RealUPIService.merchantName),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order ID:'),
                      Text(widget.orderId),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _launchPayment,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_selectedApp!.icon),
                      label: Text(_isProcessing
                          ? 'Opening ${_selectedApp!.name}...'
                          : 'Pay with ${_selectedApp!.name}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (_paymentResult != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _paymentResult!.contains('successful')
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _paymentResult!.contains('successful')
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _paymentResult!.contains('successful')
                        ? Icons.check_circle
                        : Icons.error,
                    color: _paymentResult!.contains('successful')
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _paymentResult!,
                      style: TextStyle(
                        color: _paymentResult!.contains('successful')
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'DEMO MODE: Apps will simulate payment without real money transfer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectApp(UPIApp app) {
    setState(() {
      _selectedApp = app;
      _paymentResult = null;
    });
    widget.onAppSelected(app);
  }

  Future<void> _launchPayment() async {
    if (_selectedApp == null) return;

    setState(() {
      _isProcessing = true;
      _paymentResult = null;
    });

    try {
      // Launch UPI payment
      final result = await RealUPIService.launchUPIPayment(
        app: _selectedApp!.name,
        amount: widget.amount,
        orderId: widget.orderId,
        note: 'Payment for KarmaShop Order',
      );

      // Show result
      setState(() {
        _isProcessing = false;
        if (result['success'] == true) {
          _paymentResult = 'Payment successful! Transaction ID: ${result['transactionId']}';
        } else {
          _paymentResult = 'Payment failed: ${result['error']}';
        }
      });

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_paymentResult!),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _paymentResult = 'Error: $e';
      });
    }
  }
}