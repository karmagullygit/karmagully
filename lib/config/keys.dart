// Add your client-side payment keys here.
// IMPORTANT: Do NOT store private/secret keys in the client for production.
// Use a secure server to sign/create orders and keep secrets off the app.

class AppKeys {
  // Razorpay public key (test or live).
  // Prefer injecting via --dart-define at build/run time for dev/test:
  //   flutter run --dart-define=RAZORPAY_KEY=rzp_test_xxx
  // The value below falls back if not provided via --dart-define.
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'REPLACE_WITH_RAZORPAY_KEY',
  );

  // IMPORTANT: Razorpay secret (the key that looks like rzp_secret_...) MUST NOT be embedded in the app.
  // Create orders and verify payments on a secure backend using the secret key.
  // For local testing only you can optionally provide the secret via --dart-define (NOT recommended for production):
  // flutter run --dart-define=RAZORPAY_SECRET=rzp_secret_xxx
  static const String razorpaySecret = String.fromEnvironment(
    'RAZORPAY_SECRET',
    defaultValue: '',
  );
}
