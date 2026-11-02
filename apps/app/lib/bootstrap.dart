import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared startup for every flavor entrypoint.
Future<void> bootstrap({AppConfig? config}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final dependencies = composeDependencies(
    config ?? AppConfig.fromEnvironment(),
    prefs,
  );
  runApp(App(dependencies: dependencies));
}
