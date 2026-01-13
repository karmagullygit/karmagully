// Add your client-side payment keys here.
// IMPORTANT: Do NOT store private/secret keys in the client for production.
// Use a secure server to sign/create orders and keep secrets off the app.

class AppKeys {
  // Razorpay public key (test or live).
  // Prefer injecting via --dart-define at build/run time.
  //   flutter run --dart-define=RAZORPAY_KEY=rzp_live_xxxxxx
  // The value below falls back if not provided via --dart-define.
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: '', // PASS YOUR KEY VIA --dart-define
  );

  // IMPORTANT: Razorpay secret (the key that looks like rzp_secret_xxxx)
  // Create orders and verify payments on a secure backend using this key.
  // For local testing only you can optionally provide the secret here.
  // flutter run --dart-define=RAZORPAY_SECRET=rzp_secret_xxx
  static const String razorpaySecret = String.fromEnvironment(
    'RAZORPAY_SECRET',
    defaultValue: '', // PASS YOUR SECRET VIA --dart-define
  );

  // Optional backend base URL for order creation and verification (preferred).
  // Example: flutter run --dart-define=BACKEND_BASE_URL=https://abcd.ngrok.io
  // For Android Emulator: 10.0.2.2 maps to host machine's localhost
  // For Real Device: Use ngrok URL or your local IP (e.g., http://192.168.1.12:4000)
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );
}
