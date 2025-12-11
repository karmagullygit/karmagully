class SecureConfig {
  // DO NOT commit actual credentials here
  // These are placeholders - actual values should come from environment variables
  // or secure configuration management
  
  static const String twilioAccountSid = String.fromEnvironment(
    'TWILIO_ACCOUNT_SID',
    defaultValue: '', // Empty default - must be configured
  );
  
  static const String twilioAuthToken = String.fromEnvironment(
    'TWILIO_AUTH_TOKEN',
    defaultValue: '', // Empty default - must be configured
  );
  
  static const String twilioWhatsAppNumber = String.fromEnvironment(
    'TWILIO_WHATSAPP_NUMBER',
    defaultValue: 'whatsapp:+14155238886', // Twilio sandbox number (public)
  );
  
  static const String adminPhoneNumber = String.fromEnvironment(
    'ADMIN_WHATSAPP_NUMBER',
    defaultValue: '', // Empty default - must be configured
  );
  
  static const String supportPhoneNumber = String.fromEnvironment(
    'SUPPORT_WHATSAPP_NUMBER',
    defaultValue: '', // Empty default - must be configured
  );
  
  // Validation
  static bool get isConfigured {
    return twilioAccountSid.isNotEmpty &&
           twilioAuthToken.isNotEmpty &&
           adminPhoneNumber.isNotEmpty;
  }
}
