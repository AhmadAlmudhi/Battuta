// International tourist arrivals from the World Bank's World Development
// Indicators, which publish UN Tourism's figures (PRD section 8.8). Pure
// Dart, shared by `tool/fetch_tourism.dart` and its tests.

/// The indicator: international tourism, number of arrivals.
const worldBankArrivalsUrl =
    'https://api.worldbank.org/v2/country/all/indicator/ST.INT.ARVL';

/// The indicator's page, credited in About (FR-SET-04).
const worldBankArrivalsPage =
    'https://data.worldbank.org/indicator/ST.INT.ARVL';

/// The first year a figure is taken from, so no country is ranked on very
/// old numbers.
const arrivalsFirstYear = 2012;

/// Travel all but stopped in these years, so their figures would rank
/// countries by how they handled the pandemic.
const arrivalsSkippedYears = {2020, 2021};

/// Every year from [arrivalsFirstYear] to [lastYear], in one page.
Map<String, String> worldBankArrivalsQuery(int lastYear) => {
  'format': 'json',
  'date': '$arrivalsFirstYear:$lastYear',
  'per_page': '20000',
};

/// Each country's most recent figure, keyed by its 3-letter code, for the
/// countries in [codes]. [rows] are the World Bank's records, with
/// `countryiso3code`, `date`, and `value`, which is null for a year without
/// a figure.
Map<String, ({int year, int arrivals})> latestArrivals(
  List<Object?> rows,
  Set<String> codes,
) {
  final latest = <String, ({int year, int arrivals})>{};
  for (final row in rows) {
    if (row is! Map<String, Object?>) continue;
    final code = row['countryiso3code'];
    final year = int.tryParse('${row['date']}');
    final value = row['value'];
    if (code is! String || !codes.contains(code)) continue;
    if (year == null || value is! num) continue;
    if (year < arrivalsFirstYear || arrivalsSkippedYears.contains(year)) {
      continue;
    }
    if (latest[code] case final current? when current.year >= year) continue;
    latest[code] = (year: year, arrivals: value.round());
  }
  return latest;
}
