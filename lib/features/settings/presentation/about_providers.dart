import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../countries/presentation/country_providers.dart';

/// The app version from pubspec.yaml, such as 1.0.0 (1) (FR-SET-04).
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.buildNumber.isEmpty
      ? info.version
      : '${info.version} (${info.buildNumber})';
});

/// When the country data was fetched: the snapshot time or the last
/// refresh. Updates after a refresh replaces the data (FR-SET-04).
final countryDataDateProvider = FutureProvider<DateTime?>((ref) async {
  await ref.watch(countriesProvider.future);
  return ref.watch(countryRepositoryProvider).dataFetchedAt();
});

/// The font's SIL Open Font License, listed on the licenses page next to
/// the packages' licenses.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Alexandria',
    ], await rootBundle.loadString('assets/fonts/alexandria/OFL.txt'));
  });
}
