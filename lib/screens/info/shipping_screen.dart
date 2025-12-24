import 'package:flutter/material.dart';

class ShippingScreen extends StatelessWidget {
  const ShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping & Delivery')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Shipping & Delivery Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Coverage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- We ship across India only.'),
            SizedBox(height: 12),
            Text('Estimated Delivery Timelines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Metro cities: typically 3–7 business days.'),
            Text('- Non-metro / remote locations: typically 5–12 business days.'),
            SizedBox(height: 12),
            Text('Order Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Tracking information is provided by email/SMS/in-app once shipped.'),
            SizedBox(height: 12),
            Text('Lost or Damaged Shipments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Contact support with order and tracking details for investigation and assistance.'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
