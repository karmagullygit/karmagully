import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations? of(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return AppLocalizations(languageProvider.currentLocale.languageCode);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Helper method to get text
  String _getText(String key) => AppStrings.get(key, languageCode);

  // Common texts
  String get appName => _getText('app_name');
  String get welcome => _getText('welcome');
  String get search => _getText('search');
  String get profile => _getText('profile');
  String get orders => _getText('orders');
  String get wishlist => _getText('wishlist');
  String get cart => _getText('cart');
  String get settings => _getText('settings');
  String get language => _getText('language');
  String get darkMode => _getText('dark_mode');
  String get logout => _getText('logout');
  String get login => _getText('login');
  String get email => _getText('email');
  String get password => _getText('password');
  String get addToCart => _getText('add_to_cart');
  String get addedToCart => _getText('added_to_cart');
  String get addToWishlist => _getText('add_to_wishlist');
  String get addedToWishlist => _getText('added_to_wishlist');
  String get removedFromWishlist => _getText('removed_from_wishlist');
  String get selectLanguage => _getText('select_language');
  String get currentLanguage => _getText('current_language');
  String get searchLanguages => _getText('search_languages');
  String get indianLanguages => _getText('indian_languages');
  String get otherLanguages => _getText('other_languages');
  String get noLanguagesFound => _getText('no_languages_found');
  String get languageChanged => _getText('language_changed');
  String get findWhatYouNeed => _getText('find_what_you_need');
  String get categories => _getText('categories');
  String get no_categories_available => _getText('no_categories_available');
  String get featuredProducts => _getText('featured_products');
  String get successfully_logged_out => _getText('successfully_logged_out');
  String get logout_error => _getText('logout_error');
  String get welcomeBack => _getText('welcome_back');
  String get createAccount => _getText('create_account');
  String get signInToContinue => _getText('sign_in_to_continue');
  String get joinKarmaShop => _getText('join_karma_shop');
  String get name => _getText('name');
  String get products_found => _getText('products_found');
  String get clear_filter => _getText('clear_filter');
  String get no_products_found => _getText('no_products_found');
  String get no_products_in_category => _getText('no_products_in_category');
  String get browse_all_products => _getText('browse_all_products');
  String get search_products => _getText('search_products');
  String get search_in_category => _getText('search_in_category');
  String get cancel => _getText('cancel');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi', 'bn', 'ta'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}