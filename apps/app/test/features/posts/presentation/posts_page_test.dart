import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/features/posts/domain/post.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_bloc.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPostsBloc extends MockBloc<PostsEvent, PostsState>
    implements PostsBloc {}

void main() {
  late _MockPostsBloc bloc;

  setUp(() => bloc = _MockPostsBloc());

  Future<void> pump(WidgetTester tester, PostsState state) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
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
  });

  testWidgets('shows error and retries', (tester) async {
    await pump(
      tester,
      const PostsState(status: PostsStatus.failure, errorMessage: 'boom'),
    );
    expect(find.text('boom'), findsOneWidget);

    await tester.tap(find.byType(AppButton));

    verify(() => bloc.add(const PostsRequested())).called(1);
  });
}
