// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'بطوطة';

  @override
  String get appTagline => 'كل دولة، بختمها';

  @override
  String pageTitle(String screen, String appName) {
    return '$screen · $appName';
  }

  @override
  String get navExplore => 'استكشف';

  @override
  String get navTravels => 'رحلاتي';

  @override
  String get navStats => 'الإحصاءات';

  @override
  String get welcomeTitle => 'مرحبًا بك في بطوطة';

  @override
  String get welcomeBody =>
      'استكشف كل دول العالم، وسجّل الدول التي زرتها، وخطّط لوجهتك القادمة.';

  @override
  String get welcomeContinueAsGuest => 'المتابعة كضيف';

  @override
  String get welcomeSignIn => 'تسجيل الدخول';

  @override
  String exploreCountryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دولة',
      many: '$count دولة',
      few: '$count دول',
      two: 'دولتان',
      one: 'دولة واحدة',
      zero: 'لا توجد دول',
    );
    return '$_temp0';
  }

  @override
  String get exploreLoadError => 'تعذّر تحميل الدول.';

  @override
  String get countryNotFoundTitle => 'الدولة غير موجودة';

  @override
  String get countryNotFoundBody => 'لا توجد دولة بهذا الرمز.';

  @override
  String get countryNotFoundBack => 'العودة إلى الاستكشاف';

  @override
  String get pageNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get pageNotFoundBody => 'هذه الصفحة غير موجودة.';

  @override
  String get placeholderBody => 'هذه الشاشة قيد الإنشاء.';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get accountGuestTitle => 'احفظ رحلاتك احتياطيًا';

  @override
  String get accountGuestBody =>
      'سجّل الدخول لحفظ رحلاتك احتياطيًا ورؤيتها على جميع أجهزتك.';

  @override
  String get accountSignIn => 'تسجيل الدخول';

  @override
  String get accountSettings => 'الإعدادات';

  @override
  String get signInTitle => 'تسجيل الدخول';

  @override
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeSystem => 'حسب النظام';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystem => 'حسب النظام';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';
}
