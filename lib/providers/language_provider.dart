import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US'); // Default to English
  
  Locale get currentLocale => _currentLocale;
  
  // Comprehensive list with Indian languages first
  static const List<Map<String, String>> supportedLanguages = [
    // Indian Languages (Priority)
    {'code': 'hi_IN', 'name': 'हिंदी (Hindi)', 'englishName': 'Hindi', 'flag': '🇮🇳'},
    {'code': 'bn_IN', 'name': 'বাংলা (Bengali)', 'englishName': 'Bengali', 'flag': '🇮🇳'},
    {'code': 'te_IN', 'name': 'తెలుగు (Telugu)', 'englishName': 'Telugu', 'flag': '🇮🇳'},
    {'code': 'mr_IN', 'name': 'मराठी (Marathi)', 'englishName': 'Marathi', 'flag': '🇮🇳'},
    {'code': 'ta_IN', 'name': 'தமிழ் (Tamil)', 'englishName': 'Tamil', 'flag': '🇮🇳'},
    {'code': 'gu_IN', 'name': 'ગુજરાતી (Gujarati)', 'englishName': 'Gujarati', 'flag': '🇮🇳'},
    {'code': 'kn_IN', 'name': 'ಕನ್ನಡ (Kannada)', 'englishName': 'Kannada', 'flag': '🇮🇳'},
    {'code': 'ml_IN', 'name': 'മലയാളം (Malayalam)', 'englishName': 'Malayalam', 'flag': '🇮🇳'},
    {'code': 'pa_IN', 'name': 'ਪੰਜਾਬੀ (Punjabi)', 'englishName': 'Punjabi', 'flag': '🇮🇳'},
    {'code': 'or_IN', 'name': 'ଓଡ଼ିଆ (Odia)', 'englishName': 'Odia', 'flag': '🇮🇳'},
    {'code': 'as_IN', 'name': 'অসমীয়া (Assamese)', 'englishName': 'Assamese', 'flag': '🇮🇳'},
    {'code': 'ur_IN', 'name': 'اردو (Urdu)', 'englishName': 'Urdu', 'flag': '🇮🇳'},
    
    // English (Default)
    {'code': 'en_US', 'name': 'English', 'englishName': 'English', 'flag': '🇺🇸'},
    
    // Major World Languages
    {'code': 'zh_CN', 'name': '中文 (Chinese)', 'englishName': 'Chinese (Simplified)', 'flag': '🇨🇳'},
    {'code': 'zh_TW', 'name': '中文 (繁體)', 'englishName': 'Chinese (Traditional)', 'flag': '🇹🇼'},
    {'code': 'es_ES', 'name': 'Español', 'englishName': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'fr_FR', 'name': 'Français', 'englishName': 'French', 'flag': '🇫🇷'},
    {'code': 'ar_SA', 'name': 'العربية', 'englishName': 'Arabic', 'flag': '🇸🇦'},
    {'code': 'pt_BR', 'name': 'Português', 'englishName': 'Portuguese', 'flag': '🇧🇷'},
    {'code': 'ru_RU', 'name': 'Русский', 'englishName': 'Russian', 'flag': '🇷🇺'},
    {'code': 'ja_JP', 'name': '日本語', 'englishName': 'Japanese', 'flag': '🇯🇵'},
    {'code': 'ko_KR', 'name': '한국어', 'englishName': 'Korean', 'flag': '🇰🇷'},
    {'code': 'de_DE', 'name': 'Deutsch', 'englishName': 'German', 'flag': '🇩🇪'},
    {'code': 'it_IT', 'name': 'Italiano', 'englishName': 'Italian', 'flag': '🇮🇹'},
    {'code': 'tr_TR', 'name': 'Türkçe', 'englishName': 'Turkish', 'flag': '🇹🇷'},
    {'code': 'pl_PL', 'name': 'Polski', 'englishName': 'Polish', 'flag': '🇵🇱'},
    {'code': 'nl_NL', 'name': 'Nederlands', 'englishName': 'Dutch', 'flag': '🇳🇱'},
    {'code': 'sv_SE', 'name': 'Svenska', 'englishName': 'Swedish', 'flag': '🇸🇪'},
    {'code': 'da_DK', 'name': 'Dansk', 'englishName': 'Danish', 'flag': '🇩🇰'},
    {'code': 'no_NO', 'name': 'Norsk', 'englishName': 'Norwegian', 'flag': '🇳🇴'},
    {'code': 'fi_FI', 'name': 'Suomi', 'englishName': 'Finnish', 'flag': '🇫🇮'},
    {'code': 'th_TH', 'name': 'ไทย', 'englishName': 'Thai', 'flag': '🇹🇭'},
    {'code': 'vi_VN', 'name': 'Tiếng Việt', 'englishName': 'Vietnamese', 'flag': '🇻🇳'},
    {'code': 'id_ID', 'name': 'Bahasa Indonesia', 'englishName': 'Indonesian', 'flag': '🇮🇩'},
    {'code': 'ms_MY', 'name': 'Bahasa Melayu', 'englishName': 'Malay', 'flag': '🇲🇾'},
    {'code': 'tl_PH', 'name': 'Filipino', 'englishName': 'Filipino', 'flag': '🇵🇭'},
    {'code': 'sw_KE', 'name': 'Kiswahili', 'englishName': 'Swahili', 'flag': '🇰🇪'},
    {'code': 'am_ET', 'name': 'አማርኛ', 'englishName': 'Amharic', 'flag': '🇪🇹'},
    {'code': 'he_IL', 'name': 'עברית', 'englishName': 'Hebrew', 'flag': '🇮🇱'},
    {'code': 'fa_IR', 'name': 'فارسی', 'englishName': 'Persian', 'flag': '🇮🇷'},
    {'code': 'uk_UA', 'name': 'Українська', 'englishName': 'Ukrainian', 'flag': '🇺🇦'},
    {'code': 'cs_CZ', 'name': 'Čeština', 'englishName': 'Czech', 'flag': '🇨🇿'},
    {'code': 'sk_SK', 'name': 'Slovenčina', 'englishName': 'Slovak', 'flag': '🇸🇰'},
    {'code': 'hu_HU', 'name': 'Magyar', 'englishName': 'Hungarian', 'flag': '🇭🇺'},
    {'code': 'ro_RO', 'name': 'Română', 'englishName': 'Romanian', 'flag': '🇷🇴'},
    {'code': 'bg_BG', 'name': 'Български', 'englishName': 'Bulgarian', 'flag': '🇧🇬'},
    {'code': 'hr_HR', 'name': 'Hrvatski', 'englishName': 'Croatian', 'flag': '🇭🇷'},
    {'code': 'sr_RS', 'name': 'Српски', 'englishName': 'Serbian', 'flag': '🇷🇸'},
    {'code': 'sl_SI', 'name': 'Slovenščina', 'englishName': 'Slovenian', 'flag': '🇸🇮'},
    {'code': 'lt_LT', 'name': 'Lietuvių', 'englishName': 'Lithuanian', 'flag': '🇱🇹'},
    {'code': 'lv_LV', 'name': 'Latviešu', 'englishName': 'Latvian', 'flag': '🇱🇻'},
    {'code': 'et_EE', 'name': 'Eesti', 'englishName': 'Estonian', 'flag': '🇪🇪'},
    {'code': 'mt_MT', 'name': 'Malti', 'englishName': 'Maltese', 'flag': '🇲🇹'},
    {'code': 'is_IS', 'name': 'Íslenska', 'englishName': 'Icelandic', 'flag': '🇮🇸'},
    {'code': 'ga_IE', 'name': 'Gaeilge', 'englishName': 'Irish', 'flag': '🇮🇪'},
    {'code': 'cy_GB', 'name': 'Cymraeg', 'englishName': 'Welsh', 'flag': '🏴󠁧󠁢󠁷󠁬󠁳󠁿'},
    {'code': 'eu_ES', 'name': 'Euskera', 'englishName': 'Basque', 'flag': '🇪🇸'},
    {'code': 'ca_ES', 'name': 'Català', 'englishName': 'Catalan', 'flag': '🇪🇸'},
    {'code': 'gl_ES', 'name': 'Galego', 'englishName': 'Galician', 'flag': '🇪🇸'},
  ];

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('selected_language') ?? 'en_US';
    
    final parts = savedLanguageCode.split('_');
    Locale newLocale;
    
    if (parts.length == 2) {
      // For most languages, especially Indian languages, use just the language code
      // This ensures better Material localization support
      if (parts[0] != 'en') {
        newLocale = Locale(parts[0]);
      } else {
        newLocale = Locale(parts[0], parts[1]);
      }
    } else {
      newLocale = Locale(parts[0]);
    }
    
    _currentLocale = newLocale;
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    final parts = languageCode.split('_');
    Locale newLocale;
    
    if (parts.length == 2) {
      newLocale = Locale(parts[0], parts[1]);
    } else {
      newLocale = Locale(parts[0]);
    }
    
    // For languages that might not have full Material localization support,
    // fall back to just the language code without country code
    if (parts.length == 2 && parts[0] != 'en') {
      // For most Indian and other languages, use just the language code
      // This ensures Material Design components work properly
      newLocale = Locale(parts[0]);
    }
    
    _currentLocale = newLocale;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    
    notifyListeners();
  }

  String getCurrentLanguageName() {
    final currentCode = '${_currentLocale.languageCode}_${_currentLocale.countryCode ?? _currentLocale.languageCode.toUpperCase()}';
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == currentCode,
      orElse: () => supportedLanguages.firstWhere((lang) => lang['code'] == 'en_US'),
    );
    return language['name'] ?? 'English';
  }

  String getCurrentLanguageFlag() {
    final currentCode = '${_currentLocale.languageCode}_${_currentLocale.countryCode ?? _currentLocale.languageCode.toUpperCase()}';
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == currentCode,
      orElse: () => supportedLanguages.firstWhere((lang) => lang['code'] == 'en_US'),
    );
    return language['flag'] ?? '🇺🇸';
  }

  List<Map<String, String>> searchLanguages(String query) {
    if (query.isEmpty) return supportedLanguages;
    
    final lowerQuery = query.toLowerCase();
    return supportedLanguages.where((language) {
      return language['name']!.toLowerCase().contains(lowerQuery) ||
             language['englishName']!.toLowerCase().contains(lowerQuery) ||
             language['code']!.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}