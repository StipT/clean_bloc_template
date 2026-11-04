import 'package:flutter/material.dart';

/// A [Color] that carries additional related colors.
///
/// The primary value is used directly (`colors.brand`), variants are reached
/// through members (`colors.display.secondary`).
@immutable
class AugmentedColor extends Color {
  const AugmentedColor(super.value);
}

/// A color with a secondary variant.
@immutable
class DualAugmentedColor extends AugmentedColor {
  const DualAugmentedColor(super.value, {required this.secondary});

  Color get primary => this;
  final Color secondary;
}

/// Text/icon color ramp: primary to quaternary emphasis.
@immutable
class DisplayAugmentedColor extends DualAugmentedColor {
  const DisplayAugmentedColor(
    super.value, {
    required super.secondary,
    required this.tertiary,
    required this.quaternary,
  });

  final Color tertiary;
  final Color quaternary;
}

/// A color with a foreground ("on") variant.
@immutable
class OnAugmentedColor extends AugmentedColor {
  const OnAugmentedColor(super.value, {required this.onColor});

  Color get background => this;
  Color get foreground => onColor;
  final Color onColor;
}

/// An [OnAugmentedColor] with hover and disabled states.
@immutable
class ActionableColor extends OnAugmentedColor {
  const ActionableColor(
    super.value, {
    required super.onColor,
    required this.hover,
    required this.disabled,
  });

  OnAugmentedColor get idle => this;
  final OnAugmentedColor hover;
  final OnAugmentedColor disabled;

  WidgetStateProperty<Color> get stateProperty =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return disabled;
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered)) {
          return hover;
        }
        return idle;
      });

  WidgetStateProperty<Color> get onStateProperty =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return disabled.onColor;
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered)) {
          return hover.onColor;
        }
        return idle.onColor;
      });
}
