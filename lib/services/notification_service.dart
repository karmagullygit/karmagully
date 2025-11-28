import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

/// Notification helper.
///
/// Preferred flow: POST the order to your serverless endpoint which sends
/// the email using a secret Resend API key. If `serverlessEndpoint` is
/// not configured, the code falls back to attempting to call Resend
/// directly when an API key is provided, otherwise it prints the payload.
class NotificationService {
  // Configure this to your deployed serverless endpoint (recommended).
  // Example: https://your-deployment.vercel.app/api/send-order
  static const String serverlessEndpoint = 'https://karmagully.vercel.app/api/send-order-notification'; // Vercel deployment URL

  // Fallback direct Resend usage (not recommended for production).
  static const String resendApiKey = '<YOUR_RESEND_API_KEY_HERE>';
  static const String fromEmail = 'onboarding@resend.dev';
  static const String fromName = 'KarmaGully';
  static const String adminEmail = 'karmagully0@gmail.com';

  /// Send order notification; prefers serverless endpoint.
  static Future<bool> sendOrderNotification(Order order) async {
    // If serverless endpoint is provided, POST to it.
    if (serverlessEndpoint.isNotEmpty && !serverlessEndpoint.startsWith('<')) {
      try {
        final url = Uri.parse(serverlessEndpoint);
        final resp = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'order': order.toJson()}),
        );
        if (resp.statusCode == 200 || resp.statusCode == 202) {
          print('NotificationService: serverless endpoint accepted the notification');
          return true;
        }
        print('NotificationService: serverless returned ${resp.statusCode} ${resp.body}');
        return false;
      } catch (e) {
        print('NotificationService: error calling serverless endpoint: $e');
        // fallthrough to fallback behavior
      }
    }

    // Fallback: direct Resend call (only for quick testing; not secure).
    if (resendApiKey.isEmpty || resendApiKey.startsWith('<')) {
      print('NotificationService: No serverless endpoint or Resend API key configured.');
      print('Order notification payload: ${order.toJson()}');
      return false;
    }

    final url = Uri.parse('https://api.resend.com/emails');
    final subject = 'New Order Placed — ${order.id}';
    final body = StringBuffer();
    body.writeln('A new order was placed in Karma Shop:');
    body.writeln('Order ID: ${order.id}');
    body.writeln('Customer: ${order.customerName}');
    body.writeln('Email: ${order.customerEmail}');
    body.writeln('Phone: ${order.customerPhone}');
    body.writeln('Total: ₹${order.totalAmount.toStringAsFixed(2)}');
    body.writeln('Items:');
    for (final item in order.items) {
      body.writeln('- ${item.product.name} x${item.quantity} @ ₹${item.product.price}');
    }
    body.writeln('\nShipping address: ${order.shippingAddress}');
    if (order.notes != null && order.notes!.isNotEmpty) {
      body.writeln('\nNotes: ${order.notes}');
    }

    // Build recipient list: admin + customer
    final recipients = <String>[adminEmail];
    if (order.customerEmail.isNotEmpty) {
      recipients.add(order.customerEmail);
    }

    final payload = {
      'from': '$fromName <$fromEmail>',
      'to': recipients,
      'subject': subject,
      'text': body.toString(),
    };

    try {
      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (resp.statusCode == 200) {
        print('NotificationService: email accepted by Resend');
        return true;
      }

      print('NotificationService: send failed ${resp.statusCode} ${resp.body}');
      return false;
    } catch (e) {
      print('NotificationService: error sending email: $e');
      return false;
    }
  }
}
