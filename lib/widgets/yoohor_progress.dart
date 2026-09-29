import 'package:flutter/material.dart';

import '../theme.dart';

class YoohorProgress extends StatelessWidget {
  const YoohorProgress({super.key, required this.results, this.pulse = false});

  final List<bool?> results;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Давталтын явц',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: pulse ? 1.08 : 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Row(
          children: [
            for (var index = 0; index < results.length; index++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 8,
                  decoration: BoxDecoration(
                    color: switch (results[index]) {
                      true => AppColors.shar,
                      false => AppColors.uls,
                      null => AppColors.line,
                    },
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              if (index != results.length - 1) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}
