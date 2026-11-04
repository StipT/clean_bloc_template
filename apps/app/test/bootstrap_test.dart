import 'package:flutter_bloc_template/app.dart';
import 'package:flutter_bloc_template/bootstrap.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('bootstrap composes dependencies and starts the app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await bootstrap(config: const AppConfig(baseUrl: 'https://example.test'));
    await tester.pump();

    expect(find.byType(App), findsOneWidget);
  });
}
