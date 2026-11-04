import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/src/app_routes.dart';

/// Creates the app router; pages are injected by the app.
GoRouter createAppRouter({
  required WidgetBuilder postsBuilder,
  required WidgetBuilder settingsBuilder,
  String initialLocation = AppRoutes.posts,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.posts,
        builder: (context, _) => postsBuilder(context),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, _) => settingsBuilder(context),
      ),
    ],
  );
}
