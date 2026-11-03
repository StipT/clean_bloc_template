import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/features/posts/domain/post.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_bloc.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigation/navigation.dart';

class _MockPostsBloc extends MockBloc<PostsEvent, PostsState>
    implements PostsBloc {}

void main() {
  late _MockPostsBloc bloc;

  setUp(() => bloc = _MockPostsBloc());

  Future<void> pump(
    WidgetTester tester,
    PostsState state, {
    Locale locale = const Locale('en'),
  }) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: BlocProvider<PostsBloc>.value(
          value: bloc,
          child: const PostsView(),
        ),
      ),
    );
  }

  testWidgets('shows loader while loading', (tester) async {
    await pump(tester, const PostsState(status: PostsStatus.loading));
    expect(find.byType(AppLoader), findsOneWidget);
  });

  testWidgets('shows loader on initial state', (tester) async {
    await pump(tester, const PostsState.initial());
    expect(find.byType(AppLoader), findsOneWidget);
  });

  testWidgets('shows posts', (tester) async {
    await pump(
      tester,
      const PostsState(
        status: PostsStatus.loaded,
        posts: [Post(id: 1, title: 'Title', body: 'Body')],
      ),
    );
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('shows empty view', (tester) async {
    await pump(tester, const PostsState(status: PostsStatus.loaded));
    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('No posts yet'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
  });

  testWidgets('localizes title and empty message to Croatian', (tester) async {
    await pump(
      tester,
      const PostsState(status: PostsStatus.loaded),
      locale: const Locale('hr'),
    );
    expect(find.text('Objave'), findsOneWidget);
    expect(find.text('Još nema objava'), findsOneWidget);
  });

  testWidgets('falls back to localized error message and retry label', (
    tester,
  ) async {
    await pump(tester, const PostsState(status: PostsStatus.failure));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows error and retries', (tester) async {
    await pump(
      tester,
      const PostsState(status: PostsStatus.failure, errorMessage: 'boom'),
    );
    expect(find.text('Something went wrong'), findsOneWidget);

    await tester.tap(find.byType(AppButton));

    verify(() => bloc.add(const PostsRequested())).called(1);
  });

  testWidgets('settings action opens the settings route', (tester) async {
    const state = PostsState(status: PostsStatus.loaded);
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('hr'),
        routerConfig: createAppRouter(
          postsBuilder: (_) => BlocProvider<PostsBloc>.value(
            value: bloc,
            child: const PostsView(),
          ),
          settingsBuilder: (_) => const Scaffold(body: Text('settings page')),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Postavke'));
    await tester.pumpAndSettle();

    expect(find.text('settings page'), findsOneWidget);
    expect(find.byType(PostsView), findsNothing);
  });
}
