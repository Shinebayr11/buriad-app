@Tags(['golden'])
library;

import 'package:buriad_ug/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_word_store.dart';

void main() {
  testWidgets('угтах дэлгэцийн golden зураг', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(BuriadUgApp(store: FakeWordStore()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/welcome.png'),
    );
  });
}
