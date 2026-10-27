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

  @override
  String get exploreSearchHint => 'Search countries';

  @override
  String get exploreClearSearch => 'Clear search';

  @override
  String get exploreFilters => 'Filters';

  @override
  String exploreFiltersActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filters, $count active',
      one: 'Filters, 1 active',
    );
    return '$_temp0';
  }

  @override
  String get exploreSort => 'Sort';

  @override
  String get exploreSortNameAsc => 'Name, A to Z';

  @override
  String get exploreSortNameDesc => 'Name, Z to A';

  @override
  String get exploreSortPopulationDesc => 'Population, high to low';

  @override
  String get exploreSortPopulationAsc => 'Population, low to high';

  @override
  String get exploreSortAreaDesc => 'Area, largest first';

  @override
  String get exploreSortAreaAsc => 'Area, smallest first';

  @override
  String get exploreMoreOptions => 'More options';

  @override
  String get exploreRefreshData => 'Refresh data';

  @override
  String get exploreOffline => 'You\'re offline. Showing saved data.';

  @override
  String get exploreRefreshFailed => 'Couldn\'t refresh. Showing saved data.';

  @override
  String get exploreUpToDate => 'Data is up to date.';

  @override
  String get exploreRefreshing =>
      'Updating country data. This can take up to a minute.';

  @override
  String get exploreRefreshed => 'Country data updated.';

  @override
  String get exploreEmptyTitle => 'No countries match.';

  @override
  String get exploreEmptyBody => 'Try a different search or fewer filters.';

  @override
  String get exploreClearFilters => 'Clear filters';

  @override
  String get exploreVisited => 'Visited';

  @override
  String get exploreWishlist => 'Wishlist';

  @override
  String flagLabel(String country) {
    return 'Flag of $country';
  }

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersRegion => 'Region';

  @override
  String get filtersSubregion => 'Subregion';

  @override
  String get filtersLanguage => 'Language';

  @override
  String get filtersCurrency => 'Currency';

  @override
  String get filtersAnyLanguage => 'Any language';

  @override
  String get filtersAnyCurrency => 'Any currency';

  @override
  String get filtersClearAll => 'Clear all';

  @override
  String filtersShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count countries',
      one: 'Show 1 country',
      zero: 'No matches',
    );
    return '$_temp0';
  }

  @override
  String get filtersClose => 'Close';

  @override
  String get regionAfrica => 'Africa';

  @override
  String get regionAmericas => 'Americas';

  @override
  String get regionAntarctic => 'Antarctic';

  @override
  String get regionAsia => 'Asia';

  @override
  String get regionEurope => 'Europe';

  @override
  String get regionOceania => 'Oceania';

  @override
  String get subregionEasternAfrica => 'Eastern Africa';

  @override
  String get subregionMiddleAfrica => 'Middle Africa';

  @override
  String get subregionNorthernAfrica => 'Northern Africa';

  @override
  String get subregionSouthernAfrica => 'Southern Africa';

  @override
  String get subregionWesternAfrica => 'Western Africa';

  @override
  String get subregionCaribbean => 'Caribbean';

  @override
  String get subregionCentralAmerica => 'Central America';

  @override
  String get subregionNorthAmerica => 'North America';

  @override
  String get subregionSouthAmerica => 'South America';

  @override
  String get subregionCentralAsia => 'Central Asia';

  @override
  String get subregionEasternAsia => 'Eastern Asia';

  @override
  String get subregionSouthEasternAsia => 'South-Eastern Asia';

  @override
  String get subregionSouthernAsia => 'Southern Asia';

  @override
  String get subregionWesternAsia => 'Western Asia';

  @override
  String get subregionCentralEurope => 'Central Europe';

  @override
  String get subregionEasternEurope => 'Eastern Europe';

  @override
  String get subregionNorthernEurope => 'Northern Europe';

  @override
  String get subregionSoutheastEurope => 'Southeast Europe';

  @override
  String get subregionSouthernEurope => 'Southern Europe';

  @override
  String get subregionWesternEurope => 'Western Europe';

  @override
  String get subregionAustraliaNewZealand => 'Australia and New Zealand';

  @override
  String get subregionMelanesia => 'Melanesia';

  @override
  String get subregionMicronesia => 'Micronesia';

  @override
  String get subregionPolynesia => 'Polynesia';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonNotAvailable => 'Not available';

  @override
  String get commonClose => 'Close';

  @override
  String get listSeparator => ', ';

  @override
  String get detailsFacts => 'Facts';

  @override
  String get detailsCapital => 'Capital';

  @override
  String get detailsRegion => 'Region';

  @override
  String get detailsSubregion => 'Subregion';

  @override
  String get detailsPopulation => 'Population';

  @override
  String get detailsArea => 'Area';

  @override
  String detailsAreaValue(String area) {
    return '$area km²';
  }

  @override
  String get detailsLanguages => 'Languages';

  @override
  String get detailsCurrencies => 'Currencies';

  @override
  String get detailsTimezones => 'Time zones';

  @override
  String detailsTimezoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count time zones',
      one: '1 time zone',
    );
    return '$_temp0';
  }

  @override
  String get detailsNeighbors => 'Neighboring countries';

  @override
  String get detailsNoLandBorders => 'No land borders';

  @override
  String get detailsOpenInMaps => 'Open in Maps';

  @override
  String get detailsOpenInMapsOffline => 'Maps needs a connection.';

  @override
  String get detailsMarkVisited => 'Mark as visited';

  @override
  String get detailsAddToWishlist => 'Add to wishlist';

  @override
  String get detailsEdit => 'Edit';

  @override
  String get detailsRemove => 'Remove';

  @override
  String get detailsVisited => 'Visited';

  @override
  String detailsVisitedOn(String date) {
    return 'Visited on $date';
  }

  @override
  String get detailsOnWishlist => 'On your wishlist';

  @override
  String detailsTargetYear(String year) {
    return 'Target year $year';
  }

  @override
  String detailsRemoved(String country) {
    return '$country removed.';
  }

  @override
  String detailsRating(int rating) {
    String _temp0 = intl.Intl.pluralLogic(
      rating,
      locale: localeName,
      other: '$rating of 5 stars',
      one: '1 of 5 stars',
    );
    return '$_temp0';
  }

  @override
  String get stampVisited => 'VISITED';

  @override
  String get priorityHigh => 'High priority';

  @override
  String get priorityMedium => 'Medium priority';

  @override
  String get priorityLow => 'Low priority';

  @override
  String get priorityHighShort => 'High';

  @override
  String get priorityMediumShort => 'Medium';

  @override
  String get priorityLowShort => 'Low';

  @override
  String visitFormTitle(String country) {
    return 'Your visit to $country';
  }

  @override
  String get visitFormDate => 'Visit date';

  @override
  String get visitFormAddDate => 'Pick a date';

  @override
  String get visitFormRateHint => 'Tap a star to rate';

  @override
  String visitFormRatingWord(String rating) {
    String _temp0 = intl.Intl.selectLogic(rating, {
      '1': 'Not for me',
      '2': 'Okay',
      '3': 'Good',
      '4': 'Great',
      '5': 'Loved it',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get visitFormNotesHint => 'What do you want to remember?';

  @override
  String get visitFormClearDate => 'Clear date';

  @override
  String get visitFormRating => 'Rating';

  @override
  String get visitFormClearRating => 'Clear rating';

  @override
  String get formNotes => 'Notes';

  @override
  String get formOptional => 'Everything here is optional.';

  @override
  String wishlistFormTitle(String country) {
    return '$country on your wishlist';
  }

  @override
  String get wishlistFormPriority => 'Priority';

  @override
  String get wishlistFormTargetYear => 'Target year';

  @override
  String get wishlistFormAnyTime => 'Any time';

  @override
  String get wishlistFormNotesHint => 'What draws you there?';

  @override
  String get validationVisitDateFuture => 'Visit date can\'t be in the future.';

  @override
  String get validationNotesTooLong => 'Notes can be up to 500 characters.';

  @override
  String travelsVisitedTab(int count) {
    return 'Visited ($count)';
  }

  @override
  String travelsWishlistTab(int count) {
    return 'Wishlist ($count)';
  }

  @override
  String get travelsSearchHint => 'Search your travels';

  @override
  String get travelsSortByDate => 'Visit date, newest first';

  @override
  String get travelsSortByPriority => 'Priority, then target year';

  @override
  String get travelsNoDate => 'Date not set';

  @override
  String get travelsEmptyVisitedTitle => 'No visits yet';

  @override
  String get travelsEmptyVisitedBody =>
      'Countries you mark as visited appear here.';

  @override
  String get travelsEmptyWishlistTitle => 'Your wishlist is empty';

  @override
  String get travelsEmptyWishlistBody =>
      'Add the countries you want to visit next.';

  @override
  String get travelsExplore => 'Explore countries';

  @override
  String get travelsNoMatchesTitle => 'No entries match.';

  @override
  String get travelsClearFilters => 'Clear search and filters';

  @override
  String travelsEntryMenu(String country) {
    return 'Options for $country';
  }

  @override
  String get travelsDelete => 'Delete';

  @override
  String travelsDeleted(String country) {
    return '$country deleted.';
  }

  @override
  String get statsCountriesVisited => 'Countries visited';

  @override
  String statsOfTotal(String total, String percent, String wishlist) {
    return 'of $total · $percent% · $wishlist on your wishlist';
  }

  @override
  String statsHeadlineLabel(String visited, String total, String percent) {
    return '$visited of $total countries visited, $percent percent';
  }

  @override
  String get statsByRegion => 'By region';

  @override
  String statsRegionCount(String visited, String total) {
    return '$visited of $total';
  }

  @override
  String get statsHighlights => 'Highlights';

  @override
  String get statsWishlistSize => 'On your wishlist';

  @override
  String get statsLatestTrip => 'Most recent trip';

  @override
  String get statsFirstTrip => 'First trip';

  @override
  String get statsNoDates => 'Add visit dates to see this.';

  @override
  String get statsEmptyTitle => 'No countries visited yet';

  @override
  String get statsEmptyBody =>
      'Mark your first country as visited to see your progress here.';

  @override
  String mapSemanticsLabel(String visited, String wishlist) {
    return 'World map: $visited countries visited, $wishlist on your wishlist';
  }

  @override
  String get mapViewAsList => 'View as list';

  @override
  String get mapLegendVisited => 'Visited';

  @override
  String get mapLegendWishlist => 'Wishlist';

  @override
  String get mapLegendNotYet => 'Not yet';

  @override
  String get mapLegendDots => 'Small countries appear as dots';

  @override
  String get mapNotVisited => 'Not visited yet';

  @override
  String get mapOpenDetails => 'Open details';

  @override
  String get mapRegionAll => 'All';

  @override
  String get mapZoomIn => 'Zoom in';

  @override
  String get mapZoomOut => 'Zoom out';

  @override
  String get mapResetView => 'Reset view';

  @override
  String get mapReplay => 'Replay my travels';

  @override
  String get mapReplaySkip => 'Skip';

  @override
  String get mapShare => 'Share my map';

  @override
  String mapRegionSummary(String region, String visited, String wishlist) {
    return '$region · $visited visited · $wishlist on your wishlist';
  }

  @override
  String get statsShowOnMap => 'Show on the map';

  @override
  String statsRegionLabel(String region, String count) {
    return '$region, $count';
  }

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignUpIntro =>
      'Back up your travels and see them on all your devices.';

  @override
  String get authResetIntro =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authResetSent =>
      'If an account exists for this email, a reset link is on its way.';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get validationEmail => 'Enter a valid email address.';

  @override
  String get validationPasswordRequired => 'Enter your password.';

  @override
  String get validationPasswordLength =>
      'Password must be at least 8 characters.';

  @override
  String get validationPasswordsMatch => 'Passwords don\'t match.';

  @override
  String get authErrorInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get authErrorEmailInUse => 'An account already exists for this email.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Try again in a few minutes.';

  @override
  String get authErrorNetwork =>
      'No connection. Check your network and try again.';

  @override
  String get authErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get accountSignedInAs => 'Signed in as';

  @override
  String get accountSyncNow => 'Sync now';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String accountLastSynced(String time) {
    return 'Backed up. Last synced $time.';
  }

  @override
  String get accountNotSyncedYet => 'Not synced yet.';

  @override
  String get accountSyncing => 'Syncing…';

  @override
  String get accountSyncOffline =>
      'You\'re offline. Changes will upload when you\'re back online.';

  @override
  String get accountSyncFailed => 'Couldn\'t sync. We\'ll try again.';

  @override
  String get accountSignOutTitle => 'Sign out?';

  @override
  String get accountSignOutBody =>
      'Your travels stay backed up in your account and are removed from this device.';

  @override
  String accountSignOutUnsynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes haven\'t been backed up yet and will be lost.',
      one: '1 change hasn\'t been backed up yet and will be lost.',
    );
    return '$_temp0';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsCountryData => 'Country data';

  @override
  String settingsCountryDataUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get settingsDataSource => 'Data source';

  @override
  String get settingsDataSourceValue =>
      'Country data and flags from REST Countries';

  @override
  String get settingsMapSource => 'Map data';

  @override
  String get settingsMapSourceValue =>
      'World map from Natural Earth. Disputed borders are shown as Saudi Arabia recognizes them.';

  @override
  String get settingsLicenses => 'Open-source licenses';
}
