import 'package:buriad_ug/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_word_store.dart';

void main() {
  testWidgets('хоосон үгийн сангийн төлөв харагдана', (tester) async {
    await tester.pumpWidget(BuriadUgApp(store: FakeWordStore()));
    await tester.pumpAndSettle();

    expect(find.text('Үгийн сан хоосон байна'), findsOneWidget);
    expect(find.text('Үг нэмэх'), findsWidgets);
  });

  testWidgets('Ү Ө Һ үсгийг курсорын байрлалд оруулна', (tester) async {
    await tester.pumpWidget(BuriadUgApp(store: FakeWordStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Үг нэмэх').first);
    await tester.pumpAndSettle();

    final field = find.widgetWithText(TextFormField, 'Буриад үг *');
    await tester.enterText(field, 'ТУРШИЛТ-1');
    await tester.tap(find.widgetWithText(ActionChip, 'Ү'));
    await tester.pump();

    expect(find.text('ТУРШИЛТ-1Ү'), findsOneWidget);
  });
}
