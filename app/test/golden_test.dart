@Tags(['golden'])
library;

import 'dart:io';
import 'dart:math';

import 'package:buriad_app/main.dart';
import 'package:buriad_app/state/game_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_store.dart';

/// Нүүр болон дэд дэлгэцүүдийн жинхэнэ дүрсийг багцалсан фонтоор нь гаргаж,
/// өмнөх зурагтай харьцуулна.
/// Шинэчлэх:  flutter test --update-goldens --tags golden
void main() {
  setUpAll(() async {
    Future<void> load(String family, String path) async {
      final loader = FontLoader(family)
        ..addFont(File(path).readAsBytes().then((b) => ByteData.sublistView(b)));
      await loader.load();
    }

    for (final family in ['Onest', 'GolosText']) {
      await load(family, 'assets/fonts/$family.ttf');
    }
    // Material Icons ачаалахгүй бол icon-ууд хоосон дөрвөлжин болно.
    final root = Platform.environment['FLUTTER_ROOT'];
    if (root != null) {
      await load(
        'MaterialIcons',
        '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      );
    }
  });

  Future<GameState> pump(WidgetTester tester) async {
    tester.view
      ..devicePixelRatio = 2
      ..physicalSize = const Size(750, 1624); // 375×812 логик

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Тогтмол үр — асуулт давтагдаж, зураг тогтвортой болно.
    final state = GameState(
      FakeStore(sampleWords()),
      stories: FakeStoryStore(),
      random: Random(42),
    );
    await state.init();
    await tester.pumpWidget(BuriadApp(state: state));
    await tester.pumpAndSettle();
    return state;
  }

  /// Угтах хуудсаар дамжиж нүүр рүү.
  Future<GameState> pumpHome(WidgetTester tester) async {
    final state = await pump(tester);
    await tester.tap(find.text('Бүртгэлгүйгээр үзэх'));
    await tester.pumpAndSettle();
    return state;
  }

  Future<void> shoot(WidgetTester tester, String name) => expectLater(
        find.byType(BuriadApp),
        matchesGoldenFile('goldens/$name.png'),
      );

  testWidgets('Угтах хуудас', (tester) async {
    await pump(tester);
    await shoot(tester, 'landing');
  });

  testWidgets('Бүртгүүлэх', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Бүртгүүлэх'));
    await tester.pumpAndSettle();
    await shoot(tester, 'signup');
  });

  testWidgets('Нүүр', (tester) async {
    await pumpHome(tester);
    await shoot(tester, 'home');
  });

  testWidgets('Тааварлах', (tester) async {
    final state = await pumpHome(tester);
    await tester.tap(find.text('Тааварлах'));
    await tester.pumpAndSettle();
    state.answer(state.q!.opts.first);
    await tester.pumpAndSettle();
    await shoot(tester, 'guess');
  });

  testWidgets('Хос олох', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('Хос олох'));
    await tester.pumpAndSettle();
    await shoot(tester, 'pairs');
  });

  testWidgets('Үг нэмэх', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('Үг нэмэх, засах'));
    await tester.pumpAndSettle();
    await shoot(tester, 'edit');
  });

  testWidgets('Ангиллын хоосон төлөв', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('Үлгэр'));
    await tester.pumpAndSettle();
    await shoot(tester, 'genre_empty');
  });
}
