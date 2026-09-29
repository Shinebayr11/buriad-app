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

  test('дууны ангилал ба эх сурвалжийг уншина', () {
    final archive = StoryArchive.fromJson({
      'schema': 'buriad-archive/1',
      'stories': [
        {
          'id': 'ТУРШИЛТ-1',
          'title': {'b': 'ТУРШИЛТ-1', 'm': 'туршилт 1'},
          'genre': 'дуу',
          'audio': {
            'app': '',
            'master': '',
            'duration': 0,
            'recordedAt': '',
            'recordedIn': '',
            'recordedBy': '',
            'equipment': '',
          },
          'narrator': {
            'name': '',
            'birthYear': null,
            'birthplace': '',
            'dialect': 'тэмдэглээгүй',
          },
          'rights': {
            'consentOn': '',
            'consentForm': '',
            'publicInApp': true,
            'openToResearchers': false,
            'aiTrainingAllowed': false,
            'nameCredited': true,
            'withdrawableBy': '',
            'license': '',
            'tkLabels': <String>[],
          },
          'transcript': {'by': '', 'date': '', 'verifiedBy': ''},
          'segments': <Object>[],
          'notes': '',
          'performer': 'ТУРШИЛТ-1',
          'sourceUrl': 'https://toonto.mn/',
        },
      ],
    });

    expect(archive.stories.single.genre, 'дуу');
    expect(archive.stories.single.performer, 'ТУРШИЛТ-1');
    expect(archive.stories.single.sourceUrl, 'https://toonto.mn/');
  });
}
