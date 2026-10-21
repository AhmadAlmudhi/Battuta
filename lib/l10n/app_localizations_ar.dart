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

  @override
  String get exploreSearchHint => 'ابحث عن دولة';

  @override
  String get exploreClearSearch => 'مسح البحث';

  @override
  String get exploreFilters => 'التصفية';

  @override
  String exploreFiltersActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'التصفية، $count عاملًا مفعّلًا',
      few: 'التصفية، $count عوامل مفعّلة',
      two: 'التصفية، عاملان مفعّلان',
      one: 'التصفية، عامل واحد مفعّل',
    );
    return '$_temp0';
  }

  @override
  String get exploreSort => 'الترتيب';

  @override
  String get exploreSortNameAsc => 'الاسم، من أ إلى ي';

  @override
  String get exploreSortNameDesc => 'الاسم، من ي إلى أ';

  @override
  String get exploreSortPopulationDesc => 'عدد السكان، من الأعلى إلى الأقل';

  @override
  String get exploreSortPopulationAsc => 'عدد السكان، من الأقل إلى الأعلى';

  @override
  String get exploreSortAreaDesc => 'المساحة، من الأكبر إلى الأصغر';

  @override
  String get exploreSortAreaAsc => 'المساحة، من الأصغر إلى الأكبر';

  @override
  String get exploreMoreOptions => 'خيارات أخرى';

  @override
  String get exploreRefreshData => 'تحديث البيانات';

  @override
  String get exploreOffline => 'أنت غير متصل. تُعرض البيانات المحفوظة.';

  @override
  String get exploreRefreshFailed => 'تعذّر التحديث. تُعرض البيانات المحفوظة.';

  @override
  String get exploreUpToDate => 'البيانات محدّثة.';

  @override
  String get exploreRefreshed => 'تم تحديث بيانات الدول.';

  @override
  String get exploreEmptyTitle => 'لا توجد دول مطابقة.';

  @override
  String get exploreEmptyBody => 'جرّب بحثًا آخر أو عوامل تصفية أقل.';

  @override
  String get exploreClearFilters => 'مسح عوامل التصفية';

  @override
  String get exploreVisited => 'تمت زيارتها';

  @override
  String get exploreOnWishlist => 'في قائمة الأمنيات';

  @override
  String flagLabel(String country) {
    return 'علم $country';
  }

  @override
  String get filtersTitle => 'التصفية';

  @override
  String get filtersRegion => 'المنطقة';

  @override
  String get filtersSubregion => 'المنطقة الفرعية';

  @override
  String get filtersLanguage => 'اللغة';

  @override
  String get filtersCurrency => 'العملة';

  @override
  String get filtersAnyLanguage => 'أي لغة';

  @override
  String get filtersAnyCurrency => 'أي عملة';

  @override
  String get filtersClearAll => 'مسح الكل';

  @override
  String filtersShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض $count دولة',
      many: 'عرض $count دولة',
      few: 'عرض $count دول',
      two: 'عرض دولتين',
      one: 'عرض دولة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String get filtersClose => 'إغلاق';

  @override
  String get regionAfrica => 'أفريقيا';

  @override
  String get regionAmericas => 'الأمريكتان';

  @override
  String get regionAntarctic => 'القارة القطبية الجنوبية';

  @override
  String get regionAsia => 'آسيا';

  @override
  String get regionEurope => 'أوروبا';

  @override
  String get regionOceania => 'أوقيانوسيا';

  @override
  String get subregionEasternAfrica => 'شرق أفريقيا';

  @override
  String get subregionMiddleAfrica => 'وسط أفريقيا';

  @override
  String get subregionNorthernAfrica => 'شمال أفريقيا';

  @override
  String get subregionSouthernAfrica => 'جنوب أفريقيا';

  @override
  String get subregionWesternAfrica => 'غرب أفريقيا';

  @override
  String get subregionCaribbean => 'الكاريبي';

  @override
  String get subregionCentralAmerica => 'أمريكا الوسطى';

  @override
  String get subregionNorthAmerica => 'أمريكا الشمالية';

  @override
  String get subregionSouthAmerica => 'أمريكا الجنوبية';

  @override
  String get subregionCentralAsia => 'آسيا الوسطى';

  @override
  String get subregionEasternAsia => 'شرق آسيا';

  @override
  String get subregionSouthEasternAsia => 'جنوب شرق آسيا';

  @override
  String get subregionSouthernAsia => 'جنوب آسيا';

  @override
  String get subregionWesternAsia => 'غرب آسيا';

  @override
  String get subregionCentralEurope => 'أوروبا الوسطى';

  @override
  String get subregionEasternEurope => 'أوروبا الشرقية';

  @override
  String get subregionNorthernEurope => 'أوروبا الشمالية';

  @override
  String get subregionSoutheastEurope => 'جنوب شرق أوروبا';

  @override
  String get subregionSouthernEurope => 'أوروبا الجنوبية';

  @override
  String get subregionWesternEurope => 'أوروبا الغربية';

  @override
  String get subregionAustraliaNewZealand => 'أستراليا ونيوزيلندا';

  @override
  String get subregionMelanesia => 'ميلانيزيا';

  @override
  String get subregionMicronesia => 'ميكرونيزيا';

  @override
  String get subregionPolynesia => 'بولينيزيا';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonUndo => 'تراجع';

  @override
  String get commonNotAvailable => 'غير متوفر';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get listSeparator => '، ';

  @override
  String get detailsFacts => 'معلومات أساسية';

  @override
  String get detailsCapital => 'العاصمة';

  @override
  String get detailsRegion => 'المنطقة';

  @override
  String get detailsSubregion => 'المنطقة الفرعية';

  @override
  String get detailsPopulation => 'عدد السكان';

  @override
  String get detailsArea => 'المساحة';

  @override
  String detailsAreaValue(String area) {
    return '$area كم²';
  }

  @override
  String get detailsLanguages => 'اللغات';

  @override
  String get detailsCurrencies => 'العملات';

  @override
  String get detailsTimezones => 'المناطق الزمنية';

  @override
  String get detailsNeighbors => 'الدول المجاورة';

  @override
  String get detailsNoLandBorders => 'لا توجد حدود برية';

  @override
  String get detailsOpenInMaps => 'فتح في الخرائط';

  @override
  String get detailsOpenInMapsOffline => 'تحتاج الخرائط إلى اتصال بالإنترنت.';

  @override
  String get detailsMarkVisited => 'سجّل زيارتك';

  @override
  String get detailsAddToWishlist => 'أضف إلى قائمة الأمنيات';

  @override
  String get detailsEdit => 'تعديل';

  @override
  String get detailsRemove => 'إزالة';

  @override
  String get detailsVisited => 'تمت زيارتها';

  @override
  String detailsVisitedOn(String date) {
    return 'تمت الزيارة في $date';
  }

  @override
  String get detailsOnWishlist => 'في قائمة أمنياتك';

  @override
  String detailsTargetYear(String year) {
    return 'السنة المستهدفة $year';
  }

  @override
  String detailsRemoved(String country) {
    return 'تمت إزالة $country.';
  }

  @override
  String detailsRating(int rating) {
    String _temp0 = intl.Intl.pluralLogic(
      rating,
      locale: localeName,
      other: '$rating نجوم من 5',
      few: '$rating نجوم من 5',
      two: 'نجمتان من 5',
      one: 'نجمة واحدة من 5',
    );
    return '$_temp0';
  }

  @override
  String get stampVisited => 'تمت الزيارة';

  @override
  String get priorityHigh => 'أولوية عالية';

  @override
  String get priorityMedium => 'أولوية متوسطة';

  @override
  String get priorityLow => 'أولوية منخفضة';

  @override
  String get priorityHighShort => 'عالية';

  @override
  String get priorityMediumShort => 'متوسطة';

  @override
  String get priorityLowShort => 'منخفضة';

  @override
  String visitFormTitle(String country) {
    return 'زيارتك إلى $country';
  }

  @override
  String get visitFormDate => 'تاريخ الزيارة';

  @override
  String get visitFormAddDate => 'إضافة تاريخ';

  @override
  String get visitFormClearDate => 'مسح التاريخ';

  @override
  String get visitFormRating => 'التقييم';

  @override
  String get visitFormClearRating => 'مسح التقييم';

  @override
  String get formNotes => 'ملاحظات';

  @override
  String get formNotesHint => 'اختيارية';

  @override
  String wishlistFormTitle(String country) {
    return '$country في قائمة أمنياتك';
  }

  @override
  String get wishlistFormPriority => 'الأولوية';

  @override
  String get wishlistFormTargetYear => 'السنة المستهدفة';

  @override
  String get wishlistFormNoTargetYear => 'بدون سنة محددة';

  @override
  String get validationVisitDateFuture =>
      'لا يمكن أن يكون تاريخ الزيارة في المستقبل.';

  @override
  String get validationNotesTooLong => 'يمكن أن تصل الملاحظات إلى 500 حرف.';

  @override
  String travelsVisitedTab(int count) {
    return 'تمت زيارتها ($count)';
  }

  @override
  String travelsWishlistTab(int count) {
    return 'قائمة الأمنيات ($count)';
  }

  @override
  String get travelsSearchHint => 'ابحث في رحلاتك';

  @override
  String get travelsSortByDate => 'تاريخ الزيارة، الأحدث أولًا';

  @override
  String get travelsSortByPriority => 'الأولوية، ثم السنة المستهدفة';

  @override
  String get travelsNoDate => 'بدون تاريخ';

  @override
  String get travelsEmptyVisitedTitle => 'لا توجد زيارات بعد';

  @override
  String get travelsEmptyVisitedBody => 'ستظهر هنا الدول التي تسجّل زيارتها.';

  @override
  String get travelsEmptyWishlistTitle => 'قائمة أمنياتك فارغة';

  @override
  String get travelsEmptyWishlistBody =>
      'أضف الدول التي ترغب في زيارتها لاحقًا.';

  @override
  String get travelsExplore => 'استكشف الدول';

  @override
  String get travelsNoMatchesTitle => 'لا توجد نتائج مطابقة.';

  @override
  String get travelsClearFilters => 'مسح البحث وعوامل التصفية';

  @override
  String travelsEntryMenu(String country) {
    return 'خيارات $country';
  }

  @override
  String get travelsDelete => 'حذف';

  @override
  String travelsDeleted(String country) {
    return 'تم حذف $country.';
  }

  @override
  String get statsCountriesVisited => 'الدول التي زرتها';

  @override
  String statsOfTotal(String total, String percent, String wishlist) {
    return 'من $total · $percent% · $wishlist في قائمة أمنياتك';
  }

  @override
  String statsHeadlineLabel(String visited, String total, String percent) {
    return 'زرت $visited من $total دولة، أي $percent بالمئة';
  }

  @override
  String get statsByRegion => 'حسب المنطقة';

  @override
  String statsRegionCount(String visited, String total) {
    return '$visited من $total';
  }

  @override
  String get statsHighlights => 'أبرز الأرقام';

  @override
  String get statsWishlistSize => 'في قائمة أمنياتك';

  @override
  String get statsLatestTrip => 'أحدث رحلة';

  @override
  String get statsFirstTrip => 'أول رحلة';

  @override
  String get statsNoDates => 'أضف تواريخ الزيارات لعرض ذلك.';

  @override
  String get statsEmptyTitle => 'لم تسجّل زيارة أي دولة بعد';

  @override
  String get statsEmptyBody => 'سجّل زيارتك لأول دولة لترى تقدّمك هنا.';

  @override
  String mapSemanticsLabel(String visited, String wishlist) {
    return 'خريطة العالم: زرت $visited دولة، و$wishlist في قائمة أمنياتك';
  }

  @override
  String get mapViewAsList => 'عرض كقائمة';

  @override
  String get mapLegendVisited => 'تمت زيارتها';

  @override
  String get mapLegendWishlist => 'قائمة الأمنيات';

  @override
  String get mapLegendNotYet => 'ليس بعد';

  @override
  String get mapLegendDots => 'تظهر الدول الصغيرة كنقاط';

  @override
  String get mapNotVisited => 'لم تزرها بعد';

  @override
  String get mapOpenDetails => 'عرض التفاصيل';

  @override
  String get mapRegionAll => 'الكل';

  @override
  String get mapZoomIn => 'تكبير';

  @override
  String get mapZoomOut => 'تصغير';

  @override
  String get mapResetView => 'إعادة تعيين العرض';

  @override
  String get mapReplay => 'استعرض رحلاتي';

  @override
  String get mapReplaySkip => 'تخطي';

  @override
  String get mapShare => 'شارك خريطتي';

  @override
  String mapRegionSummary(String region, String visited, String wishlist) {
    return '$region · زرت $visited · $wishlist في قائمة أمنياتك';
  }

  @override
  String get statsShowOnMap => 'عرض على الخريطة';

  @override
  String statsRegionLabel(String region, String count) {
    return '$region، $count';
  }

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSignUpIntro =>
      'احفظ رحلاتك احتياطيًا وشاهدها على جميع أجهزتك.';

  @override
  String get authResetIntro =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get authSendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get authResetSent =>
      'إذا كان هناك حساب بهذا البريد، فسيصلك رابط إعادة التعيين قريبًا.';

  @override
  String get authBackToSignIn => 'العودة إلى تسجيل الدخول';

  @override
  String get validationEmail => 'أدخل بريدًا إلكترونيًا صحيحًا.';

  @override
  String get validationPasswordRequired => 'أدخل كلمة المرور.';

  @override
  String get validationPasswordLength => 'يجب ألا تقل كلمة المرور عن 8 أحرف.';

  @override
  String get validationPasswordsMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get authErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authErrorEmailInUse => 'يوجد حساب بهذا البريد الإلكتروني بالفعل.';

  @override
  String get authErrorTooManyRequests =>
      'محاولات كثيرة. حاول مرة أخرى بعد بضع دقائق.';

  @override
  String get authErrorNetwork =>
      'لا يوجد اتصال. تحقّق من الشبكة وحاول مرة أخرى.';

  @override
  String get authErrorUnknown => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get accountSignedInAs => 'مسجّل الدخول باسم';

  @override
  String get accountSyncNow => 'مزامنة الآن';

  @override
  String get accountSignOut => 'تسجيل الخروج';

  @override
  String accountLastSynced(String time) {
    return 'تم الحفظ الاحتياطي. آخر مزامنة $time.';
  }

  @override
  String get accountNotSyncedYet => 'لم تتم المزامنة بعد.';

  @override
  String get accountSyncing => 'جارٍ المزامنة…';

  @override
  String get accountSyncOffline =>
      'أنت غير متصل. ستُرفع التغييرات عند عودة الاتصال.';

  @override
  String get accountSyncFailed => 'تعذّرت المزامنة. سنحاول مرة أخرى.';

  @override
  String get accountSignOutTitle => 'تسجيل الخروج؟';

  @override
  String get accountSignOutBody =>
      'تبقى رحلاتك محفوظة في حسابك، وستُزال من هذا الجهاز.';

  @override
  String accountSignOutUnsynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغييرًا لم تُحفظ احتياطيًا بعد وستُفقد.',
      few: '$count تغييرات لم تُحفظ احتياطيًا بعد وستُفقد.',
      two: 'تغييران لم يُحفظا احتياطيًا بعد وسيُفقدان.',
      one: 'تغيير واحد لم يُحفظ احتياطيًا بعد وسيُفقد.',
    );
    return '$_temp0';
  }

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsCountryData => 'بيانات الدول';

  @override
  String settingsCountryDataUpdated(String date) {
    return 'حُدّثت في $date';
  }

  @override
  String get settingsDataSource => 'مصدر البيانات';

  @override
  String get settingsDataSourceValue =>
      'بيانات الدول والأعلام من REST Countries';

  @override
  String get settingsMapSource => 'بيانات الخريطة';

  @override
  String get settingsMapSourceValue =>
      'خريطة العالم من Natural Earth، وتظهر الحدود المتنازع عليها كما تعترف بها المملكة العربية السعودية.';

  @override
  String get settingsLicenses => 'تراخيص المصادر المفتوحة';
}
