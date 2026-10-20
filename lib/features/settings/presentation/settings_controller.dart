import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

/// Loaded in `main` before the app starts and supplied with an override, so
/// settings are available synchronously on the first frame.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Applies setting changes instantly and persists them (FR-SET-01 to 03).
class SettingsController extends Notifier<AppSettings> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    return _repository.setThemeMode(mode);
  }

  Future<void> setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
    return _repository.setLanguage(language);
  }

  Future<void> completeOnboarding() {
    state = state.copyWith(onboardingDone: true);
    return _repository.setOnboardingDone();
  }
}
