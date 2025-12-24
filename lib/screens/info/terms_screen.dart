import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Terms & Conditions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('User Eligibility', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('You must be at least 18 years old and able to enter into binding contracts under Indian law.'),
            SizedBox(height: 8),
            Text('Account Responsibilities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('Keep your account credentials secure. You are responsible for activity under your account.'),
            SizedBox(height: 8),
            Text('Orders, Pricing & Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('Prices, taxes and shipping are shown at checkout. We accept UPI, cards and supported payment gateways. Orders are subject to availability and payment verification.'),
            SizedBox(height: 8),
            Text('Intellectual Property', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('All content, designs, logos and app UI are owned or licensed by KarmaGully. Do not reproduce without permission.'),
            SizedBox(height: 8),
            Text('Limitation of Liability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('To the extent permitted by law, KarmaGully’s liability for direct damages is limited to the order value. We are not liable for indirect or consequential damages.'),
            SizedBox(height: 8),
            Text('Governing Law', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('These Terms are governed by the laws of India.'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
