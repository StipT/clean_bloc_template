import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/features/placeholder/placeholder_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App shows the placeholder page and applies persisted theme', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final themeCubit = ThemeCubit(prefs);

    await tester.pumpWidget(
      App(localeCubit: LocaleCubit(prefs), themeCubit: themeCubit),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PlaceholderPage), findsOneWidget);
    expect(find.text('Flutter BLoC Template'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
