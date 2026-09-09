import 'package:flutter/widgets.dart';

/// Tavolozza dei colori (2.2 interfaccia.md). Valori grezzi, primitiva del
/// tema (FE-16): nessun widget vi accede direttamente (FE-17).
class AppPalette {
  const AppPalette._();

  // Accento.
  static const Color accentLight = Color(0xFF5B8DB8);
  static const Color accentPressedLight = Color(0xFF4A7BA5);
  static const Color accentSubtleLight = Color(0xFFE9F0F6);

  static const Color accentDark = Color(0xFF7FA8CC);
  static const Color accentPressedDark = Color(0xFF93B8D8);
  static const Color accentSubtleDark = Color(0xFF243440);

  // Neutri — tema chiaro.
  static const Color backgroundLight = Color(0xFFFAF9F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFF4F2EF);
  static const Color dividerLightOnLight = Color(0xFFEAE7E2);
  static const Color dividerStrongOnLight = Color(0xFFD6D2CB);
  static const Color textTertiaryLight = Color(0xFF9B958B);
  static const Color textSecondaryLight = Color(0xFF6B665D);
  static const Color textPrimaryLight = Color(0xFF000000);

  // Neutri — tema scuro.
  static const Color backgroundDark = Color(0xFF141312);
  static const Color surfaceDark = Color(0xFF1E1D1B);
  static const Color surfaceAltDark = Color(0xFF282624);
  static const Color dividerLightOnDark = Color(0xFF33302C);
  static const Color dividerStrongOnDark = Color(0xFF454138);
  static const Color textTertiaryDark = Color(0xFF78736B);
  static const Color textSecondaryDark = Color(0xFFA8A29A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  // Stati dei pasti (FE-19). "Da consumare" non ha colore proprio.
  static const Color mealConsumedLight = Color(0xFF2E7D4F);
  static const Color mealConsumedDark = Color(0xFF4FA97A);
  static const Color mealSkippedLight = Color(0xFFC0392B);
  static const Color mealSkippedDark = Color(0xFFE0705F);

  // Fondo tenue del pulsante di spunta attivo (4.1 interfaccia.md, F13).
  static const Color mealConsumedBackgroundLight = Color(0xFFE7F3EC);
  static const Color mealConsumedBackgroundDark = Color(0xFF1E3229);
  static const Color mealSkippedBackgroundLight = Color(0xFFFBEAE8);
  static const Color mealSkippedBackgroundDark = Color(0xFF3A211E);

  // Semantici.
  static const Color errorLight = Color(0xFFC0392B);
  static const Color errorDark = Color(0xFFE0705F);
  static const Color errorBackgroundLight = Color(0xFFFBEAE8);
  static const Color errorBackgroundDark = Color(0xFF3A211E);
  static const Color warningLight = Color(0xFFB5730E);
  static const Color warningDark = Color(0xFFD9A03C);
  static const Color warningBackgroundLight = Color(0xFFFBF2E3);
  static const Color warningBackgroundDark = Color(0xFF3A2E1A);
  static const Color confirmLight = Color(0xFF2E7D4F);
  static const Color confirmDark = Color(0xFF4FA97A);
}
