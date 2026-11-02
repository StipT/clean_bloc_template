import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders fetched posts and applies the persisted theme', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final getIt = GetIt.asNewInstance();
    configureDependencies(
      getIt,
      const AppConfig(baseUrl: 'https://x.test'),
      prefs,
    );
    getIt
      ..unregister<ApiClient>()
      ..registerSingleton(
        ApiClient(
          baseUrl: 'https://x.test',
          client: MockClient(
            (_) async => http.Response(
              jsonEncode([
                {'id': 1, 'userId': 1, 'title': 'Hello', 'body': 'World'},
              ]),
              200,
            ),
          ),
        ),
      );

    await tester.pumpWidget(App(getIt: getIt));
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
