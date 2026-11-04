import 'package:design_system/src/theme/augmented_color.dart';
import 'package:flutter/material.dart';

@immutable
class ActionableColorGroup {
  const ActionableColorGroup({
    required this.primary,
    required this.secondary,
    required this.destructive,
  });

  final ActionableColor primary;
  final ActionableColor secondary;
  final ActionableColor destructive;
}

@immutable
class StatusColorGroup {
  const StatusColorGroup({
    required this.success,
    required this.warning,
    required this.info,
  });

  final OnAugmentedColor success;
  final OnAugmentedColor warning;
  final OnAugmentedColor info;
}

@immutable
class AppColors {
  const AppColors({
    required this.background,
    required this.surface,
    required this.brand,
    required this.display,
    required this.actionable,
    required this.divider,
    required this.status,
  });

  /// Teal brand palette with a cool neutral background.
  static const light = AppColors(
    background: DualAugmentedColor(0xFFF7F8FA, secondary: Color(0xFFEEF0F4)),
    surface: DualAugmentedColor(0xFFFFFFFF, secondary: Color(0xFFF2F4F7)),
    brand: DualAugmentedColor(0xFF0F8B8D, secondary: Color(0xFFD5F0F0)),
    display: DisplayAugmentedColor(
      0xFF14181F,
      secondary: Color(0xFF4A5261),
      tertiary: Color(0xFF7B8494),
      quaternary: Color(0xFFB3B9C6),
    ),
    actionable: ActionableColorGroup(
      primary: ActionableColor(
        0xFF0F8B8D,
        onColor: Color(0xFFFFFFFF),
        hover: OnAugmentedColor(0xFF0B6E70, onColor: Color(0xFFFFFFFF)),
        disabled: OnAugmentedColor(0xFFB9DCDD, onColor: Color(0xFFFFFFFF)),
      ),
      secondary: ActionableColor(
        0xFFE3F3F3,
        onColor: Color(0xFF0B6E70),
        hover: OnAugmentedColor(0xFFCBE8E8, onColor: Color(0xFF0B6E70)),
        disabled: OnAugmentedColor(0xFFEEF0F4, onColor: Color(0xFFB3B9C6)),
      ),
      destructive: ActionableColor(
        0xFFD92D20,
        onColor: Color(0xFFFFFFFF),
        hover: OnAugmentedColor(0xFFB42318, onColor: Color(0xFFFFFFFF)),
        disabled: OnAugmentedColor(0xFFF4B8B3, onColor: Color(0xFFFFFFFF)),
      ),
    ),
    divider: DualAugmentedColor(0xFFE1E4EA, secondary: Color(0xFFCDD2DB)),
    status: StatusColorGroup(
      success: OnAugmentedColor(0xFFDCF5E6, onColor: Color(0xFF127A3E)),
      warning: OnAugmentedColor(0xFFFFF0D1, onColor: Color(0xFF9A5B00)),
      info: OnAugmentedColor(0xFFDCEBFF, onColor: Color(0xFF1951B3)),
    ),
  );

  static const dark = AppColors(
    background: DualAugmentedColor(0xFF0D1117, secondary: Color(0xFF161B22)),
    surface: DualAugmentedColor(0xFF161B22, secondary: Color(0xFF1F2630)),
    brand: DualAugmentedColor(0xFF3CC4C6, secondary: Color(0xFF123B3C)),
    display: DisplayAugmentedColor(
      0xFFF1F3F7,
      secondary: Color(0xFFC3C9D4),
      tertiary: Color(0xFF8B94A5),
      quaternary: Color(0xFF586071),
    ),
    actionable: ActionableColorGroup(
      primary: ActionableColor(
        0xFF3CC4C6,
        onColor: Color(0xFF06292A),
        hover: OnAugmentedColor(0xFF63D6D8, onColor: Color(0xFF06292A)),
        disabled: OnAugmentedColor(0xFF24484A, onColor: Color(0xFF586071)),
      ),
      secondary: ActionableColor(
        0xFF1F2630,
        onColor: Color(0xFF3CC4C6),
        hover: OnAugmentedColor(0xFF2A3340, onColor: Color(0xFF63D6D8)),
        disabled: OnAugmentedColor(0xFF161B22, onColor: Color(0xFF586071)),
      ),
      destructive: ActionableColor(
        0xFFF2554A,
        onColor: Color(0xFFFFFFFF),
        hover: OnAugmentedColor(0xFFF77D74, onColor: Color(0xFFFFFFFF)),
        disabled: OnAugmentedColor(0xFF5A2A27, onColor: Color(0xFF8B94A5)),
      ),
    ),
    divider: DualAugmentedColor(0xFF262D38, secondary: Color(0xFF39424F)),
    status: StatusColorGroup(
      success: OnAugmentedColor(0xFF0F3A22, onColor: Color(0xFF5FD08A)),
      warning: OnAugmentedColor(0xFF402B05, onColor: Color(0xFFF5B948)),
      info: OnAugmentedColor(0xFF0F2A55, onColor: Color(0xFF7BAEFF)),
    ),
  );

  final DualAugmentedColor background;
  final DualAugmentedColor surface;
  final DualAugmentedColor brand;
  final DisplayAugmentedColor display;
  final ActionableColorGroup actionable;
  final DualAugmentedColor divider;
  final StatusColorGroup status;
}
