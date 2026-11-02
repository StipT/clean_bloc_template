import 'package:core/core.dart';
import 'package:flutter_bloc_template/features/posts/domain/get_posts.dart';
import 'package:flutter_bloc_template/features/posts/domain/post.dart';
import 'package:flutter_bloc_template/features/posts/domain/post_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements PostRepository {}

void main() {
  test('delegates to the repository', () async {
    final repo = _MockRepo();
    const posts = [Post(id: 1, title: 't', body: 'b')];
    when(repo.getPosts).thenAnswer((_) async => const Success(posts));

    expect(await GetPosts(repo)(), const Success(posts));
    verify(repo.getPosts).called(1);
  });
}
