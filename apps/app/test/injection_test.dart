import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDependencies deps;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    deps = composeDependencies(
      const AppConfig(baseUrl: 'https://api.example.com'),
      prefs,
    );
  });

  test('exposes app-wide settings cubits as stable instances', () {
    expect(deps.localeCubit, isNotNull);
    expect(deps.themeCubit, isNotNull);
  });

  test('createPostsBloc returns a new instance each time', () async {
    final a = deps.createPostsBloc();
    final b = deps.createPostsBloc();
    expect(a, isNot(same(b)));
    await a.close();
    await b.close();
  });
}
