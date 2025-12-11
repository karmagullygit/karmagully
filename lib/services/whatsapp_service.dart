import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../config/secure_config.dart';

/// WhatsApp notification service for order notifications
/// 
/// **IMPORTANT**: Configure your WhatsApp numbers via environment variables
/// Set in .env file (not committed to Git for security)
/// 
/// Phone number format: whatsapp:+[country][number]
/// Example: whatsapp:+919876543210 for India, whatsapp:+14155552671 for USA
class WhatsAppService {
  // Load from secure config - DO NOT hardcode
  static String get _adminWhatsAppNumber => SecureConfig.adminPhoneNumber.replaceAll('whatsapp:', '');
  static String get _supportWhatsAppNumber => SecureConfig.supportPhoneNumber.replaceAll('whatsapp:', '');

  /// Update admin WhatsApp number (called by NotificationSettingsProvider)
  static void updateAdminNumber(String number) {
    print('⚠️ WARNING: updateAdminNumber is deprecated. Configure via .env file');
  }

  /// Update support WhatsApp number (called by NotificationSettingsProvider)
  static void updateSupportNumber(String number) {
    print('⚠️ WARNING: updateSupportNumber is deprecated. Configure via .env file');
  }

  /// Get current admin number
  static String get adminNumber => _adminWhatsAppNumber;

  /// Get current support number
  static String get supportNumber => _supportWhatsAppNumber;

  /// Send order notification to admin via WhatsApp
  static Future<bool> sendOrderNotificationToAdmin(Order order) async {
    final message = _buildOrderNotificationMessage(order);
    return await _sendWhatsAppMessage(_adminWhatsAppNumber, message);
  }

  /// Send order confirmation to customer via WhatsApp
  static Future<bool> sendOrderConfirmationToCustomer(Order order) async {
    // Extract phone number from customer phone (remove spaces, dashes, +)
    final customerPhone = _cleanPhoneNumber(order.customerPhone);
    
    if (customerPhone.isEmpty) {
      print('WhatsAppService: Invalid customer phone number');
      return false;
    }

    final message = _buildCustomerConfirmationMessage(order);
    return await _sendWhatsAppMessage(customerPhone, message);
  }

  /// Send order status update to customer via WhatsApp
  static Future<bool> sendOrderStatusUpdate(Order order, String statusMessage) async {
    final customerPhone = _cleanPhoneNumber(order.customerPhone);
    
    if (customerPhone.isEmpty) {
      print('WhatsAppService: Invalid customer phone number');
      return false;
    }

    final message = '''
🔔 *Order Status Update*

Order ID: ${order.id}
Status: $statusMessage

Track your order in the KarmaShop app.

Thank you for shopping with KarmaGully! 🛍️
''';

    return await _sendWhatsAppMessage(customerPhone, message);
  }

  /// Build order notification message for admin
  static String _buildOrderNotificationMessage(Order order) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 *New Order Received!*');
    buffer.writeln('');
    buffer.writeln('*Order Details:*');
    buffer.writeln('Order ID: ${order.id}');
    buffer.writeln('Customer: ${order.customerName}');
    buffer.writeln('Email: ${order.customerEmail}');
    buffer.writeln('Phone: ${order.customerPhone}');
    buffer.writeln('');
    buffer.writeln('*Items:*');
    
    for (var i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      buffer.writeln('${i + 1}. ${item.product.name}');
      buffer.writeln('   Qty: ${item.quantity} × ₹${item.product.price.toStringAsFixed(2)}');
      buffer.writeln('   Subtotal: ₹${(item.quantity * item.product.price).toStringAsFixed(2)}');
    }
    
    buffer.writeln('');
    buffer.writeln('*Total Amount: ₹${order.totalAmount.toStringAsFixed(2)}*');
    buffer.writeln('');
    buffer.writeln('*Shipping Address:*');
    buffer.writeln(order.shippingAddress);
    
    if (order.notes != null && order.notes!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('*Customer Notes:*');
      buffer.writeln(order.notes);
    }
    
    buffer.writeln('');
    buffer.writeln('📅 Ordered at: ${_formatDateTime(order.createdAt)}');
    buffer.writeln('');
    buffer.writeln('Please process this order in the admin panel.');

    return buffer.toString();
  }

  /// Build customer confirmation message
  static String _buildCustomerConfirmationMessage(Order order) {
    final buffer = StringBuffer();
    buffer.writeln('✅ *Order Confirmed!*');
    buffer.writeln('');
    buffer.writeln('Hi ${order.customerName},');
    buffer.writeln('');
    buffer.writeln('Thank you for your order! 🎉');
    buffer.writeln('');
    buffer.writeln('*Order ID:* ${order.id}');
    buffer.writeln('*Total:* ₹${order.totalAmount.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('*Items:*');
    
    for (var i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      buffer.writeln('${i + 1}. ${item.product.name} × ${item.quantity}');
    }
    
    buffer.writeln('');
    buffer.writeln('*Delivery Address:*');
    buffer.writeln(order.shippingAddress);
    buffer.writeln('');
    buffer.writeln('We will notify you when your order is shipped.');
    buffer.writeln('');
    buffer.writeln('Track your order in the KarmaShop app.');
    buffer.writeln('');
    buffer.writeln('Thank you for shopping with KarmaGully! 🛍️');

    return buffer.toString();
  }

  /// Send WhatsApp message using URL scheme
  static Future<bool> _sendWhatsAppMessage(String phoneNumber, String message) async {
    try {
      // Clean phone number
      final cleanPhone = _cleanPhoneNumber(phoneNumber);
      
      // URL encode the message
      final encodedMessage = Uri.encodeComponent(message);
      
      // Create WhatsApp URL (works on both mobile and web)
      // For mobile: whatsapp://send?phone=...
      // For web: https://wa.me/...
      final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');
      
      print('WhatsAppService: Opening WhatsApp with URL: $whatsappUrl');
      
      if (await canLaunchUrl(whatsappUrl)) {
        final launched = await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          print('WhatsAppService: Successfully opened WhatsApp');
          return true;
        } else {
          print('WhatsAppService: Failed to launch WhatsApp');
          return false;
        }
      } else {
        print('WhatsAppService: Cannot launch WhatsApp URL');
        return false;
      }
    } catch (e) {
      print('WhatsAppService: Error sending WhatsApp message: $e');
      return false;
    }
  }

  /// Clean phone number (remove spaces, dashes, parentheses, +)
  static String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Format DateTime to readable string
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Open WhatsApp chat with support
  static Future<bool> openSupportChat() async {
    final message = Uri.encodeComponent('Hi, I need help with my order.');
    final whatsappUrl = Uri.parse('https://wa.me/$_supportWhatsAppNumber?text=$message');
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        return await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('WhatsAppService: Error opening support chat: $e');
      return false;
    }
  }
}
