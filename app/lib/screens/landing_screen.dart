import 'package:flutter/material.dart';

import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/buriad_ornaments.dart';
import '../widgets/word_picture.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

/// Угтах хуудас.
///
/// Бүтэц нь буриад хувцасны дарааллыг дагана:
///   толгой  — тоорцог малгай
///   бие     — деэлийн энгэр
///   хөл     — гутлын хээ
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key, required this.state});

  final GameState state;

  void _go(BuildContext context, Widget page, {bool replace = false}) {
    final route = MaterialPageRoute<void>(builder: (_) => page);
    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.2),
            radius: .9,
            colors: [BuriadColors.tengerSoft, BuriadColors.tengerDeep],
            stops: [0, .6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── толгой: тоорцог ──
              const Padding(
                padding: EdgeInsets.only(top: 18, bottom: 10),
                child: ToortsogCrest(size: 72),
              ),

              // ── бие: энгэр ──
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: ConstrainedBox(
                      // Зай хүрэлцвэл агуулга босоо төвд суух; багадвал гүйлгэнэ.
                      constraints: BoxConstraints(minHeight: c.maxHeight - 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Буриад үг',
                            textAlign: TextAlign.center,
                            style: display(
                              size: 34,
                              weight: FontWeight.w800,
                              spacing: -.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ХЭЛ · АМАН ЗОХИОЛ · ӨВ',
                            textAlign: TextAlign.center,
                            style: label(size: 11).copyWith(letterSpacing: 1.4),
                          ),
                          const SizedBox(height: 28),
                          EngerEdge(
                            child: Text(
                              'Буриад хэл, аман зохиол, биет бус өвийг хадгалж '
                              'хойч үедээ үлдээх зорилготой апп. Амин Тоонто '
                              'ТББ-тай хамтран хөгжүүлж байна.',
                              style: body(
                                size: 15,
                                color: BuriadColors.sutDim,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _Action(
                            label: 'Нэвтрэх',
                            primary: true,
                            onTap: () => _go(
                              context,
                              AuthScreen(state: state, signUp: false),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _Action(
                            label: 'Бүртгүүлэх',
                            onTap: () => _go(
                              context,
                              AuthScreen(state: state, signUp: true),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Semantics(
                              button: true,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _go(
                                  context,
                                  HomeScreen(state: state),
                                  replace: true,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Бүртгэлгүйгээр үзэх',
                                    style: body(
                                      size: 14,
                                      weight: FontWeight.w600,
                                      color: BuriadColors.khadag,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── хөл: гутлын хээ ──
              const GutalBorder(height: 28),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                child: Text(
                  'Үг, бичлэг бүр эх сурвалж, зөвшөөрөлтэйгээр орно.',
                  textAlign: TextAlign.center,
                  style: body(size: 11.5, color: BuriadColors.sutDim),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Угтах хуудасны товч.
class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return primary
        ? MainButton(text: label, onTap: onTap)
        : SizedBox(
            width: double.infinity,
            child: GhostButton(text: label, onTap: onTap),
          );
  }
}
