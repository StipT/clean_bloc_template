import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/features/posts/domain/get_posts.dart';
import 'package:flutter_bloc_template/features/posts/domain/post.dart';

sealed class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

class PostsRequested extends PostsEvent {
  const PostsRequested();
}

enum PostsStatus { initial, loading, loaded, failure }

class PostsState extends Equatable {
  const PostsState({
    required this.status,
    this.posts = const [],
    this.errorMessage,
  });

  const PostsState.initial() : this(status: PostsStatus.initial);

  final PostsStatus status;
  final List<Post> posts;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, posts, errorMessage];
}

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc(this._getPosts) : super(const PostsState.initial()) {
    on<PostsRequested>(_onRequested);
  }

  final GetPosts _getPosts;

  Future<void> _onRequested(
    PostsRequested event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsState(status: PostsStatus.loading));
    final result = await _getPosts();
    emit(
      result.when(
        success: (posts) =>
            PostsState(status: PostsStatus.loaded, posts: posts),
        failure: (f) =>
            PostsState(status: PostsStatus.failure, errorMessage: f.message),
      ),
    );
  }
}
