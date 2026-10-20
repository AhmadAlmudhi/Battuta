import 'package:battuta/features/settings/data/settings_repository.dart';
import 'package:battuta/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SettingsRepository> repository(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SettingsRepository(await SharedPreferences.getInstance());
  }

  test(
    'defaults to System theme, System language, and Welcome not done',
    () async {
      final settings = (await repository({})).load();

      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.language, AppLanguage.system);
      expect(settings.onboardingDone, isFalse);
    },
  );

  test('saves and reloads every setting (FR-SET-03)', () async {
    final repo = await repository({});
    await repo.setThemeMode(AppThemeMode.dark);
    await repo.setLanguage(AppLanguage.ar);
    await repo.setOnboardingDone();

    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsRepository(prefs).load();
    expect(settings.themeMode, AppThemeMode.dark);
    expect(settings.language, AppLanguage.ar);
    expect(settings.onboardingDone, isTrue);
    expect(prefs.getString('theme_mode'), 'dark');
    expect(prefs.getString('locale'), 'ar');
  });

  test('falls back to defaults for unknown stored values', () async {
    final settings = (await repository({
      'theme_mode': 'sepia',
      'locale': 'fr',
    })).load();

    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.language, AppLanguage.system);
  });
}
