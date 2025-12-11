# Security Configuration Guide

## 🔐 Important: Protecting Sensitive Credentials

This app uses Twilio WhatsApp API which requires sensitive credentials. **NEVER commit these to Git!**

## Setup Instructions

### 1. Create Your Environment File

Copy the example file and add your actual credentials:

```bash
cp .env.example .env
```

### 2. Configure Your Credentials

Edit `.env` file with your actual values:

```env
# Get these from https://www.twilio.com/console
TWILIO_ACCOUNT_SID=your_actual_account_sid
TWILIO_AUTH_TOKEN=your_actual_auth_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886

# Your business WhatsApp numbers
ADMIN_WHATSAPP_NUMBER=whatsapp:+your_admin_number
SUPPORT_WHATSAPP_NUMBER=whatsapp:+your_support_number
```

### 3. Running the App

The app will automatically load credentials from the `.env` file (which is gitignored).

```bash
flutter run
```

## 🚨 Security Checklist

Before pushing to GitHub, verify:

- [x] `.env` file is in `.gitignore`
- [x] No hardcoded credentials in `lib/services/auto_whatsapp_service.dart`
- [x] No hardcoded credentials in `lib/services/whatsapp_service.dart`
- [x] No hardcoded credentials in `lib/providers/notification_settings_provider.dart`
- [x] `test_whatsapp.dart` is in `.gitignore`
- [x] All credentials use `SecureConfig` class

## 📝 Files Protected

These files are automatically ignored by Git:

- `.env` - Your actual credentials
- `.env.local` - Local overrides
- `test_whatsapp.dart` - Test file with credentials
- Any file matching `**/secrets.dart`
- Any file matching `**/credentials.json`

## 🔄 For Team Members

When cloning this repository:

1. Copy `.env.example` to `.env`
2. Ask team lead for actual Twilio credentials
3. Add your credentials to `.env`
4. Never commit `.env` file

## ⚡ Quick Check

Run this to verify no credentials are exposed:

```bash
git grep -E "(AC[a-z0-9]{32}|SK[a-z0-9]{32}|[0-9]{10,15})" -- "*.dart"
```

If this returns any results in committed files, **DO NOT PUSH!**

## 🆘 Emergency: Credentials Leaked

If you accidentally commit credentials:

1. **Immediately** rotate credentials in Twilio Console
2. Run `git filter-branch` or BFG Repo-Cleaner to remove from history
3. Force push the cleaned repository
4. Update `.env` with new credentials

## 📚 Additional Resources

- [Twilio Security Best Practices](https://www.twilio.com/docs/usage/security)
- [Git Secrets Protection](https://git-secret.io/)
- [Environment Variables in Flutter](https://pub.dev/packages/flutter_dotenv)
