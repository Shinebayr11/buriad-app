import 'package:flutter/material.dart';

import 'data/shared_preferences_word_store.dart';
import 'data/word_store.dart';
import 'screens/game_menu_screen.dart';
import 'state/word_controller.dart';
import 'theme.dart';

void main() {
  runApp(const BuriadUgApp());
}

class BuriadUgApp extends StatefulWidget {
  const BuriadUgApp({super.key, this.store});

  final WordStore? store;

  @override
  State<BuriadUgApp> createState() => _BuriadUgAppState();
}

class _BuriadUgAppState extends State<BuriadUgApp> {
  late final WordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WordController(widget.store ?? SharedPreferencesWordStore());
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Буриад үг',
      theme: AppTheme.dark,
      home: GameMenuScreen(controller: _controller),
    );
  }
}
