import 'package:flutter/material.dart';

abstract final class AppColors {
  static const tenger = Color(0xFF143A5E);
  static const tengerDeep = Color(0xFF0B2138);
  static const tengerSoft = Color(0xFF1D4E7A);
  static const night = Color(0xFF080E16);
  static const khadag = Color(0xFF8FC7DE);
  static const shar = Color(0xFFE4A33C);
  static const sharDeep = Color(0xFFC4842A);
  static const sut = Color(0xFFF4EFE4);
  static const sutDim = Color(0xFFB9C6D2);
  static const uls = Color(0xFFC1443F);
  static const khus = Color(0xFF7E9B7A);
  static const line = Color(0x388FC7DE);
}

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.shar,
      onPrimary: AppColors.night,
      secondary: AppColors.khadag,
      onSecondary: AppColors.night,
      error: AppColors.uls,
      onError: AppColors.sut,
      surface: AppColors.tengerDeep,
      onSurface: AppColors.sut,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.night,
      fontFamily: 'Golos Text',
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(
            bodyColor: AppColors.sut,
            displayColor: AppColors.sut,
            fontFamily: 'Golos Text',
          )
          .copyWith(
            displayLarge: base.textTheme.displayLarge?.copyWith(
              fontFamily: 'Onest',
              fontWeight: FontWeight.w700,
            ),
            displayMedium: base.textTheme.displayMedium?.copyWith(
              fontFamily: 'Onest',
              fontWeight: FontWeight.w700,
            ),
            headlineLarge: base.textTheme.headlineLarge?.copyWith(
              fontFamily: 'Onest',
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: base.textTheme.headlineMedium?.copyWith(
              fontFamily: 'Onest',
              fontWeight: FontWeight.w700,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              fontFamily: 'Onest',
              fontWeight: FontWeight.w700,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.tengerDeep,
        foregroundColor: AppColors.sut,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.tenger,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.tenger,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.shar, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sut,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.khadag),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
