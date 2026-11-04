import 'package:design_system/src/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

/// A [TextStyle] that exposes color variants (`style.secondary`) and an
/// optional emphasized variant (`style.bold`) built from the same base.
@immutable
class AugmentedTextStyle extends TextStyle {
  AugmentedTextStyle({
    required TextStyle style,
    required AppColors colors,
    TextStyle? emphasis,
  }) : primary = style.copyWith(color: colors.display),
       secondary = style.copyWith(color: colors.display.secondary),
       tertiary = style.copyWith(color: colors.display.tertiary),
       brand = style.copyWith(color: colors.brand),
       bold = emphasis == null
           ? null
           : AugmentedTextStyle(style: emphasis, colors: colors),
       super(
         fontFamily: style.fontFamily,
         fontFamilyFallback: style.fontFamilyFallback,
         fontSize: style.fontSize,
         fontWeight: style.fontWeight,
         height: style.height,
         letterSpacing: style.letterSpacing,
         leadingDistribution: style.leadingDistribution,
       );

  final TextStyle primary;
  final TextStyle secondary;
  final TextStyle tertiary;
  final TextStyle brand;

  /// Emphasized variant, or null when the style defines none.
  final AugmentedTextStyle? bold;
}
