import 'package:buriad_app/main.dart';
import 'package:buriad_app/state/game_state.dart';
import 'package:buriad_app/widgets/word_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_store.dart';

/// Аппын UI-г бүтнээр нь турших тестүүд. Үгийн сан нь санах ойд (FakeStore)
/// — багцын жинхэнэ файлыг bundled_words_test.dart шалгана.
void main() {
  // Тестийн анхны 800×600 дэлгэцэд хариултууд доош гарч, товшилт оносонгүй.
  // Утасны хэмжээнд ойртуулна.
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1170, 2532); // iPhone 13 Pro
    view.devicePixelRatio = 3;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });
  });

  /// Талбарт бичээд фокусыг чөлөөлнө.
  ///
  /// Фокус үлдвэл текст сонголтын давхарга (Overlay) доорх товчийг халхалж,
  /// tap нь зорилтот widget дээр буудаггүй.
  Future<void> typeInto(WidgetTester tester, int index, String text) async {
    await tester.enterText(find.byType(TextField).at(index), text);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  /// Дэлгэцэд гүйлгэж гаргаад товшино.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// n дэх хариултыг олно (semantics шошгоор — текст давхардсан ч ялгарна).
  Finder answerAt(int n) =>
      find.bySemanticsLabel(RegExp('^Хариулт $n: '));

  /// Санах ойн сангаар аппыг барина — widget тестүүд зөвхөн UI-г шалгана.
  Future<GameState> pumpApp(WidgetTester tester, {FakeStore? store}) async {
    final state = GameState(store ?? FakeStore(sampleWords()));
    await state.init();
    await tester.pumpWidget(BuriadApp(state: state));
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('ачаалж байх үед мэдэгдэл гарч, дараа нь тоглоом солигдоно',
      (tester) async {
    final state = GameState(FakeStore(sampleWords()));
    await tester.pumpWidget(BuriadApp(state: state));

    expect(find.text('Ачааллаж байна...'), findsOneWidget);
    expect(find.text('Тааварлах'), findsNothing);

    await state.init();
    await tester.pumpAndSettle();

    expect(find.text('Ачааллаж байна...'), findsNothing);
    expect(find.text('Тааварлах'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0,
        reason: 'ачаалсны дараа ямар ч анимаци эргэлдэж үлдэх ёсгүй');
  });

  testWidgets('багцын үгийн сан ачаалж, Тааварлах нээгдэнэ', (tester) async {
    final state = await pumpApp(tester);

    expect(state.load, LoadState.ready);
    expect(state.words, hasLength(14));
    expect(find.text('Ачааллаж байна...'), findsNothing);

    expect(find.text('Буриад үг'), findsOneWidget);
    expect(find.text('БУРИАД ХЭЛНИЙ КАРТ'), findsOneWidget);
    expect(find.text('0'), findsWidgets); // оноо ба бөгжний тоо
    for (var i = 1; i <= 4; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('зөв хариулахад оноо нэмэгдэж, дүгнэлт гарна', (tester) async {
    final state = await pumpApp(tester);
    final q = state.q!;
    final rightAt = q.opts.indexWhere((o) => identical(o, q.right));

    await tapVisible(tester, answerAt(rightAt + 1));

    expect(state.lastCorrect, isTrue);
    expect(find.text('Зөв'), findsOneWidget);
    expect(find.text('10'), findsWidgets);
    expect(find.text('Дараагийн үг'), findsOneWidget);
  });

  testWidgets('буруу хариулахад зөв үгийг харуулна', (tester) async {
    final state = await pumpApp(tester);
    final q = state.q!;
    final wrongAt = q.opts.indexWhere((o) => !identical(o, q.right));

    await tapVisible(tester, answerAt(wrongAt + 1));

    expect(find.text('Буруу'), findsOneWidget);
    expect(state.score, 0);
  });

  testWidgets('«Дараагийн үг» дарахад шинэ асуулт ирнэ', (tester) async {
    final state = await pumpApp(tester);
    final first = state.q!;
    final rightAt = first.opts.indexWhere((o) => identical(o, first.right));

    await tapVisible(tester, answerAt(rightAt + 1));
    await tapVisible(tester, find.text('Дараагийн үг'));

    expect(state.q, isNot(same(first)));
    expect(find.text('Дараагийн үг'), findsNothing);
    expect(find.text('Хариултаа сонгоно уу'), findsOneWidget);
  });

  testWidgets('хариулахаас өмнө карт эргэхгүй, хариулсны дараа эргэнэ',
      (tester) async {
    final state = await pumpApp(tester);
    final card = find.text('БУРИАД ХЭЛНИЙ КАРТ');
    final q = state.q!;
    final rightAt = q.opts.indexWhere((o) => identical(o, q.right));

    await tapVisible(tester, card);
    expect(state.flipped, isFalse);

    await tapVisible(tester, answerAt(rightAt + 1));
    await tapVisible(tester, card);

    expect(state.flipped, isTrue);
    expect(find.text('Буцааж дараад үргэлжлүүлнэ үү'), findsOneWidget);
  });

  testWidgets('Хос олох таб 12 карт үүсгэнэ', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Хос олох'));
    await tester.pumpAndSettle();

    expect(find.byType(DefaultMark), findsNWidgets(12));
    expect(find.text('Дахин холих'), findsOneWidget);
  });

  testWidgets('Үг нэмэх таб: үг нэмэхэд сан өснө', (tester) async {
    final state = await pumpApp(tester);

    await tester.tap(find.text('Үг нэмэх'));
    await tester.pumpAndSettle();
    expect(find.text('ҮГИЙН САН · 14'), findsOneWidget);

    await typeInto(tester, 0, 'тэст');
    await typeInto(tester, 1, 'test');
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Үг нэмэх'));

    expect(state.words, hasLength(15));
    expect(find.text('ҮГИЙН САН · 15'), findsOneWidget);
  });

  testWidgets('Буриад үг хоосон бол нэмэхгүй', (tester) async {
    final state = await pumpApp(tester);

    await tester.tap(find.text('Үг нэмэх'));
    await tester.pumpAndSettle();
    await typeInto(tester, 1, 'зөвхөн монгол');
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Үг нэмэх'));

    expect(state.words, hasLength(14));
  });

  testWidgets('Ү Ө Һ товчлуур буриад талбарт үсэг оруулна', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Үг нэмэх'));
    await tester.pumpAndSettle();

    await typeInto(tester, 0, 'у');
    await tapVisible(tester, find.widgetWithText(GestureDetector, 'һ').last);

    final field = tester.widget<TextField>(find.byType(TextField).at(0));
    expect(field.controller!.text, 'уһ');
  });

  testWidgets('дуудлага ороогүй үгэд мэдэгдэл гарна', (tester) async {
    await pumpApp(tester);
    // Жишээ сангийн бүх үгэд дуудлага ороогүй.
    expect(find.text('Дуудлага ороогүй'), findsOneWidget);
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
  });

  testWidgets('үсгийн шалгалтын зургаан үсэг харагдана', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Үг нэмэх'));
    await tester.pumpAndSettle();
    expect(find.text('Үү Өө Һһ Ээ Ёё'), findsOneWidget);
  });
}
