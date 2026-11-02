import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:get_it/get_it.dart';
import 'package:l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: the only place that touches get_it.
/// Data sources, repositories and use cases are lazy singletons;
/// Blocs are factories.
void configureDependencies(
  GetIt getIt,
  AppConfig config,
  SharedPreferences prefs,
) {
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<SharedPreferences>(prefs)
    // App-wide settings cubits live for the whole app lifetime.
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(getIt()))
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt()));
}
