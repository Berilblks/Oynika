import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';

abstract final class AppTheme {
  static const primary = Color(0xFF7255E8);
  static const secondary = Color(0xFFFF725E);
  static const background = Color(0xFFF8F7FC);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: brightness == Brightness.light ? primary : null,
      secondary: brightness == Brightness.light ? secondary : null,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: colors);
    return base.copyWith(
      scaffoldBackgroundColor:
          brightness == Brightness.light ? background : colors.surface,
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cornerRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.itemSpacing,
        ),
      ),
    );
  }
}
