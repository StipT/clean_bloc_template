import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc_template/features/posts/domain/get_posts.dart';
import 'package:flutter_bloc_template/features/posts/domain/post.dart';
import 'package:flutter_bloc_template/features/posts/presentation/posts_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPosts extends Mock implements GetPosts {}

void main() {
  late _MockGetPosts getPosts;
  const posts = [Post(id: 1, title: 't', body: 'b')];

  setUp(() => getPosts = _MockGetPosts());

  test('starts in initial state', () {
    expect(PostsBloc(getPosts).state, const PostsState.initial());
  });

  blocTest<PostsBloc, PostsState>(
    'emits loading then loaded',
    build: () {
      when(getPosts.call).thenAnswer((_) async => const Success(posts));
      return PostsBloc(getPosts);
    },
    act: (bloc) => bloc.add(const PostsRequested()),
    expect: () => [
      const PostsState(status: PostsStatus.loading),
      const PostsState(status: PostsStatus.loaded, posts: posts),
    ],
  );

  blocTest<PostsBloc, PostsState>(
    'emits loaded with empty list for no posts',
    build: () {
      when(getPosts.call).thenAnswer((_) async => const Success([]));
      return PostsBloc(getPosts);
    },
    act: (bloc) => bloc.add(const PostsRequested()),
    expect: () => [
      const PostsState(status: PostsStatus.loading),
      const PostsState(status: PostsStatus.loaded),
    ],
  );

  blocTest<PostsBloc, PostsState>(
    'emits failure with message on error',
    build: () {
      when(getPosts.call).thenAnswer((_) async => const Err(NetworkFailure()));
      return PostsBloc(getPosts);
    },
    act: (bloc) => bloc.add(const PostsRequested()),
    expect: () => [
      const PostsState(status: PostsStatus.loading),
      const PostsState(
        status: PostsStatus.failure,
        errorMessage: 'No connection',
      ),
    ],
  );
}
