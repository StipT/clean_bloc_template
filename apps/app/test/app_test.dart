import 'dart:convert';

import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:network/network.dart';

void main() {
  testWidgets('App routes to the posts page and renders fetched posts', (
    tester,
  ) async {
    final getIt = GetIt.asNewInstance();
    configureDependencies(getIt, const AppConfig(baseUrl: 'https://x.test'));
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
  });
}
