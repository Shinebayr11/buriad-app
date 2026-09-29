import 'dart:convert';

import 'package:buriad_ug/data/story_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('зөвхөн аппад нийтлэх зөвшөөрөлтэй бичлэгийг уншина', () async {
    final source = jsonEncode({
      'schema': 'buriad-archive/1',
      'stories': [
        _story('ТУРШИЛТ-1', publicInApp: true),
        _story('ТУРШИЛТ-2', publicInApp: false),
      ],
    });
    final repository = StoryRepository(bundle: _StringBundle(source));

    final stories = await repository.loadPublicStories();

    expect(stories, hasLength(1));
    expect(stories.single.id, 'ТУРШИЛТ-1');
    expect(stories.single.segments.single.text.buriad, 'ТУРШИЛТ-3');
  });
}

Map<String, Object?> _story(String id, {required bool publicInApp}) => {
  'id': id,
  'title': {'b': 'ТУРШИЛТ-1', 'm': 'туршилт 1'},
  'genre': 'үлгэр',
  'audio': {
    'app': 'ТУРШИЛТ-1.aac',
    'master': '',
    'duration': 4,
    'recordedAt': '',
    'recordedIn': '',
    'recordedBy': '',
    'equipment': '',
  },
  'narrator': {
    'name': 'ТУРШИЛТ-2',
    'birthYear': null,
    'birthplace': '',
    'dialect': 'хори',
  },
  'rights': {
    'consentOn': '',
    'consentForm': '',
    'publicInApp': publicInApp,
    'openToResearchers': false,
    'aiTrainingAllowed': false,
    'nameCredited': false,
    'withdrawableBy': '',
    'license': '',
    'tkLabels': <String>[],
  },
  'transcript': {'by': '', 'date': '', 'verifiedBy': ''},
  'segments': [
    {'start': 0, 'end': 4, 'b': 'ТУРШИЛТ-3', 'm': 'туршилт 3'},
  ],
  'notes': '',
};

class _StringBundle extends CachingAssetBundle {
  _StringBundle(this.source);

  final String source;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(source));
    return ByteData.sublistView(bytes);
  }
}
