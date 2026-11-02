import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_bloc.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:l10n/l10n.dart';
import 'package:network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late GetIt getIt;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    getIt = GetIt.asNewInstance();
    configureDependencies(
      getIt,
      const AppConfig(baseUrl: 'https://api.example.com'),
      prefs,
    );
  });

  test('composition root registers config and settings cubits', () {
    expect(getIt<AppConfig>().baseUrl, 'https://api.example.com');
    expect(getIt<LocaleCubit>(), isA<LocaleCubit>());
    expect(getIt<ThemeCubit>(), isA<ThemeCubit>());
  });

  test('ApiClient is a singleton; PostsBloc is a new instance each time', () {
    expect(getIt<ApiClient>(), same(getIt<ApiClient>()));
    final a = getIt<PostsBloc>();
    final b = getIt<PostsBloc>();
    expect(a, isNot(same(b)));
    addTearDown(() async {
      await a.close();
      await b.close();
    });
  });
}
