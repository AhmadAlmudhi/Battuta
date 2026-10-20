import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Battuta'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Every country, stamped.'**
  String get appTagline;

  /// Browser tab title (FR-PLT-07), for example Japan · Battuta.
  ///
  /// In en, this message translates to:
  /// **'{screen} · {appName}'**
  String pageTitle(String screen, String appName);

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navTravels.
  ///
  /// In en, this message translates to:
  /// **'My travels'**
  String get navTravels;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Battuta'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Explore every country, record where you\'ve been, and plan where to go next.'**
  String get welcomeBody;

  /// No description provided for @welcomeContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get welcomeContinueAsGuest;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get welcomeSignIn;

  /// No description provided for @exploreCountryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 country} other{{count} countries}}'**
  String exploreCountryCount(int count);

  /// No description provided for @exploreLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load countries.'**
  String get exploreLoadError;

  /// No description provided for @countryNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Country not found'**
  String get countryNotFoundTitle;

  /// No description provided for @countryNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'There\'s no country with this code.'**
  String get countryNotFoundBody;

  /// No description provided for @countryNotFoundBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Explore'**
  String get countryNotFoundBack;

  /// No description provided for @pageNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFoundTitle;

  /// No description provided for @pageNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist.'**
  String get pageNotFoundBody;

  /// No description provided for @placeholderBody.
  ///
  /// In en, this message translates to:
  /// **'This screen is under construction.'**
  String get placeholderBody;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Back up your travels'**
  String get accountGuestTitle;

  /// No description provided for @accountGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up your travels and see them on all your devices.'**
  String get accountGuestBody;

  /// No description provided for @accountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignIn;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get accountSettings;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get exploreSearchHint;

  /// No description provided for @exploreClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get exploreClearSearch;

  /// No description provided for @exploreFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get exploreFilters;

  /// Screen-reader label for the Filters button when filters are active.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Filters, 1 active} other{Filters, {count} active}}'**
  String exploreFiltersActive(int count);

  /// No description provided for @exploreSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get exploreSort;

  /// No description provided for @exploreSortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name, A to Z'**
  String get exploreSortNameAsc;

  /// No description provided for @exploreSortNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name, Z to A'**
  String get exploreSortNameDesc;

  /// No description provided for @exploreSortPopulationDesc.
  ///
  /// In en, this message translates to:
  /// **'Population, high to low'**
  String get exploreSortPopulationDesc;

  /// No description provided for @exploreSortPopulationAsc.
  ///
  /// In en, this message translates to:
  /// **'Population, low to high'**
  String get exploreSortPopulationAsc;

  /// No description provided for @exploreSortAreaDesc.
  ///
  /// In en, this message translates to:
  /// **'Area, largest first'**
  String get exploreSortAreaDesc;

  /// No description provided for @exploreSortAreaAsc.
  ///
  /// In en, this message translates to:
  /// **'Area, smallest first'**
  String get exploreSortAreaAsc;

  /// No description provided for @exploreMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get exploreMoreOptions;

  /// No description provided for @exploreRefreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh data'**
  String get exploreRefreshData;

  /// No description provided for @exploreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing saved data.'**
  String get exploreOffline;

  /// No description provided for @exploreRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh. Showing saved data.'**
  String get exploreRefreshFailed;

  /// No description provided for @exploreUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Data is up to date.'**
  String get exploreUpToDate;

  /// No description provided for @exploreRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Country data updated.'**
  String get exploreRefreshed;

  /// No description provided for @exploreEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No countries match.'**
  String get exploreEmptyTitle;

  /// No description provided for @exploreEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or fewer filters.'**
  String get exploreEmptyBody;

  /// No description provided for @exploreClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get exploreClearFilters;

  /// No description provided for @exploreVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get exploreVisited;

  /// No description provided for @exploreOnWishlist.
  ///
  /// In en, this message translates to:
  /// **'On wishlist'**
  String get exploreOnWishlist;

  /// No description provided for @flagLabel.
  ///
  /// In en, this message translates to:
  /// **'Flag of {country}'**
  String flagLabel(String country);

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filtersRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get filtersRegion;

  /// No description provided for @filtersSubregion.
  ///
  /// In en, this message translates to:
  /// **'Subregion'**
  String get filtersSubregion;

  /// No description provided for @filtersLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get filtersLanguage;

  /// No description provided for @filtersCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get filtersCurrency;

  /// No description provided for @filtersAnyLanguage.
  ///
  /// In en, this message translates to:
  /// **'Any language'**
  String get filtersAnyLanguage;

  /// No description provided for @filtersAnyCurrency.
  ///
  /// In en, this message translates to:
  /// **'Any currency'**
  String get filtersAnyCurrency;

  /// No description provided for @filtersClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filtersClearAll;

  /// No description provided for @filtersShowResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matches} =1{Show 1 country} other{Show {count} countries}}'**
  String filtersShowResults(int count);

  /// No description provided for @filtersClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get filtersClose;

  /// No description provided for @regionAfrica.
  ///
  /// In en, this message translates to:
  /// **'Africa'**
  String get regionAfrica;

  /// No description provided for @regionAmericas.
  ///
  /// In en, this message translates to:
  /// **'Americas'**
  String get regionAmericas;

  /// No description provided for @regionAntarctic.
  ///
  /// In en, this message translates to:
  /// **'Antarctic'**
  String get regionAntarctic;

  /// No description provided for @regionAsia.
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get regionAsia;

  /// No description provided for @regionEurope.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get regionEurope;

  /// No description provided for @regionOceania.
  ///
  /// In en, this message translates to:
  /// **'Oceania'**
  String get regionOceania;

  /// No description provided for @subregionEasternAfrica.
  ///
  /// In en, this message translates to:
  /// **'Eastern Africa'**
  String get subregionEasternAfrica;

  /// No description provided for @subregionMiddleAfrica.
  ///
  /// In en, this message translates to:
  /// **'Middle Africa'**
  String get subregionMiddleAfrica;

  /// No description provided for @subregionNorthernAfrica.
  ///
  /// In en, this message translates to:
  /// **'Northern Africa'**
  String get subregionNorthernAfrica;

  /// No description provided for @subregionSouthernAfrica.
  ///
  /// In en, this message translates to:
  /// **'Southern Africa'**
  String get subregionSouthernAfrica;

  /// No description provided for @subregionWesternAfrica.
  ///
  /// In en, this message translates to:
  /// **'Western Africa'**
  String get subregionWesternAfrica;

  /// No description provided for @subregionCaribbean.
  ///
  /// In en, this message translates to:
  /// **'Caribbean'**
  String get subregionCaribbean;

  /// No description provided for @subregionCentralAmerica.
  ///
  /// In en, this message translates to:
  /// **'Central America'**
  String get subregionCentralAmerica;

  /// No description provided for @subregionNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'North America'**
  String get subregionNorthAmerica;

  /// No description provided for @subregionSouthAmerica.
  ///
  /// In en, this message translates to:
  /// **'South America'**
  String get subregionSouthAmerica;

  /// No description provided for @subregionCentralAsia.
  ///
  /// In en, this message translates to:
  /// **'Central Asia'**
  String get subregionCentralAsia;

  /// No description provided for @subregionEasternAsia.
  ///
  /// In en, this message translates to:
  /// **'Eastern Asia'**
  String get subregionEasternAsia;

  /// No description provided for @subregionSouthEasternAsia.
  ///
  /// In en, this message translates to:
  /// **'South-Eastern Asia'**
  String get subregionSouthEasternAsia;

  /// No description provided for @subregionSouthernAsia.
  ///
  /// In en, this message translates to:
  /// **'Southern Asia'**
  String get subregionSouthernAsia;

  /// No description provided for @subregionWesternAsia.
  ///
  /// In en, this message translates to:
  /// **'Western Asia'**
  String get subregionWesternAsia;

  /// No description provided for @subregionCentralEurope.
  ///
  /// In en, this message translates to:
  /// **'Central Europe'**
  String get subregionCentralEurope;

  /// No description provided for @subregionEasternEurope.
  ///
  /// In en, this message translates to:
  /// **'Eastern Europe'**
  String get subregionEasternEurope;

  /// No description provided for @subregionNorthernEurope.
  ///
  /// In en, this message translates to:
  /// **'Northern Europe'**
  String get subregionNorthernEurope;

  /// No description provided for @subregionSoutheastEurope.
  ///
  /// In en, this message translates to:
  /// **'Southeast Europe'**
  String get subregionSoutheastEurope;

  /// No description provided for @subregionSouthernEurope.
  ///
  /// In en, this message translates to:
  /// **'Southern Europe'**
  String get subregionSouthernEurope;

  /// No description provided for @subregionWesternEurope.
  ///
  /// In en, this message translates to:
  /// **'Western Europe'**
  String get subregionWesternEurope;

  /// No description provided for @subregionAustraliaNewZealand.
  ///
  /// In en, this message translates to:
  /// **'Australia and New Zealand'**
  String get subregionAustraliaNewZealand;

  /// No description provided for @subregionMelanesia.
  ///
  /// In en, this message translates to:
  /// **'Melanesia'**
  String get subregionMelanesia;

  /// No description provided for @subregionMicronesia.
  ///
  /// In en, this message translates to:
  /// **'Micronesia'**
  String get subregionMicronesia;

  /// No description provided for @subregionPolynesia.
  ///
  /// In en, this message translates to:
  /// **'Polynesia'**
  String get subregionPolynesia;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
