import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primary = Color(0xFF46309B);
  static const secondary = Color(0xFFFF8C85);
  static const background = Color(0xFFFFF9F1);
  static const ink = Color(0xFF17103E);
  static const muted = Color(0xFF655E7F);
  // Explicit axes keep variable-font weights consistent on Android and iOS.
  static const displayWeight = [FontVariation('wght', 900)];
  static const titleWeight = [FontVariation('wght', 800)];
  static const bodyWeight = [FontVariation('wght', 500)];
  static const labelWeight = [FontVariation('wght', 700)];

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: isDark ? const Color(0xFFC7B4FF) : primary,
      secondary: isDark ? const Color(0xFFFFADA6) : secondary,
      surface: isDark ? const Color(0xFF1B172B) : background,
      onSurface: isDark ? const Color(0xFFF7F0FF) : ink,
      onSurfaceVariant: isDark ? const Color(0xFFCAC0DA) : muted,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: colors.surface,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w900,
          fontVariations: displayWeight,
          letterSpacing: -1.2,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          fontVariations: displayWeight,
          letterSpacing: -0.8,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          fontVariations: displayWeight,
          letterSpacing: -0.5,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontVariations: titleWeight,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontVariations: titleWeight,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          height: 1.4,
          fontVariations: bodyWeight,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          height: 1.3,
          fontVariations: bodyWeight,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontVariations: bodyWeight,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontVariations: labelWeight,
        ),
        labelMedium: base.textTheme.labelMedium?.copyWith(
          fontVariations: labelWeight,
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          fontVariations: labelWeight,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
