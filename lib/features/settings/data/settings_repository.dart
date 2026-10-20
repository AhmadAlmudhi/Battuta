import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// Reads and writes local settings with shared_preferences, which uses the
/// browser's local storage on web (PRD section 8.5).
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _onboardingDoneKey = 'onboarding_done';

  AppSettings load() => AppSettings(
    themeMode: _enumByName(
      AppThemeMode.values,
      _prefs.getString(_themeModeKey),
      AppThemeMode.system,
    ),
    language: _enumByName(
      AppLanguage.values,
      _prefs.getString(_localeKey),
      AppLanguage.system,
    ),
    onboardingDone: _prefs.getBool(_onboardingDoneKey) ?? false,
  );

  Future<void> setThemeMode(AppThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  Future<void> setLanguage(AppLanguage language) =>
      _prefs.setString(_localeKey, language.name);

  Future<void> setOnboardingDone() => _prefs.setBool(_onboardingDoneKey, true);

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) => values.where((value) => value.name == name).firstOrNull ?? fallback;
}
