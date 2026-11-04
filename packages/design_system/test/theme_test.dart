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

  test('typography exposes augmented styles with color variants', () {
    final t = AppThemeData.light.typography;
    expect(t.body.fontFamily, 'Inter');
    expect(t.body.primary.color, AppColors.light.display);
    expect(t.body.secondary.color, AppColors.light.display.secondary);
    expect(t.title1.bold!.fontWeight, FontWeight.w700);
    expect(AppTheme.light.textTheme.bodyMedium, isNotNull);
  });

  test('color tokens differ between light and dark', () {
    expect(AppColors.light.surface, isNot(AppColors.dark.surface));
    expect(
      AppTheme.light.colorScheme.primary.toARGB32(),
      AppColors.light.brand.toARGB32(),
    );
  });

  test('actionable color resolves states', () {
    final c = AppColors.light.actionable.primary;
    expect(c.stateProperty.resolve({WidgetState.disabled}), c.disabled);
    expect(c.stateProperty.resolve({WidgetState.pressed}), c.hover);
    expect(c.stateProperty.resolve({}), c.idle);
    expect(
      c.onStateProperty.resolve({WidgetState.disabled}),
      c.disabled.onColor,
    );
    expect(c.onStateProperty.resolve({WidgetState.hovered}), c.hover.onColor);
    expect(c.onStateProperty.resolve({}), c.onColor);
  });

  testWidgets('context extensions follow theme brightness', (tester) async {
    late AppColors colors;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) {
            colors = context.colors;
            expect(context.typography, AppThemeData.dark.typography);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors, AppColors.dark);
  });
}
