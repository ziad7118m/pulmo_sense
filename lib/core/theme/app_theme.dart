import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_colors.dart';

class AppTheme {
  static const _radius = 16.0;

  static ThemeData light() {
    const bg = Color(0xFFF4F9FF);
    const surface = Color(0xFFFFFFFF);
    const surfaceVariant = Color(0xFFE7F1FF);
    const outline = Color(0xFFB8C7E6);
    const outlineVariant = Color(0xFFD6E3FF);

    final scheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      errorContainer: Color(0xFFFFE8E8),
      onErrorContainer: Color(0xFF7A0012),
      background: bg,
      onBackground: AppColors.darkBlue,
      surface: surface,
      onSurface: AppColors.darkBlue,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: Color(0xFF3A4A6B),
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF0B1220),
      onInverseSurface: Color(0xFFEAF1FF),
      inversePrimary: AppColors.secondary,
      primaryContainer: Color(0xFFD6E7FF),
      onPrimaryContainer: AppColors.darkBlue,
      secondaryContainer: Color(0xFFEAF3FF),
      onSecondaryContainer: AppColors.darkBlue,
      tertiary: Color(0xFF0F4FB8),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD0E4FF),
      onTertiaryContainer: AppColors.darkBlue,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      fontFamily: 'PlusJakartaSans',
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF3F8FF),
        surfaceTintColor: const Color(0xFFE0EEFF),
        elevation: 0,
        scrolledUnderElevation: 1,
        foregroundColor: scheme.primary,
        iconTheme: IconThemeData(color: scheme.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  static ThemeData dark() {
    const bg = Color(0xFF071226);
    const surface = Color(0xFF0D1B35);
    const surfaceVariant = Color(0xFF102447);
    const outline = Color(0xFF2A3F66);
    const outlineVariant = Color(0xFF223656);

    final scheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.secondary,
      onPrimary: Color(0xFF061023),
      secondary: Color(0xFF8EC6FF),
      onSecondary: Color(0xFF061023),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      background: bg,
      onBackground: Color(0xFFEAF1FF),
      surface: surface,
      onSurface: Color(0xFFEAF1FF),
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: Color(0xFFB8C7E6),
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: surfaceVariant,
      onInverseSurface: Color(0xFFEAF1FF),
      inversePrimary: AppColors.primary,
      primaryContainer: Color(0xFF0F2A55),
      onPrimaryContainer: Color(0xFFD6E7FF),
      secondaryContainer: Color(0xFF173662),
      onSecondaryContainer: Color(0xFFD6E7FF),
      tertiary: Color(0xFF5DB1FF),
      onTertiary: Color(0xFF041021),
      tertiaryContainer: Color(0xFF09325A),
      onTertiaryContainer: Color(0xFFD0E4FF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      fontFamily: 'PlusJakartaSans',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
