import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/payment_method.dart';
import '../config/secure_config.dart';

/// Automatic WhatsApp notification service using Twilio API
/// This sends WhatsApp messages automatically without requiring WhatsApp on device
class AutoWhatsAppService {
  // Credentials loaded from secure configuration
  // DO NOT hardcode credentials here - use .env file or environment variables
  static String get twilioAccountSid => SecureConfig.twilioAccountSid;
  static String get twilioAuthToken => SecureConfig.twilioAuthToken;
  static String get twilioWhatsAppNumber => SecureConfig.twilioWhatsAppNumber;
  
  // Your admin phone number to receive notifications
  static String get adminPhoneNumber => SecureConfig.adminPhoneNumber;
  
  /// Update admin phone number
  static void updateAdminNumber(String number) {
    // Note: This method is deprecated - use environment variables instead
    print('⚠️ WARNING: updateAdminNumber is deprecated. Configure via .env file');
  }

  /// Send automatic WhatsApp notification to admin when order is placed
  static Future<bool> sendOrderNotification(Order order) async {
    // Validate credentials are configured
    if (!SecureConfig.isConfigured || twilioAccountSid.isEmpty || twilioAuthToken.isEmpty) {
      print('❌ Twilio not configured. Please set credentials in .env file');
      return false;
    }

    try {
      final message = _buildOrderMessage(order);
      return await _sendTwilioWhatsApp(adminPhoneNumber, message);
    } catch (e) {
      print('AutoWhatsAppService Error: $e');
      return false;
    }
  }

  /// Send order status update automatically
  static Future<bool> sendStatusUpdate(Order order, String statusMessage) async {
    if (twilioAccountSid == 'YOUR_TWILIO_ACCOUNT_SID') {
      return false;
    }

    try {
      // Format customer phone number
      String customerPhone = order.customerPhone.replaceAll(RegExp(r'[^\d]'), '');
      if (!customerPhone.startsWith('+')) {
        customerPhone = '+91$customerPhone'; // Default to India, adjust as needed
      }
      customerPhone = 'whatsapp:$customerPhone';

      final message = '''
🔔 *KarmaShop Order Update*

Order ID: ${order.id}
Status: $statusMessage

Customer: ${order.customerName}
Total: ₹${order.totalAmount.toStringAsFixed(2)}

Track your order in the app.
''';

      return await _sendTwilioWhatsApp(customerPhone, message);
    } catch (e) {
      print('AutoWhatsAppService Error: $e');
      return false;
    }
  }

  /// Build order notification message
  static String _buildOrderMessage(Order order) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 *NEW ORDER RECEIVED!*');
    buffer.writeln('');
    buffer.writeln('*Order Details:*');
    buffer.writeln('Order ID: ${order.id.substring(0, 8)}');
    buffer.writeln('Customer: ${order.customerName}');
    buffer.writeln('Phone: ${order.customerPhone}');
    buffer.writeln('Email: ${order.customerEmail}');
    buffer.writeln('');
    
    // Payment information
    if (order.paymentInfo != null) {
      final paymentMethod = order.paymentInfo!.method;
      final paymentStatus = order.paymentInfo!.status;
      
      buffer.writeln('*Payment:*');
      if (paymentMethod == PaymentMethod.cod) {
        buffer.write('💵 Cash on Delivery');
      } else if (paymentMethod == PaymentMethod.upi) {
        buffer.write('📱 UPI - ');
        if (paymentStatus == PaymentStatus.completed) {
          buffer.write('✅ Paid');
        } else {
          buffer.write('⏳ ${paymentStatus.name}');
        }
      } else if (paymentMethod == PaymentMethod.card) {
        buffer.write('💳 Card - ');
        if (paymentStatus == PaymentStatus.completed) {
          buffer.write('✅ Paid');
        } else {
          buffer.write('⏳ ${paymentStatus.name}');
        }
      }
      
      if (order.paymentInfo!.transactionId != null) {
        buffer.writeln(' (Txn: ${order.paymentInfo!.transactionId})');
      } else {
        buffer.writeln('');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('*Items Ordered:*');
    
    for (var i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      buffer.writeln('${i + 1}. ${item.product.name}');
      buffer.writeln('   Qty: ${item.quantity} × ₹${item.product.price.toStringAsFixed(2)}');
      
      // Add product image URL if available
      if (item.product.imageUrl.isNotEmpty) {
        buffer.writeln('   📷 Image: ${item.product.imageUrl}');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('*Total: ₹${order.totalAmount.toStringAsFixed(2)}*');
    buffer.writeln('');
    buffer.writeln('*Delivery Address:*');
    buffer.writeln(order.shippingAddress);
    
    if (order.notes != null && order.notes!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('*Notes:* ${order.notes}');
    }
    
    buffer.writeln('');
    buffer.writeln('📅 ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('');
    buffer.writeln('✅ Process this order in your admin panel');

    return buffer.toString();
  }

  /// Send WhatsApp message via Twilio API with optional media attachments
  static Future<bool> _sendTwilioWhatsApp(String to, String message, {List<String>? mediaUrls}) async {
    try {
      // Twilio API endpoint
      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$twilioAccountSid/Messages.json',
      );

      // Create basic auth header
      final credentials = base64Encode(utf8.encode('$twilioAccountSid:$twilioAuthToken'));

      // Build request body
      final body = <String, String>{
        'From': twilioWhatsAppNumber,
        'To': to,
        'Body': message,
      };
      
      // Add media URLs if provided (max 10 images)
      if (mediaUrls != null && mediaUrls.isNotEmpty) {
        final validUrls = mediaUrls.take(10).toList();
        for (int i = 0; i < validUrls.length; i++) {
          body['MediaUrl$i'] = validUrls[i];
        }
      }

      // Send request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ WhatsApp message sent successfully to $to');
        return true;
      } else {
        print('❌ Failed to send WhatsApp: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Twilio API Error: $e');
      return false;
    }
  }

  /// Check if Twilio is properly configured
  static bool isConfigured() {
    return twilioAccountSid != 'YOUR_TWILIO_ACCOUNT_SID' &&
           twilioAuthToken != 'YOUR_TWILIO_AUTH_TOKEN';
  }
}
