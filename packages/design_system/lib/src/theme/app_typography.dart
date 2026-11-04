import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/theme/augmented_text_style.dart';
import 'package:flutter/widgets.dart';

/// Type scale using the Inter family (add the font assets to the app to
/// bundle it; the platform font is used as a fallback).
@immutable
class AppTypography {
  const AppTypography({
    required this.largeTitle,
    required this.title1,
    required this.title2,
    required this.subtitle,
    required this.body,
    required this.caption,
    required this.footnote,
  });

  factory AppTypography.generate({required AppColors colors}) {
    const base = TextStyle(
      fontFamily: 'Inter',
      fontFamilyFallback: ['Roboto', '.AppleSystemUIFont', 'Apple Color Emoji'],
      leadingDistribution: TextLeadingDistribution.even,
    );

    AugmentedTextStyle build(
      double size,
      double lineHeight, {
      double letterSpacing = 0,
      FontWeight regular = FontWeight.w400,
      FontWeight emphasis = FontWeight.w600,
    }) {
      final style = base.copyWith(
        fontSize: size,
        height: lineHeight / size,
        letterSpacing: letterSpacing,
        fontWeight: regular,
      );
      return AugmentedTextStyle(
        style: style,
        colors: colors,
        emphasis: style.copyWith(fontWeight: emphasis),
      );
    }

    return AppTypography(
      largeTitle: build(32, 40, letterSpacing: -0.6, emphasis: FontWeight.w700),
      title1: build(26, 32, letterSpacing: -0.4, emphasis: FontWeight.w700),
      title2: build(20, 26, letterSpacing: -0.2, emphasis: FontWeight.w700),
      subtitle: build(17, 24, letterSpacing: -0.1),
      body: build(15, 22),
      caption: build(13, 18, letterSpacing: 0.1),
      footnote: build(11, 16, letterSpacing: 0.2, emphasis: FontWeight.w700),
    );
  }

  final AugmentedTextStyle largeTitle;
  final AugmentedTextStyle title1;
  final AugmentedTextStyle title2;
  final AugmentedTextStyle subtitle;
  final AugmentedTextStyle body;
  final AugmentedTextStyle caption;
  final AugmentedTextStyle footnote;
}
