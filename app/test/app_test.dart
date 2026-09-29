import 'package:buriad_app/main.dart';
import 'package:buriad_app/state/game_state.dart';
import 'package:buriad_app/widgets/word_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_store.dart';

/// Аппын UI-г бүтнээр нь турших тестүүд. Үгийн сан нь санах ойд (FakeStore)
/// — багцын жинхэнэ файлыг bundled_words_test.dart шалгана.
void main() {
  // Тестийн анхны 800×600 дэлгэцэд агуулга доош гарч, товшилт оносонгүй.
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1170, 2532); // iPhone 13 Pro
    view.devicePixelRatio = 3;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });
  });

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> typeInto(WidgetTester tester, int index, String text) async {
    await tester.enterText(find.byType(TextField).at(index), text);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  /// n дэх хариулт (semantics шошгоор — текст давхардсан ч ялгарна).
  Finder answerAt(int n) => find.bySemanticsLabel(RegExp('^Хариулт $n: '));

  Future<GameState> pumpHome(WidgetTester tester, {FakeStore? store}) async {
    final state = GameState(
      store ?? FakeStore(sampleWords()),
      stories: FakeStoryStore(),
    );
    await state.init();
    await tester.pumpWidget(BuriadApp(state: state));
    await tester.pumpAndSettle();
    // Угтах хуудаснаас нүүр рүү.
    await tester.tap(find.text('Бүртгэлгүйгээр үзэх'));
    await tester.pumpAndSettle();
    return state;
  }

  /// Нүүрнээс нэрлэсэн карт руу орно.
  Future<GameState> open(WidgetTester tester, String card) async {
    final state = await pumpHome(tester);
    await tapVisible(tester, find.text(card));
    return state;
  }

  group('Нүүр дэлгэц', () {
    testWidgets('угтах хуудаснаас нүүр рүү орно',
        (tester) async {
      final state =
          GameState(FakeStore(sampleWords()), stories: FakeStoryStore());
      await tester.pumpWidget(BuriadApp(state: state));

      expect(find.text('Ачааллаж байна...'), findsNothing,
          reason: 'угтах хуудас өгөгдөл хүлээхгүй');
      expect(find.text('Бүртгэлгүйгээр үзэх'), findsOneWidget);

      await state.init();
      await tester.tap(find.text('Бүртгэлгүйгээр үзэх'));
      await tester.pumpAndSettle();

      expect(find.text('ТОГЛООМ'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0,
          reason: 'ачаалсны дараа анимаци эргэлдэж үлдэх ёсгүй');
    });

    testWidgets('гурван хэсэг, тоглоом ба үгийн сангийн тоо харагдана',
        (tester) async {
      await pumpHome(tester);

      for (final section in ['ТОГЛООМ', 'АМАН ЗОХИОЛ', 'ҮГИЙН САН']) {
        expect(find.text(section), findsOneWidget);
      }
      expect(find.text('Тааварлах'), findsOneWidget);
      expect(find.text('Хос олох'), findsOneWidget);
      expect(find.text('Үг нэмэх, засах'), findsOneWidget);
      expect(find.text('14 үг'), findsNWidgets(2)); // тоглоом ба үгийн сан
    });

    testWidgets('дөрвөн ангилал харагдаж, хоосон гэж заана', (tester) async {
      await pumpHome(tester);

      for (final g in ['Үлгэр', 'Домог', 'Түүх', 'Өгүүллэг']) {
        expect(find.text(g), findsOneWidget);
      }
      expect(find.text('хоосон'), findsNWidgets(4),
          reason: 'бичлэг ороогүй тул дөрвүүлээ хоосон');
    });
  });

  group('Угтах хуудас', () {
    Future<GameState> pumpLanding(WidgetTester tester) async {
      final state =
          GameState(FakeStore(sampleWords()), stories: FakeStoryStore());
      await state.init();
      await tester.pumpWidget(BuriadApp(state: state));
      await tester.pumpAndSettle();
      return state;
    }

    testWidgets('гарчиг, гурван сонголт харагдана', (tester) async {
      await pumpLanding(tester);

      expect(find.text('Буриад үг'), findsOneWidget);
      expect(find.text('ХЭЛ · АМАН ЗОХИОЛ · ӨВ'), findsOneWidget);
      expect(find.text('Нэвтрэх'), findsOneWidget);
      expect(find.text('Бүртгүүлэх'), findsOneWidget);
      expect(find.text('Бүртгэлгүйгээр үзэх'), findsOneWidget);
    });

    testWidgets('Бүртгүүлэх дарахад нэр, и-мэйл, нууц үг гарна',
        (tester) async {
      await pumpLanding(tester);
      await tapVisible(tester, find.text('Бүртгүүлэх'));

      expect(find.text('НЭР'), findsOneWidget);
      expect(find.text('И-МЭЙЛ'), findsOneWidget);
      expect(find.text('НУУЦ ҮГ'), findsOneWidget);
    });

    testWidgets('Нэвтрэх дээр нэрийн талбар байхгүй', (tester) async {
      await pumpLanding(tester);
      await tapVisible(tester, find.text('Нэвтрэх'));

      expect(find.text('НЭР'), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('и-мэйл буруу бол алдаа заана', (tester) async {
      await pumpLanding(tester);
      await tapVisible(tester, find.text('Нэвтрэх'));

      await typeInto(tester, 0, 'буруу-хаяг');
      await typeInto(tester, 1, 'нууцүг12345');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Нэвтрэх'));

      expect(find.text('И-мэйл хаяг буруу байна.'), findsOneWidget);
    });

    testWidgets('нууц үг богино бол алдаа заана', (tester) async {
      await pumpLanding(tester);
      await tapVisible(tester, find.text('Нэвтрэх'));

      await typeInto(tester, 0, 'name@example.com');
      await typeInto(tester, 1, 'богино');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Нэвтрэх'));

      expect(find.textContaining('дор хаяж 8 тэмдэгт'), findsWidgets);
    });

    testWidgets('бүрэн бөглөвөл сервер хараахан байхгүйг мэдэгдэнэ',
        (tester) async {
      await pumpLanding(tester);
      await tapVisible(tester, find.text('Нэвтрэх'));

      await typeInto(tester, 0, 'name@example.com');
      await typeInto(tester, 1, 'нууцүг12345');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Нэвтрэх'));

      expect(find.textContaining('Сервер хараахан холбогдоогүй'),
          findsOneWidget);
    });

    testWidgets('нэвтрэлтээс бүртгэлгүйгээр нүүр рүү орно', (tester) async {
      await pumpLanding(tester);
      await tapVisible(tester, find.text('Нэвтрэх'));
      await tapVisible(tester, find.text('Бүртгэлгүйгээр үзэх'));

      expect(find.text('ТОГЛООМ'), findsOneWidget);
    });
  });

  group('Шилжилт', () {
    testWidgets('ангилал нээхэд хоосон төлөв гарна', (tester) async {
      await pumpHome(tester);
      await tapVisible(tester, find.text('Домог'));

      expect(find.text('Бичлэг хараахан ороогүй байна.'), findsOneWidget);
      expect(find.byType(DefaultMark), findsOneWidget);
    });

    testWidgets('буцах товчоор нүүр рүү эргэж ирнэ', (tester) async {
      await pumpHome(tester);
      await tapVisible(tester, find.text('Үлгэр'));
      expect(find.text('ТОГЛООМ'), findsNothing);

      await tapVisible(tester, find.bySemanticsLabel('Буцах'));
      expect(find.text('ТОГЛООМ'), findsOneWidget);
    });

    testWidgets('Хос олох нээхэд 12 карт үүснэ', (tester) async {
      await open(tester, 'Хос олох');
      expect(find.byType(DefaultMark), findsNWidgets(12));
      expect(find.text('Дахин холих'), findsOneWidget);
    });
  });

  group('Тааварлах', () {
    testWidgets('карт, дөрвөн сонголт, оноо гарна', (tester) async {
      await open(tester, 'Тааварлах');

      expect(find.text('БУРИАД ХЭЛНИЙ КАРТ'), findsOneWidget);
      expect(find.text('ОНОО'), findsOneWidget);
      for (var i = 1; i <= 4; i++) {
        expect(answerAt(i), findsOneWidget);
      }
    });

    testWidgets('зөв хариулахад сонголтууд алга болж, Дараагийн үг гарна',
        (tester) async {
      final state = await open(tester, 'Тааварлах');
      final q = state.q!;
      final rightAt = q.opts.indexWhere((o) => identical(o, q.right));

      await tapVisible(tester, answerAt(rightAt + 1));

      for (var i = 1; i <= 4; i++) {
        expect(answerAt(i), findsNothing, reason: 'зөв бол сонголт үлдэхгүй');
      }
      expect(find.text('Зөв'), findsOneWidget);
      expect(find.text('Дараагийн үг'), findsOneWidget);
      expect(state.score, 10);
    });

    testWidgets('буруу хариулахад сонголтууд үлдэж, зөвийг нь тодруулна',
        (tester) async {
      final state = await open(tester, 'Тааварлах');
      final q = state.q!;
      final wrongAt = q.opts.indexWhere((o) => !identical(o, q.right));

      await tapVisible(tester, answerAt(wrongAt + 1));

      for (var i = 1; i <= 4; i++) {
        expect(answerAt(i), findsOneWidget,
            reason: 'буруу бол аль нь зөв байсныг харуулна');
      }
      expect(find.text('Буруу'), findsOneWidget);
      expect(state.score, 0);
    });

    testWidgets('«Дараагийн үг» дарахад шинэ асуулт ирнэ', (tester) async {
      final state = await open(tester, 'Тааварлах');
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
      final state = await open(tester, 'Тааварлах');
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

    testWidgets('дуудлага ороогүй үгэд мэдэгдэл гарна', (tester) async {
      await open(tester, 'Тааварлах');
      expect(find.text('Дуудлага ороогүй'), findsOneWidget);
      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    });

    testWidgets('4-өөс цөөн үгтэй бол тоглох боломжгүйг заана', (tester) async {
      await pumpHome(tester, store: FakeStore(sampleWords().take(3).toList()));
      await tapVisible(tester, find.text('Тааварлах'));

      expect(find.textContaining('дор хаяж 4 үг'), findsOneWidget);
    });
  });

  group('Үг нэмэх', () {
    testWidgets('үг нэмэхэд сан өснө', (tester) async {
      final state = await open(tester, 'Үг нэмэх, засах');
      expect(find.text('ҮГИЙН САН · 14'), findsOneWidget);

      await typeInto(tester, 0, 'тэст');
      await typeInto(tester, 1, 'test');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Үг нэмэх'));

      expect(state.words, hasLength(15));
      expect(find.text('ҮГИЙН САН · 15'), findsOneWidget);
    });

    testWidgets('буриад үг хоосон бол нэмэхгүй', (tester) async {
      final state = await open(tester, 'Үг нэмэх, засах');
      await typeInto(tester, 1, 'зөвхөн монгол');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Үг нэмэх'));

      expect(state.words, hasLength(14));
    });

    testWidgets('Ү Ө Һ товчлуур буриад талбарт үсэг оруулна', (tester) async {
      await open(tester, 'Үг нэмэх, засах');
      await typeInto(tester, 0, 'у');
      await tapVisible(tester, find.widgetWithText(GestureDetector, 'һ').last);

      final field = tester.widget<TextField>(find.byType(TextField).at(0));
      expect(field.controller!.text, 'уһ');
    });

    testWidgets('үсгийн шалгалтын зургаан үсэг харагдана', (tester) async {
      await open(tester, 'Үг нэмэх, засах');
      expect(find.text('Үү Өө Һһ Ээ Ёё'), findsOneWidget);
    });
  });
}
