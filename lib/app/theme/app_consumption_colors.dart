import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Voci semantiche per gli stati di consumo di uno slot (FE-19, SP-1):
/// il significato è del dominio, la resa è del tema. Distinta da [AppColors]
/// anche dove i valori coincidono con quelli di errore/conferma (2.2), perché
/// dice cosa diversa e potrebbe divergerne in seguito.
///
/// "Da consumare" è la condizione ordinaria e non ha colore proprio (2.2):
/// [toConsume] è `null`, e i widget vi si riferiscono coi neutri di
/// [AppColors].
class AppConsumptionColors extends ThemeExtension<AppConsumptionColors> {
  const AppConsumptionColors({
    required this.toConsume,
    required this.consumed,
    required this.skipped,
    required this.consumedBackground,
    required this.skippedBackground,
  });

  final Color? toConsume;
  final Color consumed;
  final Color skipped;

  /// Fondo tenue del pulsante di spunta quando il proprio stato è quello
  /// corrente (4.1 interfaccia.md). Nessuna voce per [toConsume]: quello
  /// stato non ha un pulsante proprio (SP-1, due soli pulsanti).
  final Color consumedBackground;
  final Color skippedBackground;

  static const AppConsumptionColors light = AppConsumptionColors(
    toConsume: null,
    consumed: AppPalette.mealConsumedLight,
    skipped: AppPalette.mealSkippedLight,
    consumedBackground: AppPalette.mealConsumedBackgroundLight,
    skippedBackground: AppPalette.mealSkippedBackgroundLight,
  );

  static const AppConsumptionColors dark = AppConsumptionColors(
    toConsume: null,
    consumed: AppPalette.mealConsumedDark,
    skipped: AppPalette.mealSkippedDark,
    consumedBackground: AppPalette.mealConsumedBackgroundDark,
    skippedBackground: AppPalette.mealSkippedBackgroundDark,
  );

  @override
  AppConsumptionColors copyWith({
    Color? toConsume,
    Color? consumed,
    Color? skipped,
    Color? consumedBackground,
    Color? skippedBackground,
  }) {
    return AppConsumptionColors(
      toConsume: toConsume ?? this.toConsume,
      consumed: consumed ?? this.consumed,
      skipped: skipped ?? this.skipped,
      consumedBackground: consumedBackground ?? this.consumedBackground,
      skippedBackground: skippedBackground ?? this.skippedBackground,
    );
  }

  @override
  AppConsumptionColors lerp(ThemeExtension<AppConsumptionColors>? other, double t) {
    if (other is! AppConsumptionColors) return this;
    return AppConsumptionColors(
      toConsume: Color.lerp(toConsume, other.toConsume, t),
      consumed: Color.lerp(consumed, other.consumed, t)!,
      skipped: Color.lerp(skipped, other.skipped, t)!,
      consumedBackground: Color.lerp(consumedBackground, other.consumedBackground, t)!,
      skippedBackground: Color.lerp(skippedBackground, other.skippedBackground, t)!,
    );
  }
}
