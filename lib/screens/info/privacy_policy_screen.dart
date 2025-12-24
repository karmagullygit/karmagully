import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Privacy Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Introduction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('This Privacy Policy explains how KarmaGully collects, uses, stores and shares personal information. By using the KarmaGully app or placing orders, you agree to this policy.'),
            SizedBox(height: 12),
            Text('Information We Collect', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Account & Identity: name, email, phone number, delivery address, profile picture.'),
            Text('- Order & Payment: order history, billing/shipping addresses, payment transaction identifiers (we do not store full card numbers).'),
            Text('- Device & Usage: device identifiers, OS version, IP address, crash logs, analytics events.'),
            Text('- Support Data: messages, support tickets, and any attachments you send to support.'),
            SizedBox(height: 12),
            Text('Purpose of Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- To process orders, payments and refunds.'),
            Text('- To communicate order status, support responses and account updates.'),
            Text('- To improve our service via analytics and crash reporting.'),
            SizedBox(height: 12),
            Text('Third-Party Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Payment Gateways: Razorpay, Cashfree (or similar) for processing payments.'),
            Text('- Analytics & Crash Reporting: Firebase, Google Analytics (or equivalent).'),
            Text('- Hosting & Email providers to deliver services and notifications.'),
            SizedBox(height: 12),
            Text('Data Protection & Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- We use HTTPS/TLS for data in transit and secure hosting for storage.'),
            Text('- Access to personal data is restricted and controlled.'),
            SizedBox(height: 12),
            Text('User Rights & Choices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Access: request a copy of your personal data.'),
            Text('- Correction: ask us to correct inaccurate information.'),
            Text('- Deletion: request account and data deletion (see Account & Data Deletion).'),
            SizedBox(height: 12),
            Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('For privacy inquiries contact: contactkarmagully@gmail.com'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
