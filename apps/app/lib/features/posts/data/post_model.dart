import 'package:flutter_bloc_template/features/posts/domain/post.dart';

class PostModel {
  const PostModel({required this.id, required this.title, required this.body});

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: json['id'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
  );

  /// Throws on an unexpected payload; `ApiClient` maps that to a failure.
  static List<PostModel> listFromJson(Object? json) => [
    for (final item in json! as List<dynamic>)
      PostModel.fromJson(item as Map<String, dynamic>),
  ];

  final int id;
  final String title;
  final String body;

  Post toEntity() => Post(id: id, title: title, body: body);
}
