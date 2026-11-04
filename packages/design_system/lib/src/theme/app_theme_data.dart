import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Holds the app's colors and typography for one brightness.
///
/// Access with `context.theme`, `context.colors` and `context.typography`;
/// use [materialThemeData] with `MaterialApp`.
@immutable
class AppThemeData {
  const AppThemeData({
    required this.brightness,
    required this.colors,
    required this.typography,
  });

  factory AppThemeData._generate(Brightness brightness, AppColors colors) =>
      AppThemeData(
        brightness: brightness,
        colors: colors,
        typography: AppTypography.generate(colors: colors),
      );

  static final AppThemeData light = AppThemeData._generate(
    Brightness.light,
    AppColors.light,
  );

  static final AppThemeData dark = AppThemeData._generate(
    Brightness.dark,
    AppColors.dark,
  );

  final Brightness brightness;
  final AppColors colors;
  final AppTypography typography;

  ColorScheme get colorScheme => ColorScheme(
    brightness: brightness,
    primary: colors.actionable.primary,
    onPrimary: colors.actionable.primary.onColor,
    secondary: colors.actionable.secondary,
    onSecondary: colors.actionable.secondary.onColor,
    error: colors.actionable.destructive,
    onError: colors.actionable.destructive.onColor,
    surface: colors.surface,
    onSurface: colors.display,
    outline: colors.divider,
    outlineVariant: colors.divider.secondary,
  );

  TextTheme get textTheme => TextTheme(
    displaySmall: typography.largeTitle.primary,
    headlineMedium: typography.title1.bold!.primary,
    headlineSmall: typography.title2.bold!.primary,
    titleLarge: typography.title2.bold!.primary,
    titleMedium: typography.subtitle.bold!.primary,
    titleSmall: typography.body.bold!.primary,
    bodyLarge: typography.subtitle.primary,
    bodyMedium: typography.body.primary,
    bodySmall: typography.caption.secondary,
    labelLarge: typography.body.bold!.primary,
    labelMedium: typography.caption.bold!.primary,
    labelSmall: typography.footnote.bold!.secondary,
  );

  ThemeData get materialThemeData => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colors.background,
    dividerColor: colors.divider,
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      labelStyle: typography.body.secondary,
    ),
  );

  /// Resolves the theme data matching the ambient [Theme] brightness.
  static AppThemeData of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

extension AppThemeContext on BuildContext {
  AppThemeData get theme => AppThemeData.of(this);
  AppColors get colors => theme.colors;
  AppTypography get typography => theme.typography;
}
