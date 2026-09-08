import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/word_store.dart';
import 'screens/home_screen.dart';
import 'state/game_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Утасны апп тул зөвхөн босоо байрлал.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness:
          Brightness.dark, // iOS: харанхуй дэвсгэр → цагаан бичиг
      systemNavigationBarColor: BuriadColors.tengerDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final state = GameState(WordStore());
  runApp(BuriadApp(state: state));
  state.init();
}

class BuriadApp extends StatelessWidget {
  const BuriadApp({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Буриад үг',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('mn'),
      supportedLocales: const [Locale('mn'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomeScreen(state: state),
    );
  }
}
