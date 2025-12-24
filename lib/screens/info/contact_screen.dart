import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact & Support')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Contact & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Customer Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Email: support@karmagully.com'),
            Text('- Phone: +91-XXXXXXXXXX (Mon–Fri 10:00–18:00)'),
            SizedBox(height: 12),
            Text('Issue Reporting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- For order-related issues, include your order ID and a short description.'),
            SizedBox(height: 12),
            Text('Business Inquiries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Email: partnerships@karmagully.com'),
          ],
        ),
      ),
    );
  }
}
