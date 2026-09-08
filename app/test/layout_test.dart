import 'package:buriad_app/main.dart';
import 'package:buriad_app/models/genre.dart';
import 'package:buriad_app/screens/edit_screen.dart';
import 'package:buriad_app/screens/guess_screen.dart';
import 'package:buriad_app/screens/pairs_screen.dart';
import 'package:buriad_app/screens/story_list_screen.dart';
import 'package:buriad_app/state/game_state.dart';
import 'package:buriad_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_store.dart';

/// Янз бүрийн дэлгэцийн хэмжээнд layout халин гарахгүй байхыг шалгана.
void main() {
  const sizes = <String, Size>{
    'iPhone SE (жижиг утас)': Size(320, 568),
    'iPhone 13 mini': Size(375, 812),
    'iPhone 15 Pro Max': Size(430, 932),
    'Android таблет': Size(800, 1280),
    'маш намхан цонх': Size(400, 300),
  };

  Future<GameState> newState() async {
    final s = GameState(FakeStore(sampleWords()), stories: FakeStoryStore());
    await s.init();
    return s;
  }

  void useSize(WidgetTester tester, Size logical) {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = logical;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  sizes.forEach((name, size) {
    testWidgets('$name дээр нүүр халилтгүй', (tester) async {
      useSize(tester, size);
      final state = await newState();
      await tester.pumpWidget(BuriadApp(state: state));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('ТОГЛООМ'), findsOneWidget);
    });
  });

  testWidgets('дэд дэлгэцүүд бүх хэмжээнд халилтгүй', (tester) async {
    for (final entry in sizes.entries) {
      final state = await newState();
      final pages = <String, Widget>{
        'Тааварлах': GuessScreen(state: state),
        'Хос олох': PairsScreen(state: state),
        'Үг нэмэх': EditScreen(state: state),
        'Үлгэр': StoryListScreen(state: state, genre: Genre.ulger),
      };

      for (final page in pages.entries) {
        useSize(tester, entry.value);
        await tester.pumpWidget(
          MaterialApp(theme: buildTheme(), home: page.value),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.key} — ${entry.key}',
        );
      }
    }
  });
}
