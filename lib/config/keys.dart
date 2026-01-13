// Add your client-side payment keys here.
// IMPORTANT: Do NOT store private/secret keys in the client for production.
// Use a secure server to sign/create orders and keep secrets off the app.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppKeys {
  // Razorpay public key (test or live).
  // Read from .env file
  static String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';

  // IMPORTANT: Razorpay secret
  // Read from .env file
  static String get razorpaySecret => dotenv.env['RAZORPAY_SECRET'] ?? '';

  // Optional backend base URL for order creation and verification (preferred).
  // Example: flutter run --dart-define=BACKEND_BASE_URL=https://abcd.ngrok.io
  // For Android Emulator: 10.0.2.2 maps to host machine's localhost
  // For Real Device: Use ngrok URL or your local IP (e.g., http://192.168.1.12:4000)
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );
}
