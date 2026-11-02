import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/features/placeholder/placeholder_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the placeholder page with its title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlaceholderPage()));

    expect(find.text('Flutter BLoC Template'), findsOneWidget);
  });
}
