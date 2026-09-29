import 'package:buriad_ug/data/word_codec.dart';
import 'package:buriad_ug/models/word_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('үгийг JSON-оос уншаад буцаан бичнэ', () {
    final word = WordEntry.fromJson({
      'b': 'ТУРШИЛТ-1',
      'm': 'туршилт 1',
      'e': '',
      'n': 'ҮӨҺ үөһ',
      'a': '',
      'dialect': 'хори',
      'source': 'ТУРШИЛТ-2',
      'verifiedBy': 'ТУРШИЛТ-3',
    });

    expect(word.buriad, 'ТУРШИЛТ-1');
    expect(WordEntry.fromJson(word.toJson()), word);
  });

  test('хоосон болон буруу бичлэгийг алгасана', () {
    const source = '''
      [
        {"b":"ТУРШИЛТ-1","m":"туршилт 1"},
        {"b":"","m":"туршилт 2"},
        {"b":"ТУРШИЛТ-3"},
        "буруу"
      ]
    ''';

    final result = decodeWords(source);

    expect(result.words, hasLength(1));
    expect(result.skipped, 3);
  });

  test('буруу аялгууг зөвшөөрөхгүй', () {
    expect(
      () => WordEntry.fromJson({
        'b': 'ТУРШИЛТ-1',
        'm': 'туршилт 1',
        'dialect': 'ТУРШИЛТ-2',
      }),
      throwsFormatException,
    );
  });
}
