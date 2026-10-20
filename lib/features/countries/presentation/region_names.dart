import '../../../l10n/app_localizations.dart';

/// Region names from the data, in the app language. A region the strings
/// don't know yet, such as one added by a data refresh, shows as provided.
String regionName(AppLocalizations l10n, String region) => switch (region) {
  'Africa' => l10n.regionAfrica,
  'Americas' => l10n.regionAmericas,
  'Antarctic' => l10n.regionAntarctic,
  'Asia' => l10n.regionAsia,
  'Europe' => l10n.regionEurope,
  'Oceania' => l10n.regionOceania,
  _ => region,
};

String subregionName(AppLocalizations l10n, String subregion) =>
    switch (subregion) {
      'Eastern Africa' => l10n.subregionEasternAfrica,
      'Middle Africa' => l10n.subregionMiddleAfrica,
      'Northern Africa' => l10n.subregionNorthernAfrica,
      'Southern Africa' => l10n.subregionSouthernAfrica,
      'Western Africa' => l10n.subregionWesternAfrica,
      'Caribbean' => l10n.subregionCaribbean,
      'Central America' => l10n.subregionCentralAmerica,
      'North America' => l10n.subregionNorthAmerica,
      'South America' => l10n.subregionSouthAmerica,
      'Central Asia' => l10n.subregionCentralAsia,
      'Eastern Asia' => l10n.subregionEasternAsia,
      'South-Eastern Asia' => l10n.subregionSouthEasternAsia,
      'Southern Asia' => l10n.subregionSouthernAsia,
      'Western Asia' => l10n.subregionWesternAsia,
      'Central Europe' => l10n.subregionCentralEurope,
      'Eastern Europe' => l10n.subregionEasternEurope,
      'Northern Europe' => l10n.subregionNorthernEurope,
      'Southeast Europe' => l10n.subregionSoutheastEurope,
      'Southern Europe' => l10n.subregionSouthernEurope,
      'Western Europe' => l10n.subregionWesternEurope,
      'Australia and New Zealand' => l10n.subregionAustraliaNewZealand,
      'Melanesia' => l10n.subregionMelanesia,
      'Micronesia' => l10n.subregionMicronesia,
      'Polynesia' => l10n.subregionPolynesia,
      _ => subregion,
    };
