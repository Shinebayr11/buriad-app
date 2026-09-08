import 'package:buriad_app/models/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Word.fromJson', () {
    test('дутуу талбарыг анхны утгаар нөхнө', () {
      final w = Word.fromJson({'b': 'уһан', 'm': 'ус'});
      expect(w.e, Word.defaultMark);
      expect(w.n, '');
      expect(w.a, '');
      expect(w.hasAudio, isFalse);
    });

    test('хоосон эможиг ◈ болгоно', () {
      expect(Word.fromJson({'b': 'гал', 'm': 'гал', 'e': ''}).e, Word.defaultMark);
    });

    test('хоёр талын зайг арилгана', () {
      final w = Word.fromJson({'b': '  һара ', 'm': ' сар '});
      expect(w.b, 'һара');
      expect(w.m, 'сар');
    });

    test('http эхэлсэн эможиг зураг гэж үзнэ', () {
      expect(Word.fromJson({'b': 'a', 'm': 'b', 'e': 'https://x/y.png'}).hasImage, isTrue);
      expect(Word.fromJson({'b': 'a', 'm': 'b', 'e': '💧'}).hasImage, isFalse);
    });
  });

  group('Word.parseList', () {
    test('зөв жагсаалтыг уншина', () {
      final list = Word.parseList([
        {'b': 'эжы', 'm': 'ээж'},
        {'b': 'аба', 'm': 'аав'},
      ]);
      expect(list, hasLength(2));
      expect(list!.first.b, 'эжы');
    });

    test('b эсвэл m дутуу бол бүхэл файлыг голно', () {
      expect(Word.parseList([{'b': 'эжы'}]), isNull);
      expect(Word.parseList([{'m': 'ээж'}]), isNull);
      expect(Word.parseList([{'b': '  ', 'm': 'ээж'}]), isNull);
    });

    test('жагсаалт биш бол null', () {
      expect(Word.parseList({'b': 'a', 'm': 'b'}), isNull);
      expect(Word.parseList('юу ч биш'), isNull);
    });

    test('хоосон жагсаалт зөвшөөрөгдөнө', () {
      expect(Word.parseList([]), isEmpty);
    });
  });

  test('toJson нь fromJson-ын эсрэг үйлдэл', () {
    const w = Word(b: 'морин', m: 'морь', e: '🐎', n: 'эцсийн н', a: '');
    expect(Word.fromJson(w.toJson()).toJson(), w.toJson());
  });
}
