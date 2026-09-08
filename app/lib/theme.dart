import 'package:flutter/material.dart';

/// Өнгөнүүд — index.html-ийн CSS хувьсагчтай нэг нэгээр таарна.
abstract final class BuriadColors {
  static const tenger = Color(0xFF143A5E);
  static const tengerDeep = Color(0xFF0B2138);
  static const tengerSoft = Color(0xFF1D4E7A);
  static const khadag = Color(0xFF8FC7DE);
  static const shar = Color(0xFFE4A33C);
  static const sharDeep = Color(0xFFC4842A);
  static const sut = Color(0xFFF4EFE4);
  static const sutDim = Color(0xFFB9C6D2);
  static const uls = Color(0xFFC1443F);
  static const khus = Color(0xFF7E9B7A);
  static const line = Color(0x388FC7DE); // rgba(143,199,222,.22)
  static const night = Color(0xFF080E16);
}

/// Хоёулаа Ү Ө Һ үсгийг бүрэн агуулна (fontTools-оор cmap-ыг нь шалгасан).
/// Эхэндээ гарчигт Unbounded байсан ч тэр фонтод эдгээр үсэг байхгүй тул
/// буриад үг хоёр өөр фонтоор холилдож гардаг байв — Onest-ээр сольсон.
abstract final class Fonts {
  static const display = 'Onest';
  static const body = 'GolosText';
  static const fallback = <String>['GolosText'];
}

TextStyle display({
  double size = 16,
  FontWeight weight = FontWeight.w600,
  Color color = BuriadColors.sut,
  double? spacing,
  double? height,
}) => TextStyle(
  fontFamily: Fonts.display,
  fontFamilyFallback: Fonts.fallback,
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
);

TextStyle body({
  double size = 15,
  FontWeight weight = FontWeight.w400,
  Color color = BuriadColors.sut,
  double? spacing,
  double? height,
}) => TextStyle(
  fontFamily: Fonts.body,
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
);

/// Жижиг, том үсгээр бичсэн шошго — CSS: font-size 11px; letter-spacing .1em.
TextStyle label({Color color = BuriadColors.sutDim, double size = 11}) =>
    body(size: size, weight: FontWeight.w500, color: color, spacing: size * .1);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: BuriadColors.tengerDeep,
    fontFamily: Fonts.body,
    colorScheme: const ColorScheme.dark(
      primary: BuriadColors.shar,
      onPrimary: BuriadColors.tengerDeep,
      secondary: BuriadColors.khadag,
      onSecondary: BuriadColors.tengerDeep,
      surface: BuriadColors.tenger,
      onSurface: BuriadColors.sut,
      error: BuriadColors.uls,
    ),
    splashFactory: NoSplash.splashFactory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: BuriadColors.sut,
      displayColor: BuriadColors.sut,
      fontFamily: Fonts.body,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: BuriadColors.shar,
      selectionColor: Color(0x55E4A33C),
      selectionHandleColor: BuriadColors.shar,
    ),
  );
}
