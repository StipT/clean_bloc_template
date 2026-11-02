import 'package:flutter_bloc_template/config/app_config.dart';
import 'package:flutter_bloc_template/features/posts/data/posts_remote_data_source.dart';
import 'package:flutter_bloc_template/features/posts/data/posts_repository_impl.dart';
import 'package:flutter_bloc_template/features/posts/domain/get_posts.dart';
import 'package:flutter_bloc_template/features/posts/domain/post_repository.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:l10n/l10n.dart';
import 'package:network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: the only place that touches get_it.
/// Data sources, repositories and use cases are lazy singletons;
/// Blocs are factories.
void configureDependencies(
  GetIt getIt,
  AppConfig config,
  SharedPreferences prefs,
) {
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<SharedPreferences>(prefs)
    // App-wide settings cubits live for the whole app lifetime.
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(getIt()))
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt()))
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(baseUrl: getIt<AppConfig>().baseUrl),
    )
    // --- posts demo feature (see README "Removing the demo feature") ---
    ..registerLazySingleton(() => PostsRemoteDataSource(getIt<ApiClient>()))
    ..registerLazySingleton<PostRepository>(
      () => PostsRepositoryImpl(getIt<PostsRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetPosts(getIt<PostRepository>()))
    ..registerFactory(() => PostsBloc(getIt<GetPosts>()));
  // --- end posts demo feature ---
}
