import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Livello semantico del colore (FE-16, FE-17): il significato d'uso, non il
/// valore grezzo. I widget leggono sempre da qui, mai da [AppPalette].
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.dividerLight,
    required this.dividerStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentPressed,
    required this.accentSubtle,
    required this.error,
    required this.errorBackground,
    required this.warning,
    required this.warningBackground,
    required this.confirm,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color dividerLight;
  final Color dividerStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentPressed;
  final Color accentSubtle;
  final Color error;
  final Color errorBackground;
  final Color warning;
  final Color warningBackground;
  final Color confirm;

  static const AppColors light = AppColors(
    background: AppPalette.backgroundLight,
    surface: AppPalette.surfaceLight,
    surfaceAlt: AppPalette.surfaceAltLight,
    dividerLight: AppPalette.dividerLightOnLight,
    dividerStrong: AppPalette.dividerStrongOnLight,
    textPrimary: AppPalette.textPrimaryLight,
    textSecondary: AppPalette.textSecondaryLight,
    textTertiary: AppPalette.textTertiaryLight,
    accent: AppPalette.accentLight,
    accentPressed: AppPalette.accentPressedLight,
    accentSubtle: AppPalette.accentSubtleLight,
    error: AppPalette.errorLight,
    errorBackground: AppPalette.errorBackgroundLight,
    warning: AppPalette.warningLight,
    warningBackground: AppPalette.warningBackgroundLight,
    confirm: AppPalette.confirmLight,
  );

  static const AppColors dark = AppColors(
    background: AppPalette.backgroundDark,
    surface: AppPalette.surfaceDark,
    surfaceAlt: AppPalette.surfaceAltDark,
    dividerLight: AppPalette.dividerLightOnDark,
    dividerStrong: AppPalette.dividerStrongOnDark,
    textPrimary: AppPalette.textPrimaryDark,
    textSecondary: AppPalette.textSecondaryDark,
    textTertiary: AppPalette.textTertiaryDark,
    accent: AppPalette.accentDark,
    accentPressed: AppPalette.accentPressedDark,
    accentSubtle: AppPalette.accentSubtleDark,
    error: AppPalette.errorDark,
    errorBackground: AppPalette.errorBackgroundDark,
    warning: AppPalette.warningDark,
    warningBackground: AppPalette.warningBackgroundDark,
    confirm: AppPalette.confirmDark,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? dividerLight,
    Color? dividerStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentPressed,
    Color? accentSubtle,
    Color? error,
    Color? errorBackground,
    Color? warning,
    Color? warningBackground,
    Color? confirm,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      dividerLight: dividerLight ?? this.dividerLight,
      dividerStrong: dividerStrong ?? this.dividerStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      error: error ?? this.error,
      errorBackground: errorBackground ?? this.errorBackground,
      warning: warning ?? this.warning,
      warningBackground: warningBackground ?? this.warningBackground,
      confirm: confirm ?? this.confirm,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      dividerLight: Color.lerp(dividerLight, other.dividerLight, t)!,
      dividerStrong: Color.lerp(dividerStrong, other.dividerStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBackground: Color.lerp(warningBackground, other.warningBackground, t)!,
      confirm: Color.lerp(confirm, other.confirm, t)!,
    );
  }
}
