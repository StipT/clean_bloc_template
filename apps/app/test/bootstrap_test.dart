import 'package:flutter_bloc_template/bootstrap.dart';
import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  test('bootstrap registers the config and starts the app', () {
    final getIt = GetIt.asNewInstance();
    const config = AppConfig(baseUrl: 'https://example.test');

    bootstrap(getIt: getIt, config: config);

    expect(getIt<AppConfig>(), config);
  });
}
