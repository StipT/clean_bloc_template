import 'package:core/core.dart';
import 'package:flutter_bloc_template/features/posts/data/post_model.dart';
import 'package:network/network.dart';

class PostsRemoteDataSource {
  const PostsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Result<List<PostModel>>> fetchPosts() =>
      _client.get('/posts', parse: PostModel.listFromJson);
}
