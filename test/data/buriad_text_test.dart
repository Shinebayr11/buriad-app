import 'package:buriad_ug/data/buriad_text.dart';
import 'package:buriad_ug/models/word_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ү Ө Һ үсгийг цагаан толгойн зөв байранд эрэмбэлнэ', () {
    final values = ['ү', 'х', 'ө', 'п', 'һ', 'у', 'о'];

    values.sort(compareBuriadText);

    expect(values, ['о', 'ө', 'п', 'у', 'ү', 'х', 'һ']);
  });

  test('ҮӨҺ үөһ үсгийг том жижиг ялгалгүй хайна', () {
    const words = [
      WordEntry(buriad: 'ТУРШИЛТ-ҮӨҺ', mongolian: 'туршилт 1'),
      WordEntry(buriad: 'ТУРШИЛТ-2', mongolian: 'туршилт үөһ'),
      WordEntry(buriad: 'ТУРШИЛТ-3', mongolian: 'туршилт 3'),
    ];

    expect(searchAndSortWords(words, 'үөһ'), hasLength(2));
    expect(searchAndSortWords(words, 'ҮӨҺ'), hasLength(2));
  });

  test('хоосон жагсаалтын хайлт хоосон байна', () {
    expect(searchAndSortWords(const [], 'ҮӨҺ'), isEmpty);
  });
}
