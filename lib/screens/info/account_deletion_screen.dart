import 'package:flutter/material.dart';

class AccountDeletionScreen extends StatelessWidget {
  const AccountDeletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account & Data Deletion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Account & Data Deletion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Data Deletion Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- To request deletion of your account and personal data, contact support with your account email and order IDs.'),
            SizedBox(height: 12),
            Text('Processing Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- We will acknowledge the request within 48 hours and complete deletion within 30 days unless legal retention is required.'),
            SizedBox(height: 12),
            Text('Exceptions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('- Certain transactional data (order history) may be retained for legal or tax purposes.'),
          ],
        ),
      ),
    );
  }
}
