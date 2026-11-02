import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:get_it/get_it.dart';

/// Shared startup for every flavor entrypoint.
void bootstrap({GetIt? getIt, AppConfig? config}) {
  WidgetsFlutterBinding.ensureInitialized();
  final container = getIt ?? GetIt.instance;
  configureDependencies(container, config ?? AppConfig.fromEnvironment());
  runApp(App(getIt: container));
}
