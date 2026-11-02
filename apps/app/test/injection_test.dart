import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('composition root registers config and settings cubits', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final getIt = GetIt.asNewInstance();
    const config = AppConfig(baseUrl: 'https://api.example.com');

    configureDependencies(getIt, config, prefs);

    expect(getIt<AppConfig>().baseUrl, 'https://api.example.com');
    expect(getIt<LocaleCubit>(), isA<LocaleCubit>());
    expect(getIt<ThemeCubit>(), isA<ThemeCubit>());
  });
}
