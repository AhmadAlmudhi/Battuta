/// Stored as text in the `theme_mode` setting (PRD section 8.5).
enum AppThemeMode { system, light, dark }

/// Stored as text in the `locale` setting (PRD section 8.5).
enum AppLanguage { system, en, ar }

class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.system,
    this.onboardingDone = false,
  });

  final AppThemeMode themeMode;
  final AppLanguage language;

  /// Hides the Welcome screen after the first choice (FR-ONB-02).
  final bool onboardingDone;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? onboardingDone,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    onboardingDone: onboardingDone ?? this.onboardingDone,
  );
}
