import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Selected locale; `null` follows the system locale. Persisted.
class LocaleCubit extends Cubit<Locale?> {
  /// Reads the persisted locale from [_prefs].
  LocaleCubit(this._prefs) : super(_read(_prefs));

  /// Preferences key.
  static const storageKey = 'locale';

  /// Locales the app ships.
  static const supported = [Locale('en'), Locale('hr')];

  final SharedPreferences _prefs;

  static Locale? _read(SharedPreferences prefs) {
    final code = prefs.getString(storageKey);
    for (final locale in supported) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }

  /// Sets and persists [locale]; `null` follows the system.
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(storageKey);
    } else {
      await _prefs.setString(storageKey, locale.languageCode);
    }
    emit(locale);
  }
}
