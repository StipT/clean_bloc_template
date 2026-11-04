import 'package:design_system/src/theme/app_theme_data.dart';
import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppTheme {
  static final ThemeData light = AppThemeData.light.materialThemeData;
  static final ThemeData dark = AppThemeData.dark.materialThemeData;
}
