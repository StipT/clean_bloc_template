import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> prefsWith(Map<String, Object> values) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  group('LocaleCubit', () {
    test('starts as system locale when nothing is stored', () async {
      expect(LocaleCubit(await prefsWith({})).state, isNull);
    });

    test('restores a persisted locale', () async {
      final cubit = LocaleCubit(await prefsWith({'locale': 'hr'}));
      expect(cubit.state, const Locale('hr'));
    });

    test('ignores an unsupported stored locale', () async {
      expect(LocaleCubit(await prefsWith({'locale': 'xx'})).state, isNull);
    });

    test('setLocale emits and persists, null clears', () async {
      final prefs = await prefsWith({});
      final cubit = LocaleCubit(prefs);
      final emitted = <Locale?>[];
      cubit.stream.listen(emitted.add);
      await cubit.setLocale(const Locale('hr'));
      expect(prefs.getString('locale'), 'hr');
      await cubit.setLocale(null);
      expect(prefs.getString('locale'), isNull);
      await Future<void>.delayed(Duration.zero);
      expect(emitted, [const Locale('hr'), null]);
    });
  });

  group('ThemeCubit', () {
    test('defaults to system', () async {
      expect(ThemeCubit(await prefsWith({})).state, ThemeMode.system);
    });

    test('restores a persisted mode', () async {
      final cubit = ThemeCubit(await prefsWith({'theme_mode': 'dark'}));
      expect(cubit.state, ThemeMode.dark);
    });

    test('setThemeMode emits and persists across a new instance', () async {
      final prefs = await prefsWith({});
      await ThemeCubit(prefs).setThemeMode(ThemeMode.light);
      expect(ThemeCubit(prefs).state, ThemeMode.light);
    });
  });
}
