import 'package:flutter/widgets.dart';

/// Tavolozza dei colori (2.2 interfaccia.md). Valori grezzi, primitiva del
/// tema (FE-16): nessun widget vi accede direttamente (FE-17).
class AppPalette {
  const AppPalette._();

  // Accento.
  static const Color accentLight = Color(0xFF5B8DB8);
  static const Color accentPressedLight = Color(0xFF4A7BA5);
  static const Color accentSubtleLight = Color(0xFFE9F0F6);

  /// 2.2, 11.1: accento attenuato — la barra di una giornata in cui
  /// l'obiettivo d'acqua non è stato raggiunto (AQ-23). Sta fra l'accento
  /// e l'accento tenue: quest'ultimo è un fondo, e una barra di quel
  /// valore non si vedrebbe.
  static const Color accentMutedLight = Color(0xFFA9C4DA);

  static const Color accentDark = Color(0xFF7FA8CC);
  static const Color accentPressedDark = Color(0xFF93B8D8);
  static const Color accentSubtleDark = Color(0xFF243440);
  static const Color accentMutedDark = Color(0xFF4A6B85);

  // Superficie della barra di navigazione fluttuante (3.2 interfaccia.md),
  // distinta da quella delle card che le scorrono sotto — nessun neutro
  // chiaro bastava a separarla dal bianco senza farne una fascia grigia
  // (vedi decisioni.md).
  //
  // Nel tema chiaro è l'accento: la barra è l'unico elemento persistente
  // dell'applicazione, e portarne il colore la distingue da tutto ciò che
  // le passa sotto senza aggiungere un neutro alla tavolozza. Nel tema
  // scuro resta un neutro più chiaro del fondo, che è come 2.4 prescrive
  // di separare là dove l'ombra non funziona.
  static const Color surfaceFloatingLight = accentLight;
  static const Color surfaceFloatingDark = Color(0xFF32302C);
  static const Color shadowFloatingLight = Color(0x38000000);
  static const Color shadowFloatingDark = Color(0x00000000);

  /// Velo che separa dal contenuto ciò che vi si apre sopra (2.6): il
  /// ventaglio dell'acqua (6.2) e ogni altra apertura modale. Più denso
  /// nel tema scuro, dove un nero tenue non si distinguerebbe dal fondo.
  static const Color scrimLight = Color(0x66000000);
  static const Color scrimDark = Color(0x99000000);

  // Voci della barra sulla propria superficie: attiva e inattiva. Sul
  // colore d'accento la distinzione è fra il bianco pieno e il bianco
  // attenuato; sul neutro scuro resta quella di 3.2, accento e colore
  // secondario del testo.
  static const Color onSurfaceFloatingLight = Color(0xFFFFFFFF);
  static const Color onSurfaceFloatingMutedLight = Color(0xBCFFFFFF);
  static const Color onSurfaceFloatingDark = accentDark;
  static const Color onSurfaceFloatingMutedDark = textSecondaryDark;

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
