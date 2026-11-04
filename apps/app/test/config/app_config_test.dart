import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes the base URL it was created with', () {
    const config = AppConfig(baseUrl: 'https://api.example.com');

    expect(config.baseUrl, 'https://api.example.com');
  });

  test('fromEnvironment falls back to an empty base URL without defines', () {
    expect(AppConfig.fromEnvironment().baseUrl, isEmpty);
  });
}
