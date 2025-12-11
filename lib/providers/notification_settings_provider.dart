import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/whatsapp_service.dart';
import '../config/secure_config.dart';

class NotificationSettingsProvider with ChangeNotifier {
  // Load from secure config instead of hardcoded values
  String get _adminWhatsAppNumber => SecureConfig.adminPhoneNumber.replaceAll('whatsapp:', '').replaceAll('+', '');
  String get _supportWhatsAppNumber => SecureConfig.supportPhoneNumber.replaceAll('whatsapp:', '').replaceAll('+', '');
  bool _enableWhatsAppNotifications = true;
  bool _enableEmailNotifications = true;
  bool _sendCustomerConfirmation = true;

  String get adminWhatsAppNumber => _adminWhatsAppNumber;
  String get supportWhatsAppNumber => _supportWhatsAppNumber;
  bool get enableWhatsAppNotifications => _enableWhatsAppNotifications;
  bool get enableEmailNotifications => _enableEmailNotifications;
  bool get sendCustomerConfirmation => _sendCustomerConfirmation;

  NotificationSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Numbers now come from secure config, not stored in preferences
    _enableWhatsAppNotifications = prefs.getBool('enable_whatsapp_notifications') ?? true;
    _enableEmailNotifications = prefs.getBool('enable_email_notifications') ?? true;
    _sendCustomerConfirmation = prefs.getBool('send_customer_confirmation') ?? true;
    
    // Sync with WhatsAppService
    WhatsAppService.updateAdminNumber(_adminWhatsAppNumber);
    WhatsAppService.updateSupportNumber(_supportWhatsAppNumber);
    
    notifyListeners();
  }

  Future<void> updateAdminWhatsAppNumber(String number) async {
    // Numbers are now loaded from secure config (.env file)
    // This method is deprecated - configure via .env file instead
    print('⚠️ WARNING: Phone numbers should be configured in .env file, not in app settings');
    
    // Don't store in preferences anymore - use .env file
    notifyListeners();
  }

  Future<void> updateSupportWhatsAppNumber(String number) async {
    // Numbers are now loaded from secure config (.env file)
    // This method is deprecated - configure via .env file instead
    print('⚠️ WARNING: Phone numbers should be configured in .env file, not in app settings');
    
    // Don't store in preferences anymore - use .env file
    notifyListeners();
  }

  Future<void> toggleWhatsAppNotifications(bool value) async {
    _enableWhatsAppNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_whatsapp_notifications', value);
    notifyListeners();
  }

  Future<void> toggleEmailNotifications(bool value) async {
    _enableEmailNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_email_notifications', value);
    notifyListeners();
  }

  Future<void> toggleCustomerConfirmation(bool value) async {
    _sendCustomerConfirmation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('send_customer_confirmation', value);
    notifyListeners();
  }
}
