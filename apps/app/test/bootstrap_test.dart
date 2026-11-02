import 'package:flutter_bloc_template/bootstrap.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('bootstrap registers the config and starts the app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final getIt = GetIt.asNewInstance();
    const config = AppConfig(baseUrl: 'https://example.test');

    await bootstrap(getIt: getIt, config: config);

    expect(getIt<AppConfig>(), config);
  });
}
