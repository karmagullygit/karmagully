import 'package:flutter/material.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing & Product Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Pricing & Product Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Poster Sizes & Pricing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Small: 8 × 11.7 inches'),
            Text('- Large: 11.7 × 15.7 inches'),
            SizedBox(height: 12),
            Text('Pricing Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Prices are shown on the product page and include applicable taxes unless stated otherwise.'),
            Text('- Custom prints or high-resolution variations may carry additional costs.'),
            SizedBox(height: 12),
            Text('Returns on Printed Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Prints are custom-made; returns are accepted only for defects or shipping damage.'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
