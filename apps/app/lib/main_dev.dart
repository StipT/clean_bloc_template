import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:get_it/get_it.dart';

void main() {
  configureDependencies(GetIt.instance, AppConfig.fromEnvironment());
  runApp(const App());
}
