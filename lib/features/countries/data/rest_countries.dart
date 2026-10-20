// REST Countries v5 request settings (PRD section 8.1), shared by the app's
// refresh and `tool/fetch_snapshot.dart`. Pure Dart, so the CLI tool can
// import it.

const restCountriesBaseUrl = 'https://api.restcountries.com/countries/v5';

/// The free plan allows up to 100 records per page; about 250 records need
/// 3 requests.
const restCountriesPageSize = 100;

/// Stops a misbehaving `more` flag from looping; 5 pages cover 500 records.
const restCountriesMaxPages = 5;

/// Must match the fields `parseCountry` reads.
const restCountriesFields = [
  'codes.alpha_2',
  'codes.alpha_3',
  'names.common',
  'names.official',
  'names.translations',
  'capitals',
  'region',
  'subregion',
  'borders',
  'area.kilometers',
  'population',
  'languages',
  'currencies',
  'timezones',
  'links.google_maps',
  'flag.description',
  'flag.colors.dominant',
];

Map<String, String> restCountriesPageQuery(int offset) => {
  'limit': '$restCountriesPageSize',
  'offset': '$offset',
  'response_fields': restCountriesFields.join(','),
};
