import 'dart:convert';

import 'package:buriad_app/models/story.dart';
import 'package:flutter_test/flutter_test.dart';

/// Архивын бүтцийн жишээ. Буриад бичвэрийг зохиохгүй (CLAUDE.md) тул
/// текстийн талбарт зориуд танигдахуйц орлуулагч тавьсан.
Map<String, dynamic> sampleStory({
  String id = 'test-001',
  bool publicInApp = true,
  bool nameCredited = true,
  String dialect = 'хори',
  List<Map<String, dynamic>>? segments,
}) =>
    {
      'id': id,
      'title': {'b': '<буриад гарчиг>', 'm': '<монгол гарчиг>'},
      'genre': 'үлгэр',
      'audio': {
        'app': 'stories/$id.m4a',
        'master': '/archive/masters/$id.wav',
        'duration': 12.0,
        'recordedAt': '2026-09-08',
        'recordedIn': 'Дадал сум, Хэнтий',
        'recordedBy': 'Бичсэн хүн',
        'equipment': 'Zoom H5',
      },
      'narrator': {
        'name': 'Ярьсан хүн',
        'birthYear': 1948,
        'birthPlace': 'Дадал сум',
        'dialect': dialect,
        'dialectVerifiedBy': 'Хэл шинжээч',
        'learnedFrom': 'Эмээгээсээ',
      },
      'transcript': {
        'by': 'Буулгасан хүн',
        'date': '2026-09-09',
        'verifiedBy': 'Хэл шинжээч',
      },
      'rights': {
        'consentOn': '2026-09-08',
        'consentForm': 'archive/consent/$id.pdf',
        'publicInApp': publicInApp,
        'openToResearchers': true,
        'aiTrainingAllowed': false,
        'nameCredited': nameCredited,
        'withdrawableBy': 'Ярьсан хүн ба гэр бүл',
        'license': 'CC-BY-NC-4.0',
        'tkLabels': ['TK Attribution'],
      },
      'segments': segments ??
          [
            {'start': 0.0, 'end': 6.0, 'b': '<хэсэг 1>', 'm': '<орчуулга 1>'},
            {'start': 6.0, 'end': 12.0, 'b': '<хэсэг 2>', 'm': '<орчуулга 2>'},
          ],
      'notes': '',
    };

Map<String, dynamic> archive(List<Map<String, dynamic>> stories) =>
    {'schema': StoryArchive.currentSchema, 'stories': stories};

