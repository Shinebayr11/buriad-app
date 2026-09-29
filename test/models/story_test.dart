import 'package:buriad_ug/models/story.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('хоосон архивыг уншина', () {
    final archive = StoryArchive.fromJson({
      'schema': 'buriad-archive/1',
      'stories': <Object>[],
    });

    expect(archive.schema, 'buriad-archive/1');
    expect(archive.stories, isEmpty);
  });

  test('дэмжигдэхгүй schema-г зөвшөөрөхгүй', () {
    expect(
      () => StoryArchive.fromJson({'schema': 'ТУРШИЛТ-1', 'stories': []}),
      throwsFormatException,
    );
  });
}
