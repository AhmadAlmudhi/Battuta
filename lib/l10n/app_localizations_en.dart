// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Battuta';

  @override
  String get appTagline => 'Every country, stamped.';

  @override
  String pageTitle(String screen, String appName) {
    return '$screen · $appName';
  }

  @override
  String get navExplore => 'Explore';

  @override
  String get navTravels => 'My travels';

  @override
  String get navStats => 'Stats';

  @override
  String get welcomeTitle => 'Welcome to Battuta';

  @override
  String get welcomeBody =>
      'Explore every country, record where you\'ve been, and plan where to go next.';

  @override
  String get welcomeContinueAsGuest => 'Continue as guest';

  @override
  String get welcomeSignIn => 'Sign in';

  @override
  String exploreCountryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries',
      one: '1 country',
    );
    return '$_temp0';
  }

  @override
  String get exploreLoadError => 'Couldn\'t load countries.';

  @override
  String get countryNotFoundTitle => 'Country not found';

  @override
  String get countryNotFoundBody => 'There\'s no country with this code.';

  @override
  String get countryNotFoundBack => 'Back to Explore';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundBody => 'This page doesn\'t exist.';

  @override
  String get placeholderBody => 'This screen is under construction.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountGuestTitle => 'Back up your travels';

  @override
  String get accountGuestBody =>
      'Sign in to back up your travels and see them on all your devices.';

  @override
  String get accountSignIn => 'Sign in';

  @override
  String get accountSettings => 'Settings';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';
}
