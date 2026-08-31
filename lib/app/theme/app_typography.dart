import 'package:flutter/material.dart';

import 'app_type_scale.dart';

/// Livello semantico della tipografia (FE-16, FE-17). Espone la scala per
/// nome d'uso; i widget vi accedono tramite il tema, mai importando
/// [AppTypeScale] direttamente. Nessuno stile reca colore (2.3): il colore è
/// scelto di volta in volta da [AppColors].
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.displayLarge,
    required this.titleLarge,
    required this.titleMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.label,
    required this.caption,
    required this.overline,
  });

  final TextStyle displayLarge;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle overline;

  static const AppTypography standard = AppTypography(
    displayLarge: AppTypeScale.displayLarge,
    titleLarge: AppTypeScale.titleLarge,
    titleMedium: AppTypeScale.titleMedium,
    bodyLarge: AppTypeScale.bodyLarge,
    bodyMedium: AppTypeScale.bodyMedium,
    label: AppTypeScale.label,
    caption: AppTypeScale.caption,
    overline: AppTypeScale.overline,
  );

  @override
  AppTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? overline,
  }) {
    return AppTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      overline: overline ?? this.overline,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
    );
  }
}
