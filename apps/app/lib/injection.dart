import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:get_it/get_it.dart';

/// Composition root: the only place that touches get_it.
/// Data sources, repositories and use cases are lazy singletons;
/// Blocs are factories.
void configureDependencies(GetIt getIt, AppConfig config) {
  getIt.registerSingleton<AppConfig>(config);
}
