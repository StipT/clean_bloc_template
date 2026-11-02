import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Selected [ThemeMode]. Persisted.
class ThemeCubit extends Cubit<ThemeMode> {
  /// Reads the persisted mode from [_prefs].
  ThemeCubit(this._prefs) : super(_read(_prefs));

  /// Preferences key.
  static const storageKey = 'theme_mode';

  final SharedPreferences _prefs;

  static ThemeMode _read(SharedPreferences prefs) {
    final name = prefs.getString(storageKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  /// Sets and persists [mode].
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(storageKey, mode.name);
    emit(mode);
  }
}
