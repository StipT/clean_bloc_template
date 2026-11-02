import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  test('composition root registers the AppConfig it is given', () {
    final getIt = GetIt.asNewInstance();
    const config = AppConfig(baseUrl: 'https://api.example.com');

    configureDependencies(getIt, config);

    expect(getIt<AppConfig>().baseUrl, 'https://api.example.com');
  });
}
