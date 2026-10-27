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

  /// Shown while a manual refresh downloads country data (FR-EXP-11).
  ///
  /// In en, this message translates to:
  /// **'Updating country data. This can take up to a minute.'**
  String get exploreRefreshing;

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

  /// No description provided for @exploreWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get exploreWishlist;

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

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get commonNotAvailable;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Joins list items, for example languages.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @detailsFacts.
  ///
  /// In en, this message translates to:
  /// **'Facts'**
  String get detailsFacts;

  /// No description provided for @detailsCapital.
  ///
  /// In en, this message translates to:
  /// **'Capital'**
  String get detailsCapital;

  /// No description provided for @detailsRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get detailsRegion;

  /// No description provided for @detailsSubregion.
  ///
  /// In en, this message translates to:
  /// **'Subregion'**
  String get detailsSubregion;

  /// No description provided for @detailsPopulation.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get detailsPopulation;

  /// No description provided for @detailsArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get detailsArea;

  /// No description provided for @detailsAreaValue.
  ///
  /// In en, this message translates to:
  /// **'{area} km²'**
  String detailsAreaValue(String area);

  /// No description provided for @detailsLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get detailsLanguages;

  /// No description provided for @detailsCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get detailsCurrencies;

  /// No description provided for @detailsTimezones.
  ///
  /// In en, this message translates to:
  /// **'Time zones'**
  String get detailsTimezones;

  /// Under a country's time zone range on Country details (FR-DET-02).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time zone} other{{count} time zones}}'**
  String detailsTimezoneCount(int count);

  /// No description provided for @detailsNeighbors.
  ///
  /// In en, this message translates to:
  /// **'Neighboring countries'**
  String get detailsNeighbors;

  /// No description provided for @detailsNoLandBorders.
  ///
  /// In en, this message translates to:
  /// **'No land borders'**
  String get detailsNoLandBorders;

  /// No description provided for @detailsOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get detailsOpenInMaps;

  /// No description provided for @detailsOpenInMapsOffline.
  ///
  /// In en, this message translates to:
  /// **'Maps needs a connection.'**
  String get detailsOpenInMapsOffline;

  /// No description provided for @detailsMarkVisited.
  ///
  /// In en, this message translates to:
  /// **'Mark as visited'**
  String get detailsMarkVisited;

  /// No description provided for @detailsAddToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get detailsAddToWishlist;

  /// No description provided for @detailsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get detailsEdit;

  /// No description provided for @detailsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get detailsRemove;

  /// No description provided for @detailsVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get detailsVisited;

  /// No description provided for @detailsVisitedOn.
  ///
  /// In en, this message translates to:
  /// **'Visited on {date}'**
  String detailsVisitedOn(String date);

  /// No description provided for @detailsOnWishlist.
  ///
  /// In en, this message translates to:
  /// **'On your wishlist'**
  String get detailsOnWishlist;

  /// No description provided for @detailsTargetYear.
  ///
  /// In en, this message translates to:
  /// **'Target year {year}'**
  String detailsTargetYear(String year);

  /// No description provided for @detailsRemoved.
  ///
  /// In en, this message translates to:
  /// **'{country} removed.'**
  String detailsRemoved(String country);

  /// No description provided for @detailsRating.
  ///
  /// In en, this message translates to:
  /// **'{rating, plural, =1{1 of 5 stars} other{{rating} of 5 stars}}'**
  String detailsRating(int rating);

  /// No description provided for @stampVisited.
  ///
  /// In en, this message translates to:
  /// **'VISITED'**
  String get stampVisited;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium priority'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low priority'**
  String get priorityLow;

  /// No description provided for @priorityHighShort.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHighShort;

  /// No description provided for @priorityMediumShort.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMediumShort;

  /// No description provided for @priorityLowShort.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLowShort;

  /// No description provided for @visitFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Your visit to {country}'**
  String visitFormTitle(String country);

  /// No description provided for @visitFormDate.
  ///
  /// In en, this message translates to:
  /// **'Visit date'**
  String get visitFormDate;

  /// No description provided for @visitFormAddDate.
  ///
  /// In en, this message translates to:
  /// **'Add date'**
  String get visitFormAddDate;

  /// No description provided for @visitFormClearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get visitFormClearDate;

  /// No description provided for @visitFormRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get visitFormRating;

  /// No description provided for @visitFormClearRating.
  ///
  /// In en, this message translates to:
  /// **'Clear rating'**
  String get visitFormClearRating;

  /// No description provided for @formNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get formNotes;

  /// No description provided for @formNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get formNotesHint;

  /// No description provided for @wishlistFormTitle.
  ///
  /// In en, this message translates to:
  /// **'{country} on your wishlist'**
  String wishlistFormTitle(String country);

  /// No description provided for @wishlistFormPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get wishlistFormPriority;

  /// No description provided for @wishlistFormTargetYear.
  ///
  /// In en, this message translates to:
  /// **'Target year'**
  String get wishlistFormTargetYear;

  /// No description provided for @wishlistFormNoTargetYear.
  ///
  /// In en, this message translates to:
  /// **'No target year'**
  String get wishlistFormNoTargetYear;

  /// No description provided for @validationVisitDateFuture.
  ///
  /// In en, this message translates to:
  /// **'Visit date can\'t be in the future.'**
  String get validationVisitDateFuture;

  /// No description provided for @validationNotesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Notes can be up to 500 characters.'**
  String get validationNotesTooLong;

  /// No description provided for @travelsVisitedTab.
  ///
  /// In en, this message translates to:
  /// **'Visited ({count})'**
  String travelsVisitedTab(int count);

  /// No description provided for @travelsWishlistTab.
  ///
  /// In en, this message translates to:
  /// **'Wishlist ({count})'**
  String travelsWishlistTab(int count);

  /// No description provided for @travelsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your travels'**
  String get travelsSearchHint;

  /// No description provided for @travelsSortByDate.
  ///
  /// In en, this message translates to:
  /// **'Visit date, newest first'**
  String get travelsSortByDate;

  /// No description provided for @travelsSortByPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority, then target year'**
  String get travelsSortByPriority;

  /// No description provided for @travelsNoDate.
  ///
  /// In en, this message translates to:
  /// **'Date not set'**
  String get travelsNoDate;

  /// No description provided for @travelsEmptyVisitedTitle.
  ///
  /// In en, this message translates to:
  /// **'No visits yet'**
  String get travelsEmptyVisitedTitle;

  /// No description provided for @travelsEmptyVisitedBody.
  ///
  /// In en, this message translates to:
  /// **'Countries you mark as visited appear here.'**
  String get travelsEmptyVisitedBody;

  /// No description provided for @travelsEmptyWishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get travelsEmptyWishlistTitle;

  /// No description provided for @travelsEmptyWishlistBody.
  ///
  /// In en, this message translates to:
  /// **'Add the countries you want to visit next.'**
  String get travelsEmptyWishlistBody;

  /// No description provided for @travelsExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore countries'**
  String get travelsExplore;

  /// No description provided for @travelsNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries match.'**
  String get travelsNoMatchesTitle;

  /// No description provided for @travelsClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get travelsClearFilters;

  /// No description provided for @travelsEntryMenu.
  ///
  /// In en, this message translates to:
  /// **'Options for {country}'**
  String travelsEntryMenu(String country);

  /// No description provided for @travelsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get travelsDelete;

  /// No description provided for @travelsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{country} deleted.'**
  String travelsDeleted(String country);

  /// No description provided for @statsCountriesVisited.
  ///
  /// In en, this message translates to:
  /// **'Countries visited'**
  String get statsCountriesVisited;

  /// Under the visited count, for example: of 250 · 6.4% · 12 on your wishlist (FR-STA-01, FR-MAP-02).
  ///
  /// In en, this message translates to:
  /// **'of {total} · {percent}% · {wishlist} on your wishlist'**
  String statsOfTotal(String total, String percent, String wishlist);

  /// Screen-reader label for the headline.
  ///
  /// In en, this message translates to:
  /// **'{visited} of {total} countries visited, {percent} percent'**
  String statsHeadlineLabel(String visited, String total, String percent);

  /// No description provided for @statsByRegion.
  ///
  /// In en, this message translates to:
  /// **'By region'**
  String get statsByRegion;

  /// No description provided for @statsRegionCount.
  ///
  /// In en, this message translates to:
  /// **'{visited} of {total}'**
  String statsRegionCount(String visited, String total);

  /// No description provided for @statsHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get statsHighlights;

  /// No description provided for @statsWishlistSize.
  ///
  /// In en, this message translates to:
  /// **'On your wishlist'**
  String get statsWishlistSize;

  /// No description provided for @statsLatestTrip.
  ///
  /// In en, this message translates to:
  /// **'Most recent trip'**
  String get statsLatestTrip;

  /// No description provided for @statsFirstTrip.
  ///
  /// In en, this message translates to:
  /// **'First trip'**
  String get statsFirstTrip;

  /// No description provided for @statsNoDates.
  ///
  /// In en, this message translates to:
  /// **'Add visit dates to see this.'**
  String get statsNoDates;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No countries visited yet'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Mark your first country as visited to see your progress here.'**
  String get statsEmptyBody;

  /// Screen-reader label for the world map (FR-MAP-08).
  ///
  /// In en, this message translates to:
  /// **'World map: {visited} countries visited, {wishlist} on your wishlist'**
  String mapSemanticsLabel(String visited, String wishlist);

  /// No description provided for @mapViewAsList.
  ///
  /// In en, this message translates to:
  /// **'View as list'**
  String get mapViewAsList;

  /// No description provided for @mapLegendVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get mapLegendVisited;

  /// No description provided for @mapLegendWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get mapLegendWishlist;

  /// No description provided for @mapLegendNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get mapLegendNotYet;

  /// No description provided for @mapLegendDots.
  ///
  /// In en, this message translates to:
  /// **'Small countries appear as dots'**
  String get mapLegendDots;

  /// No description provided for @mapNotVisited.
  ///
  /// In en, this message translates to:
  /// **'Not visited yet'**
  String get mapNotVisited;

  /// No description provided for @mapOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get mapOpenDetails;

  /// No description provided for @mapRegionAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mapRegionAll;

  /// No description provided for @mapZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get mapZoomOut;

  /// No description provided for @mapResetView.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get mapResetView;

  /// No description provided for @mapReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay my travels'**
  String get mapReplay;

  /// No description provided for @mapReplaySkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get mapReplaySkip;

  /// No description provided for @mapShare.
  ///
  /// In en, this message translates to:
  /// **'Share my map'**
  String get mapShare;

  /// Over the map during a region focus, for example: Europe · 4 visited · 3 on your wishlist (FR-MAP-24).
  ///
  /// In en, this message translates to:
  /// **'{region} · {visited} visited · {wishlist} on your wishlist'**
  String mapRegionSummary(String region, String visited, String wishlist);

  /// No description provided for @statsShowOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on the map'**
  String get statsShowOnMap;

  /// Screen-reader label for a region bar, for example: Europe, 4 of 53.
  ///
  /// In en, this message translates to:
  /// **'{region}, {count}'**
  String statsRegionLabel(String region, String count);

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authSignUpIntro.
  ///
  /// In en, this message translates to:
  /// **'Back up your travels and see them on all your devices.'**
  String get authSignUpIntro;

  /// No description provided for @authResetIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get authResetIntro;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authResetSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link is on its way.'**
  String get authResetSent;

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmail;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get validationPasswordLength;

  /// No description provided for @validationPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get validationPasswordsMatch;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a few minutes.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorUnknown;

  /// No description provided for @accountSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get accountSignedInAs;

  /// No description provided for @accountSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get accountSyncNow;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Backed up. Last synced {time}.'**
  String accountLastSynced(String time);

  /// No description provided for @accountNotSyncedYet.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet.'**
  String get accountNotSyncedYet;

  /// No description provided for @accountSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get accountSyncing;

  /// No description provided for @accountSyncOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes will upload when you\'re back online.'**
  String get accountSyncOffline;

  /// No description provided for @accountSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync. We\'ll try again.'**
  String get accountSyncFailed;

  /// No description provided for @accountSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountSignOutTitle;

  /// No description provided for @accountSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your travels stay backed up in your account and are removed from this device.'**
  String get accountSignOutBody;

  /// No description provided for @accountSignOutUnsynced.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change hasn\'t been backed up yet and will be lost.} other{{count} changes haven\'t been backed up yet and will be lost.}}'**
  String accountSignOutUnsynced(int count);

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsCountryData.
  ///
  /// In en, this message translates to:
  /// **'Country data'**
  String get settingsCountryData;

  /// No description provided for @settingsCountryDataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String settingsCountryDataUpdated(String date);

  /// No description provided for @settingsDataSource.
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get settingsDataSource;

  /// No description provided for @settingsDataSourceValue.
  ///
  /// In en, this message translates to:
  /// **'Country data and flags from REST Countries'**
  String get settingsDataSourceValue;

  /// No description provided for @settingsMapSource.
  ///
  /// In en, this message translates to:
  /// **'Map data'**
  String get settingsMapSource;

  /// No description provided for @settingsMapSourceValue.
  ///
  /// In en, this message translates to:
  /// **'World map from Natural Earth. Disputed borders are shown as Saudi Arabia recognizes them.'**
  String get settingsMapSourceValue;

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get settingsLicenses;
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
