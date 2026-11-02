import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';

void main() {
  Widget build(GoRouter router) => MaterialApp.router(routerConfig: router);

  GoRouter makeRouter() => createAppRouter(
    postsBuilder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => context.push(AppRoutes.settings),
        child: const Text('posts'),
      ),
    ),
    settingsBuilder: (_) => const Scaffold(body: Text('settings')),
  );

  testWidgets('starts on posts', (tester) async {
    await tester.pumpWidget(build(makeRouter()));
    expect(find.text('posts'), findsOneWidget);
  });

  testWidgets('navigates to settings and back', (tester) async {
    final router = makeRouter();
    await tester.pumpWidget(build(router));
    await tester.tap(find.text('posts'));
    await tester.pumpAndSettle();
    expect(find.text('settings'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('posts'), findsOneWidget);
  });

  testWidgets('go to settings via path', (tester) async {
    final router = makeRouter();
    await tester.pumpWidget(build(router));
    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    expect(find.text('settings'), findsOneWidget);
  });
}
