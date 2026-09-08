import 'package:buriad_app/data/word_store.dart';
import 'package:buriad_app/models/word.dart';

/// Санах ойд ажиллах үгийн сан.
///
/// Widget тестүүд UI-г шалгах учиртай тул жинхэнэ WordStore-ыг (SharedPreferences
/// болон asset bundle) оролцуулахгүй — тэдгээр нь тест хооронд хүлээгдэж буй
/// таймер үлдээж, дараагийн тестийг гацаадаг. Багцын жинхэнэ файлыг
/// bundled_words_test.dart тусад нь шалгана.
class FakeStore implements WordStore {
  FakeStore(this.bundled, {this.saved});

  final List<Word> bundled;
  List<Word>? saved;
  int saveCount = 0;

  @override
  Future<List<Word>> loadBundled() async => bundled;

  @override
  Future<List<Word>?> loadSaved() async => saved;

  @override
  Future<void> save(List<Word> words) async {
    saved = words;
    saveCount++;
  }

  @override
  Future<void> clearSaved() async => saved = null;
}

/// words.json-той ижил бүтэцтэй жишээ сан (14 бичлэг).
List<Word> sampleWords() => const [
      Word(b: 'эжы', m: 'ээж', e: '👩'),
      Word(b: 'аба', m: 'аав', e: '👨'),
      Word(b: 'уһан', m: 'ус', e: '💧', n: 'Монгол с → буриад һ'),
      Word(b: 'һара', m: 'сар', e: '🌙', n: 'Монгол с → буриад һ'),
      Word(b: 'загаһан', m: 'загас', e: '🐟', n: 'Монгол с → буриад һ'),
      Word(b: 'үнеэн', m: 'үнээ', e: '🐄'),
      Word(b: 'морин', m: 'морь', e: '🐎', n: 'Үгийн эцсийн н хадгалагдана'),
      Word(b: 'хонин', m: 'хонь', e: '🐑', n: 'Үгийн эцсийн н хадгалагдана'),
      Word(b: 'тэмээн', m: 'тэмээ', e: '🐫', n: 'Үгийн эцсийн н хадгалагдана'),
      Word(b: 'шубуун', m: 'шувуу', e: '🐦'),
      Word(b: 'модон', m: 'мод', e: '🌳'),
      Word(b: 'нохой', m: 'нохой', e: '🐕', n: 'Хоёр хэлэнд ижил'),
      Word(b: 'гэр', m: 'гэр', e: '🏠', n: 'Хоёр хэлэнд ижил'),
      Word(b: 'гал', m: 'гал', e: '🔥', n: 'Хоёр хэлэнд ижил'),
    ];
