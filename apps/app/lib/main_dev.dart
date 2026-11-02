import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:get_it/get_it.dart';
import 'package:l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  configureDependencies(GetIt.instance, AppConfig.fromEnvironment(), prefs);
  runApp(
    App(
      localeCubit: GetIt.instance<LocaleCubit>(),
      themeCubit: GetIt.instance<ThemeCubit>(),
    ),
  );
}
