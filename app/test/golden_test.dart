@Tags(['golden'])
library;

import 'dart:io';
import 'dart:math';

import 'package:buriad_app/main.dart';
import 'package:buriad_app/state/game_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_store.dart';

/// Гурван табын жинхэнэ дүрсийг багцалсан фонтоор нь гаргаж, өмнөх зурагтай
/// харьцуулна. Шинэчлэх:  flutter test --update-goldens --tags golden
void main() {
  setUpAll(() async {
    // Тест анхдагчаар Ahem фонт зурдаг. Жинхэнэ фонтоо ачаалж, Ү Ө Һ үсэг
    // хэрхэн гарахыг нүдээр шалгах боломжтой болгоно.
    Future<void> load(String family, String path) async {
      final loader = FontLoader(
        family,
      )..addFont(File(path).readAsBytes().then((b) => ByteData.sublistView(b)));
      await loader.load();
    }

    for (final family in ['Onest', 'GolosText']) {
      await load(family, 'assets/fonts/$family.ttf');
    }
    // Material Icons ачаалахгүй бол icon-ууд хоосон дөрвөлжин болж, зураг
    // жинхэнэ аппаас зөрнө.
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

    // Тогтмол үр — асуулт болгонд ижил үг сонгогдож, зураг давтагдана.
    final state = GameState(FakeStore(sampleWords()), random: Random(42));
    await state.init();
    await tester.pumpWidget(BuriadApp(state: state));
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('Тааварлах', (tester) async {
    final state = await pump(tester);
    // Асуулт санамсаргүй тул зургийг тогтвортой болгохын тулд эхний үгээр
    // гараар барина.
    state.answer(state.q!.opts.first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BuriadApp),
      matchesGoldenFile('goldens/guess.png'),
    );
  });

  testWidgets('Хос олох', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Хос олох'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BuriadApp),
      matchesGoldenFile('goldens/pairs.png'),
    );
  });

  testWidgets('Үг нэмэх', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Үг нэмэх'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BuriadApp),
      matchesGoldenFile('goldens/edit.png'),
    );
  });
}
