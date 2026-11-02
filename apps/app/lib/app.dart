import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/features/placeholder/placeholder_page.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_bloc.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_page.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';

class App extends StatefulWidget {
  const App({required this.getIt, super.key});

  final GetIt getIt;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createAppRouter(
    postsBuilder: (_) => PostsPage(createBloc: () => widget.getIt<PostsBloc>()),
    settingsBuilder: (_) => const PlaceholderPage(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter BLoC Template',
      routerConfig: _router,
    );
  }
}
