import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'auth/auth_gateway.dart';
import 'auth/supabase_auth_gateway.dart';
import 'auth/supabase_config.dart';
import 'auth/unavailable_auth_gateway.dart';
import 'data/shared_preferences_word_store.dart';
import 'data/word_store.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/word_controller.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const config = SupabaseConfig.fromEnvironment();
  AuthGateway authGateway = const UnavailableAuthGateway();
  if (config.isConfigured) {
    await Supabase.initialize(
      url: config.url,
      publishableKey: config.publishableKey,
    );
    authGateway = SupabaseAuthGateway(Supabase.instance.client);
  }
  runApp(BuriadUgApp(authGateway: authGateway));
}

class BuriadUgApp extends StatefulWidget {
  const BuriadUgApp({
    super.key,
    this.store,
    this.authGateway = const UnavailableAuthGateway(),
  });

  final WordStore? store;
  final AuthGateway authGateway;

  @override
  State<BuriadUgApp> createState() => _BuriadUgAppState();
}

class _BuriadUgAppState extends State<BuriadUgApp> {
  late final WordController _wordController;
  late AuthUser? _currentUser;
  late bool _showingHome;
  StreamSubscription<AuthUser?>? _authSubscription;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _wordController = WordController(
      widget.store ?? SharedPreferencesWordStore(),
    );
    _wordController.load();
    _currentUser = widget.authGateway.currentUser;
    _showingHome = _currentUser != null;
    _authSubscription = widget.authGateway.authStateChanges.listen((user) {
      if (user != null) {
        _showHome(user);
      } else if (_currentUser != null) {
        _showWelcome();
      }
    }, onError: (_, _) {});
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _wordController.dispose();
    super.dispose();
  }

  void _showHome(AuthUser? user) {
    if (_showingHome && _currentUser == user) return;
    _currentUser = user;
    _showingHome = true;
    _replaceAll(_homeScreen(user));
  }

  void _showWelcome() {
    if (!_showingHome && _currentUser == null) return;
    _currentUser = null;
    _showingHome = false;
    _replaceAll(_welcomeScreen());
  }

  void _replaceAll(Widget screen) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _replaceAll(screen));
      return;
    }
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => screen),
      (_) => false,
    );
  }

  Future<void> _signOut() async {
    try {
      await widget.authGateway.signOut();
      if (!mounted) return;
      _showWelcome();
    } catch (error) {
      if (!mounted) return;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(authFailureMessage(error))),
      );
    }
  }

  Widget _homeScreen(AuthUser? user) => HomeScreen(
    controller: _wordController,
    user: user,
    onSignOut: _signOut,
    onSignIn: _showWelcome,
  );

  Widget _welcomeScreen() => WelcomeScreen(
    authGateway: widget.authGateway,
    onAuthenticated: _showHome,
    onContinueAsGuest: () => _showHome(null),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Буриад үг',
      theme: AppTheme.dark,
      home: _currentUser == null ? _welcomeScreen() : _homeScreen(_currentUser),
    );
  }
}
