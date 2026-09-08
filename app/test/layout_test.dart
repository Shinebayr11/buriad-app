import 'package:buriad_app/main.dart';
import 'package:buriad_app/state/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_store.dart';

/// Янз бүрийн дэлгэцийн хэмжээнд layout халин гарахгүй байхыг шалгана.
void main() {
  Future<void> pumpAt(WidgetTester tester, Size logical) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = logical;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final state = GameState(FakeStore(sampleWords()));
    await state.init();
    await tester.pumpWidget(BuriadApp(state: state));
    await tester.pumpAndSettle();
  }

  // Жижиг, том, маш намхан — бүгд халилтгүй байх ёстой.
  const sizes = <String, Size>{
    'iPhone SE (жижиг утас)': Size(320, 568),
    'iPhone 13 mini': Size(375, 812),
    'iPhone 15 Pro Max': Size(430, 932),
    'Android таблет': Size(800, 1280),
    'маш намхан цонх': Size(400, 300),
  };

  sizes.forEach((name, size) {
    testWidgets('$name дээр халилт гарахгүй', (tester) async {
      await pumpAt(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('Тааварлах'), findsOneWidget);
    });
  });

  testWidgets('бүх таб бүх хэмжээнд халилтгүй нээгдэнэ', (tester) async {
    for (final size in sizes.values) {
      await pumpAt(tester, size);
      for (final tab in ['Хос олох', 'Үг нэмэх', 'Тааварлах']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '$tab таб ${size.width.toInt()}×${size.height.toInt()} дээр');
      }
    }
  });
}
