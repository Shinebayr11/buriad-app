import 'package:flutter/material.dart';

import 'data/shared_preferences_word_store.dart';
import 'data/word_store.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/word_controller.dart';
import 'theme.dart';

void main() {
  runApp(const BuriadUgApp());
}

class BuriadUgApp extends StatefulWidget {
  const BuriadUgApp({
    super.key,
    this.store,
    this.adminMode = const bool.fromEnvironment('ADMIN_MODE'),
  });

  final WordStore? store;
  final bool adminMode;

  @override
  State<BuriadUgApp> createState() => _BuriadUgAppState();
}

class _BuriadUgAppState extends State<BuriadUgApp> {
  late final WordController _controller;
  final _navigatorKey = GlobalKey<NavigatorState>();

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

  void _continueWithoutAccount() {
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(
          controller: _controller,
          canManageWords: widget.adminMode,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Буриад үг',
      theme: AppTheme.dark,
      home: WelcomeScreen(onContinue: _continueWithoutAccount),
    );
  }
}
