import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/layout/window_size.dart';
import '../../../core/platform/link_launcher.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_settings.dart';
import 'about_providers.dart';
import 'settings_controller.dart';

/// Theme, language (FR-SET-01 to 03), and About (FR-SET-04).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return ScreenTitle(
      screen: l10n.settingsTitle,
      child: Scaffold(
        appBar: AppBar(
          leading: upButton(context, fallback: '/account'),
          title: Text(l10n.settingsTitle),
        ),
        body: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: l10n.settingsTheme,
                child: SegmentedButton<AppThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_rounded),
                      label: Text(l10n.settingsThemeSystem),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      icon: const Icon(Icons.light_mode_rounded),
                      label: Text(l10n.settingsThemeLight),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_rounded),
                      label: Text(l10n.settingsThemeDark),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) =>
                      controller.setThemeMode(selection.single),
                ),
              ),
              const SizedBox(height: 24),
              _Section(
                title: l10n.settingsLanguage,
                child: SegmentedButton<AppLanguage>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: AppLanguage.system,
                      label: Text(l10n.settingsLanguageSystem),
                    ),
                    ButtonSegment(
                      value: AppLanguage.en,
                      label: Text(l10n.settingsLanguageEnglish),
                    ),
                    ButtonSegment(
                      value: AppLanguage.ar,
                      label: Text(l10n.settingsLanguageArabic),
                    ),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (selection) =>
                      controller.setLanguage(selection.single),
                ),
              ),
              const SizedBox(height: 24),
              _Section(title: l10n.settingsAbout, child: const _About()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: child),
    ],
  );
}

/// App version, date of the country data, and the data source credit
/// (FR-SET-04).
class _About extends ConsumerWidget {
  const _About();

  static final _restCountries = Uri.parse('https://restcountries.com');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final version = ref.watch(appVersionProvider).valueOrNull;
    final dataDate = ref.watch(countryDataDateProvider).valueOrNull;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(l10n.settingsVersion),
            // Read left to right, but aligned like the rest of the row.
            subtitle: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(version ?? '', textDirection: TextDirection.ltr),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.public_rounded),
            title: Text(l10n.settingsCountryData),
            subtitle: Text(
              dataDate == null
                  ? l10n.commonNotAvailable
                  : l10n.settingsCountryDataUpdated(
                      context.formatDate(dataDate),
                    ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dataset_outlined),
            title: Text(l10n.settingsDataSource),
            subtitle: Text(l10n.settingsDataSourceValue),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => ref.read(linkLauncherProvider)(_restCountries),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsLicenses),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appName,
              applicationVersion: version,
            ),
          ),
        ],
      ),
    );
  }
}
