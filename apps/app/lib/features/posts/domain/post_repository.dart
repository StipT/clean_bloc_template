import 'package:core/core.dart';
import 'package:flutter_bloc_template/features/posts/domain/post.dart';

// ignore: one_member_abstracts, a seam for the data layer to implement.
abstract interface class PostRepository {
  Future<Result<List<Post>>> getPosts();
}
