import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(body: child),
  );

  testWidgets('AppTextField shows label and reports changes', (tester) async {
    String? value;
    await tester.pumpWidget(
      wrap(AppTextField(label: 'Email', onChanged: (v) => value = v)),
    );
    expect(find.text('Email'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'a@b.c');
    expect(value, 'a@b.c');
  });

  testWidgets('AppTextField shows error text', (tester) async {
    await tester.pumpWidget(
      wrap(const AppTextField(label: 'Email', errorText: 'Invalid')),
    );
    expect(find.text('Invalid'), findsOneWidget);
  });

  testWidgets('AppTextField obscures text when requested', (tester) async {
    await tester.pumpWidget(
      wrap(const AppTextField(label: 'Pw', obscureText: true)),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, true);
  });
}
