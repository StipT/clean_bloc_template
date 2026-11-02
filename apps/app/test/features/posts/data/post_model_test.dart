import 'package:flutter_bloc_template/features/posts/data/post_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a JSON object into a model and entity', () {
    final model = PostModel.fromJson(const {
      'id': 1,
      'userId': 2,
      'title': 't',
      'body': 'b',
    });

    expect(model.toEntity().id, 1);
    expect(model.toEntity().title, 't');
    expect(model.toEntity().body, 'b');
  });

  test('parses a JSON list', () {
    final models = PostModel.listFromJson(const [
      {'id': 1, 'userId': 1, 'title': 'a', 'body': 'b'},
    ]);

    expect(models, hasLength(1));
  });

  test('throws on a non-list payload so the client maps it to a failure', () {
    expect(() => PostModel.listFromJson(const {'a': 1}), throwsA(anything));
  });
}
