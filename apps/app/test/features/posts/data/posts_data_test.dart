import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_bloc_template/features/posts/data/posts_remote_data_source.dart';
import 'package:flutter_bloc_template/features/posts/data/posts_repository_impl.dart';
import 'package:flutter_bloc_template/features/posts/domain/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:network/network.dart';

PostsRepositoryImpl repoFor(MockClient client) => PostsRepositoryImpl(
  PostsRemoteDataSource(ApiClient(baseUrl: 'https://x.test', client: client)),
);

void main() {
  test('returns posts from /posts as entities', () async {
    late Uri requested;
    final repo = repoFor(
      MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode([
            {'id': 1, 'userId': 1, 'title': 't', 'body': 'b'},
          ]),
          200,
        );
      }),
    );

    final result = await repo.getPosts();

    expect(requested.toString(), 'https://x.test/posts');
    expect(result, const Success([Post(id: 1, title: 't', body: 'b')]));
  });

  test('propagates failures', () async {
    final repo = repoFor(MockClient((_) async => http.Response('', 500)));

    final result = await repo.getPosts();

    expect(result.failureOrNull, isA<ServerFailure>());
  });

  test('maps a malformed payload to ParsingFailure', () async {
    final repo = repoFor(MockClient((_) async => http.Response('{}', 200)));

    final result = await repo.getPosts();

    expect(result.failureOrNull, isA<ParsingFailure>());
  });
}
