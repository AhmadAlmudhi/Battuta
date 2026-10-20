import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/window_size.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_settings.dart';
import 'settings_controller.dart';

/// Theme and language (FR-SET-01 to 03). The About section comes later.
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
