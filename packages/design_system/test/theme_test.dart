import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light and dark themes use matching brightness', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.light.useMaterial3, isTrue);
  });

  test('spacing tokens increase monotonically', () {
    const s = [
      AppSpacing.xs,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.xl,
    ];
    for (var i = 1; i < s.length; i++) {
      expect(s[i], greaterThan(s[i - 1]));
    }
  });

  test('typography exposes a full text theme', () {
    expect(AppTypography.textTheme.bodyMedium, isNotNull);
    expect(AppTypography.textTheme.headlineMedium, isNotNull);
  });

  test('color tokens differ between light and dark schemes', () {
    expect(AppColors.lightScheme.surface, isNot(AppColors.darkScheme.surface));
  });
}
