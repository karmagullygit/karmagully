import 'package:flutter/material.dart';

class RefundScreen extends StatelessWidget {
  const RefundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refund & Cancellation Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Refund & Cancellation Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Refund Eligibility', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Eligible: damaged, defective, or incorrect items delivered; proven non-delivery.'),
            Text('- Not eligible: change of mind or damage after delivery.'),
            SizedBox(height: 12),
            Text('Replacement Policy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Report damage within 48 hours with photos. We may request return for inspection.'),
            Text('- If approved we will offer a replacement or refund.'),
            SizedBox(height: 12),
            Text('Custom Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Custom posters are non-cancellable once production begins. If defective, contact support with images for evaluation.'),
            SizedBox(height: 12),
            Text('Processing Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Refunds processed after verification: typically within 7–14 business days.'),
            SizedBox(height: 12),
            Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('Email: contactkarmagully@gmail.com'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
