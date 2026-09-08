import 'package:buriad_app/data/word_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_store.dart';

/// Багцад орсон assets/data/words.json файлыг жинхэнээр нь уншиж шалгана.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('assets/data/words.json уншигдаж, бүх бичлэг бүрэн бүтэн', () async {
    final words = await WordStore().loadBundled();

    expect(words, hasLength(14));
    for (final w in words) {
      expect(w.b, isNotEmpty, reason: 'буриад үг хоосон байж болохгүй');
      expect(w.m, isNotEmpty, reason: 'монгол утга хоосон байж болохгүй');
      expect(w.e, isNotEmpty, reason: 'зураг нь ядаж ◈ байна');
    }
  });

  test('буриад үгс давхардаагүй', () async {
    final words = await WordStore().loadBundled();
    expect(words.map((w) => w.b).toSet(), hasLength(words.length));
  });

  test('тестийн жишээ сан багцын файлтай тохирч байна', () async {
    final bundled = await WordStore().loadBundled();
    final sample = sampleWords();

    expect(sample, hasLength(bundled.length));
    for (var i = 0; i < bundled.length; i++) {
      expect(sample[i].b, bundled[i].b);
      expect(sample[i].m, bundled[i].m);
    }
  });

  test('Ү Ө Һ агуулсан үгс байгаа бөгөөд зөв кодлогдсон', () async {
    final words = await WordStore().loadBundled();
    final all = words.map((w) => w.b).join();

    expect(all, contains('һ')); // U+04BB
    expect(all, contains('ү')); // U+04AF
    expect(all.contains('h'), isFalse, reason: 'латин h биш кирилл һ байх ёстой');
  });
}
