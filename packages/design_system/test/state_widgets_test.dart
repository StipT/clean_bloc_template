import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('AppLoader shows a progress indicator', (tester) async {
    await tester.pumpWidget(wrap(const AppLoader()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ErrorView shows message and retry triggers callback', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      wrap(
        ErrorView(
          message: 'Boom',
          retryLabel: 'Retry',
          onRetry: () => retries++,
        ),
      ),
    );
    expect(find.text('Boom'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('ErrorView hides retry without callback', (tester) async {
    await tester.pumpWidget(wrap(const ErrorView(message: 'Boom')));
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('EmptyView shows message', (tester) async {
    await tester.pumpWidget(wrap(const EmptyView(message: 'Nothing')));
    expect(find.text('Nothing'), findsOneWidget);
  });
}
