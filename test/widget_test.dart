import 'package:buriad_ug/main.dart';
import 'package:buriad_ug/auth/auth_gateway.dart';
import 'package:buriad_ug/data/story_repository.dart';
import 'package:buriad_ug/models/story.dart';
import 'package:buriad_ug/screens/story_list_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_auth_gateway.dart';
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
    final auth = FakeAuthGateway(
      initialUser: const AuthUser(
        id: 'ТУРШИЛТ-1',
        email: 'turshilt@example.com',
        isAdmin: true,
      ),
    );
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      BuriadUgApp(store: FakeWordStore(), authGateway: auth),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Үгийн сангийн удирдлага'));
    await tester.pumpAndSettle();

    expect(find.text('Үгийн сан хоосон байна'), findsOneWidget);
    expect(find.text('Үг нэмэх'), findsWidgets);
  });

  testWidgets('Ү Ө Һ үсгийг курсорын байрлалд оруулна', (tester) async {
    final auth = FakeAuthGateway(
      initialUser: const AuthUser(
        id: 'ТУРШИЛТ-1',
        email: 'turshilt@example.com',
        isAdmin: true,
      ),
    );
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      BuriadUgApp(store: FakeWordStore(), authGateway: auth),
    );
    await tester.pumpAndSettle();
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

  testWidgets('зөв мэдээллээр нэвтрээд бүртгэлийн цэс харуулна', (
    tester,
  ) async {
    final auth = FakeAuthGateway();
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      BuriadUgApp(store: FakeWordStore(), authGateway: auth),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Нэвтрэх'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'И-мэйл'),
      'turshilt@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Нууц үг'),
      'ТУРШИЛТ-123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Нэвтрэх'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Бүртгэл'), findsOneWidget);
    expect(find.text('Тоглоом'), findsOneWidget);
  });

  testWidgets('баталгаажуулах и-мэйлийг дахин илгээнэ', (tester) async {
    final auth = FakeAuthGateway(confirmationRequired: true);
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      BuriadUgApp(store: FakeWordStore(), authGateway: auth),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Бүртгүүлэх'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'И-мэйл'),
      'turshilt@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Нууц үг'),
      'ТУРШИЛТ-123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Бүртгүүлэх'));
    await tester.pumpAndSettle();

    final resendButton = find.text('Баталгаажуулах и-мэйлийг дахин илгээх');
    expect(resendButton, findsOneWidget);
    await tester.tap(resendButton);
    await tester.pump(const Duration(seconds: 1));

    expect(auth.lastResendEmail, 'turshilt@example.com');
    expect(
      find.text('Баталгаажуулах и-мэйлийг дахин илгээлээ.'),
      findsOneWidget,
    );
  });

  testWidgets('хоосон үлгэрийн төлөв харагдана', (tester) async {
    await tester.pumpWidget(BuriadUgApp(store: FakeWordStore()));
    await tester.pumpAndSettle();
    await openHome(tester);
    await tester.tap(find.text('Үлгэр'));
    await tester.pumpAndSettle();

    expect(find.text('Нийтлэх бичлэг алга'), findsOneWidget);
  });

  testWidgets('дууны ангилал гурван бичлэгтэй', (tester) async {
    final story = Story.fromJson({
      'id': 'ТУРШИЛТ-1',
      'title': {'b': 'ТУРШИЛТ-1', 'm': 'туршилт 1'},
      'genre': 'дуу',
      'audio': {
        'app': '',
        'master': '',
        'duration': 0,
        'recordedAt': '',
        'recordedIn': '',
        'recordedBy': '',
        'equipment': '',
      },
      'narrator': {
        'name': '',
        'birthYear': null,
        'birthplace': '',
        'dialect': 'тэмдэглээгүй',
      },
      'rights': {
        'consentOn': '',
        'consentForm': '',
        'publicInApp': true,
        'openToResearchers': false,
        'aiTrainingAllowed': false,
        'nameCredited': true,
        'withdrawableBy': '',
        'license': '',
        'tkLabels': <String>[],
      },
      'transcript': {'by': '', 'date': '', 'verifiedBy': ''},
      'segments': <Object>[],
      'notes': '',
      'performer': 'ТУРШИЛТ-1',
      'sourceUrl': 'https://toonto.mn/',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: StoryListScreen(
          genre: 'дуу',
          repository: _FakeStoryRepository(List.filled(3, story)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ListTile), findsNWidgets(3));
    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Аудио хүлээгдэж байна'), findsOneWidget);
    expect(find.text('Toonto.mn эх сурвалжийг нээх'), findsOneWidget);
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

class _FakeStoryRepository extends StoryRepository {
  _FakeStoryRepository(this.stories);

  final List<Story> stories;

  @override
  Future<List<Story>> loadPublicStories() => SynchronousFuture(stories);
}
