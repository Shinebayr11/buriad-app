import 'package:buriad_ug/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_word_store.dart';

void main() {
  Future<void> openHome(WidgetTester tester) async {
    final guestButton = find.text('Бүртгэлгүйгээр үзэх');
    await tester.ensureVisible(guestButton);
    await tester.pumpAndSettle();
    await tester.tap(guestButton);
    await tester.pumpAndSettle();
  }

  testWidgets('угтах дэлгэц гурван сонголттой', (tester) async {
    await tester.pumpWidget(BuriadUgApp(store: FakeWordStore()));
    await tester.pumpAndSettle();

    expect(find.text('Нэвтрэх'), findsOneWidget);
    expect(find.text('Бүртгүүлэх'), findsOneWidget);
    expect(find.text('Бүртгэлгүйгээр үзэх'), findsOneWidget);
  });

  testWidgets('хоосон үгийн сангийн төлөв харагдана', (tester) async {
    await tester.pumpWidget(
      BuriadUgApp(store: FakeWordStore(), adminMode: true),
    );
    await tester.pumpAndSettle();
    await openHome(tester);
    await tester.tap(find.byTooltip('Үгийн сангийн удирдлага'));
    await tester.pumpAndSettle();

    expect(find.text('Үгийн сан хоосон байна'), findsOneWidget);
    expect(find.text('Үг нэмэх'), findsWidgets);
  });

  testWidgets('Ү Ө Һ үсгийг курсорын байрлалд оруулна', (tester) async {
    await tester.pumpWidget(
      BuriadUgApp(store: FakeWordStore(), adminMode: true),
    );
    await tester.pumpAndSettle();
    await openHome(tester);
    await tester.tap(find.byTooltip('Үгийн сангийн удирдлага'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Үг нэмэх').first);
    await tester.pumpAndSettle();

    final field = find.widgetWithText(TextFormField, 'Буриад үг *');
    await tester.enterText(field, 'ТУРШИЛТ-1');
    await tester.tap(find.widgetWithText(ActionChip, 'Ү'));
    await tester.pump();

    expect(find.text('ТУРШИЛТ-1Ү'), findsOneWidget);
  });

  testWidgets('энгийн хэрэглэгчид үгийн удирдлага харагдахгүй', (tester) async {
    await tester.pumpWidget(BuriadUgApp(store: FakeWordStore()));
    await tester.pumpAndSettle();
    await openHome(tester);

    expect(find.byTooltip('Үгийн сангийн удирдлага'), findsNothing);
    expect(find.text('Үгийн сангийн удирдлага'), findsNothing);
  });

  testWidgets('нэвтрэх маягт буруу утгыг тайлбарлана', (tester) async {
    await tester.pumpWidget(BuriadUgApp(store: FakeWordStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Нэвтрэх'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Нэвтрэх'));
    await tester.pump();

    expect(find.text('И-мэйл хаягаа зөв оруулна уу.'), findsOneWidget);
    expect(
      find.text('Нууц үг 8-аас цөөнгүй тэмдэгттэй байна.'),
      findsOneWidget,
    );
    expect(find.text('Бүртгэлгүйгээр үзэх'), findsOneWidget);
  });

  testWidgets('хоосон аман зохиолын төлөв харагдана', (tester) async {
    await tester.pumpWidget(BuriadUgApp(store: FakeWordStore()));
    await tester.pumpAndSettle();
    await openHome(tester);
    await tester.tap(find.text('Бүгдийг үзэх'));
    await tester.pumpAndSettle();

    expect(find.text('Нийтлэх бичлэг алга'), findsOneWidget);
  });

  testWidgets('320 өргөн ба том текстэд нүүр дэлгэц эвдрэхгүй', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: BuriadUgApp(store: FakeWordStore()),
      ),
    );
    await tester.pumpAndSettle();
    await openHome(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Тоглоом'), findsOneWidget);
  });
}
