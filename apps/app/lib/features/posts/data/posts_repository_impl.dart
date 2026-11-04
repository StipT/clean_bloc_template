import 'package:core/core.dart';
import 'package:flutter_bloc_template/features/posts/data/posts_remote_data_source.dart';
import 'package:flutter_bloc_template/features/posts/domain/post.dart';
import 'package:flutter_bloc_template/features/posts/domain/post_repository.dart';

class PostsRepositoryImpl implements PostRepository {
  const PostsRepositoryImpl(this._remote);

  final PostsRemoteDataSource _remote;

  @override
  Future<Result<List<Post>>> getPosts() async {
    final result = await _remote.fetchPosts();
    return result.map((models) => [for (final m in models) m.toEntity()]);
  }
}
