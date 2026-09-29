import 'package:flutter/material.dart';

import '../theme.dart';

/// Нүүр дэлгэцийн нэг хэсэг — жижиг гарчиг ба доор нь картууд.
class HomeSection extends StatelessWidget {
  const HomeSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 9),
          child: Text(title.toUpperCase(), style: label()),
        ),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Нүүр дэлгэцийн товшигдох карт.
class HomeCard extends StatelessWidget {
  const HomeCard({
    super.key,
    required this.title,
    required this.meta,
    required this.onTap,
    this.hint,
    this.accent = false,
    this.dim = false,
  });

  final String title;

  /// Баруун доор гарах тоо эсвэл товч тэмдэглэл.
  final String meta;

  /// Гарчгийн доорх тайлбар — заавал биш.
  final String? hint;

  /// Шар өргөлттэй эсэх (тоглоомын картад).
  final bool accent;

  /// Агуулга хоосон үед бүдгэрүүлнэ.
  final bool dim;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = dim ? BuriadColors.sutDim : BuriadColors.sut;
    return Semantics(
      button: true,
      label: '$title, $meta',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          decoration: BoxDecoration(
            color: accent
                ? BuriadColors.shar.withValues(alpha: .1)
                : BuriadColors.khadag.withValues(alpha: .06),
            border: Border.all(
              color: accent
                  ? BuriadColors.shar.withValues(alpha: .45)
                  : BuriadColors.line,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: display(
                  size: 16,
                  weight: FontWeight.w600,
                  color: accent ? BuriadColors.shar : fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hint != null) ...[
                const SizedBox(height: 4),
                Text(
                  hint!,
                  style: body(
                    size: 12,
                    color: BuriadColors.sutDim,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Text(meta, style: label(size: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Дэд дэлгэцийн толгой — буцах товч, гарчиг, баруун талын нэмэлт.
class SubPageHeader extends StatelessWidget {
  const SubPageHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Буцах',
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(right: 10, top: 4, bottom: 4),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: BuriadColors.khadag,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: display(size: 17, weight: FontWeight.w700, spacing: -.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Дэд дэлгэцийн ерөнхий хүрээ — нүүртэй ижил дэвсгэр.
class SubPage extends StatelessWidget {
  const SubPage({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SubPageHeader(title: title, trailing: trailing),
                const SizedBox(height: 16),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
