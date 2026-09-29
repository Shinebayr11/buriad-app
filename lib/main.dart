import 'package:flutter/material.dart';

import 'theme.dart';

void main() {
  runApp(const BuriadUgApp());
}

class BuriadUgApp extends StatelessWidget {
  const BuriadUgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Буриад үг',
      theme: AppTheme.dark,
      home: const _InitialScreen(),
    );
  }
}

class _InitialScreen extends StatelessWidget {
  const _InitialScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: Text('Буриад үг'))),
    );
  }
}
