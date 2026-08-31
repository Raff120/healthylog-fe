import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Costruisce le varianti chiara e scura del tema applicativo (FE-18),
/// entrambe definite sulle medesime primitive (FE-16).
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.surface,
      secondary: colors.accent,
      onSecondary: colors.surface,
      error: colors.error,
      onError: colors.surface,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      dividerColor: colors.dividerLight,
      fontFamily: 'Inter',
      splashFactory: NoSplash.splashFactory,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const _AppPageTransitionsBuilder(),
        },
      ),
      extensions: <ThemeExtension<Object?>>[
        colors,
        AppTypography.standard,
      ],
    );
  }
}

/// Transizione tra schermate breve e funzionale (2.4 interfaccia.md):
/// dissolvenza morbida in 280 ms, senza rimbalzi.
class _AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const _AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: AppSpacing.motionSoftCurve,
      ),
      child: child,
    );
  }
}