void main() {
  group('Аялгуу', () {
    test('гурван аялгууг таних', () {
      expect(Dialect.parse('хори'), Dialect.khori);
      expect(Dialect.parse('ага'), Dialect.aga);
      expect(Dialect.parse('сартуул'), Dialect.sartuul);
    });

    test('танихгүй аялгууг хүлээж авахгүй', () {
      expect(Dialect.parse('буриад'), isNull);
      expect(Dialect.parse(''), isNull);
      expect(Dialect.parse(null), isNull);
      expect(Dialect.parse('хори/ага'), isNull,
          reason: 'аялгууг хольж нэгтгэхгүй');
    });
  });

  group('Зөвшөөрөл', () {
    test('publicInApp false бол тоглуулахгүй', () {
      final s = Story.fromJson(sampleStory(publicInApp: false));
      expect(s.playableInApp, isFalse);
      expect(s.archiveProblems, isEmpty,
          reason: 'архивын хувьд бүрэн ч аппад гарахгүй');
    });

    test('publicInApp true бөгөөд аудио, хэсэг бүрэн бол тоглуулна', () {
      expect(Story.fromJson(sampleStory()).playableInApp, isTrue);
    });

    test('аудиогүй бол тоглуулахгүй', () {
      final j = sampleStory();
      (j['audio'] as Map)['app'] = '';
      expect(Story.fromJson(j).playableInApp, isFalse);
    });

    test('хэсэггүй бол тоглуулахгүй', () {
      expect(Story.fromJson(sampleStory(segments: [])).playableInApp, isFalse);
    });

    test('нэр гаргах зөвшөөрөлгүй бол нэр хоосон', () {
      expect(Story.fromJson(sampleStory(nameCredited: false)).creditedName, '');
      expect(Story.fromJson(sampleStory()).creditedName, 'Ярьсан хүн');
    });

    test('AI сургалтын зөвшөөрөл анхдагчаар хаалттай', () {
      final s = Story.fromJson({'id': 'x'});
      expect(s.rights.aiTrainingAllowed, isFalse);
      expect(s.rights.publicInApp, isFalse);
      expect(s.rights.openToResearchers, isFalse);
    });
  });

  group('Архивын бүрэн бүтэн байдал', () {
    test('бүрэн бичлэгт гомдол алга', () {
      expect(Story.fromJson(sampleStory()).archiveProblems, isEmpty);
    });

    test('аялгуу дутуу бол заана', () {
      final p = Story.fromJson(sampleStory(dialect: '')).archiveProblems;
      expect(p, contains('аялгуу (хори / ага / сартуул)'));
    });

    test('зөвшөөрлийн мэдээлэл дутуу бол заана', () {
      final j = sampleStory();
      (j['rights'] as Map)['consentOn'] = '';
      (j['rights'] as Map)['consentForm'] = '';
      final p = Story.fromJson(j).archiveProblems;
      expect(p, contains('зөвшөөрөл авсан огноо'));
      expect(p, contains('бичгийн зөвшөөрлийн байршил'));
    });

    test('эх хувийн байршил дутуу бол заана', () {
      final j = sampleStory();
      (j['audio'] as Map)['master'] = '';
      expect(Story.fromJson(j).archiveProblems, contains('эх хувийн байршил'));
    });

    test('хэсгийн цаг буруу бол заана', () {
      final j = sampleStory(segments: [
        {'start': 6.0, 'end': 2.0, 'b': '<хэсэг>', 'm': ''},
      ]);
      expect(Story.fromJson(j).archiveProblems,
          contains('1-р хэсгийн цаг эсвэл бичвэр буруу'));
    });
  });

  group('Хэсгийн цаг', () {
    test('тухайн секундэд аль хэсэг дуугарч байгааг олно', () {
      final s = Story.fromJson(sampleStory());
      expect(s.segments[0].contains(0), isTrue);
      expect(s.segments[0].contains(5.9), isTrue);
      expect(s.segments[0].contains(6), isFalse, reason: 'заагийг давхцуулахгүй');
      expect(s.segments[1].contains(6), isTrue);
      expect(s.segments[1].contains(12), isFalse);
    });
  });

  group('Файл унших', () {
    test('зөв файлыг уншина', () {
      final a = StoryArchive.parse(archive([sampleStory()]));
      expect(a, isNotNull);
      expect(a!.stories, hasLength(1));
      expect(a.playable, hasLength(1));
    });

    test('нээхгүй бичлэгийг playable-д оруулахгүй', () {
      final a = StoryArchive.parse(archive([
        sampleStory(id: 'a'),
        sampleStory(id: 'b', publicInApp: false),
      ]));
      expect(a!.stories, hasLength(2), reason: 'архивт хоёулаа үлдэнэ');
      expect(a.playable.map((s) => s.id), ['a']);
    });

    test('schema таарахгүй бол голно', () {
      expect(StoryArchive.parse({'schema': 'өөр/9', 'stories': []}), isNull);
      expect(StoryArchive.parse({'stories': []}), isNull);
    });

    test('давхардсан id бол голно', () {
      final a = StoryArchive.parse(
          archive([sampleStory(id: 'x'), sampleStory(id: 'x')]));
      expect(a, isNull);
    });

    test('id хоосон бол голно', () {
      expect(StoryArchive.parse(archive([sampleStory(id: '')])), isNull);
    });

    test('жагсаалт биш бол голно', () {
      expect(StoryArchive.parse({'schema': StoryArchive.currentSchema, 'stories': 5}),
          isNull);
      expect(StoryArchive.parse('текст'), isNull);
    });

    test('хоосон архив зөвшөөрөгдөнө', () {
      final a = StoryArchive.parse(archive([]));
      expect(a, isNotNull);
      expect(a!.stories, isEmpty);
    });
  });

  test('toJson нь fromJson-ын эсрэг үйлдэл', () {
    final s = Story.fromJson(sampleStory());
    final again = Story.fromJson(s.toJson());
    expect(jsonEncode(again.toJson()), jsonEncode(s.toJson()));
  });
}
