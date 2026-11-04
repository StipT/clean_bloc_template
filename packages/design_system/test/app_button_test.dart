import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('AppButton calls onPressed when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(AppButton(label: 'Go', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Go'));
    expect(taps, 1);
  });

  testWidgets('AppButton is disabled without onPressed', (tester) async {
    await tester.pumpWidget(wrap(const AppButton(label: 'Go')));
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('AppButton loading shows spinner and ignores taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(AppButton(label: 'Go', isLoading: true, onPressed: () => taps++)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Go'), findsNothing);
    await tester.tap(find.byType(FilledButton));
    expect(taps, 0);
  });

  testWidgets('AppButton secondary renders an OutlinedButton', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Go',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
      ),
    );
    expect(find.byType(OutlinedButton), findsOneWidget);
  });
}
