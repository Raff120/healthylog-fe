import 'package:flutter/widgets.dart';

const String _interFontFamily = 'Inter';

/// Scala tipografica (2.3 interfaccia.md). Otto voci, primitiva del tema
/// (FE-16): dimensione, interlinea, peso e spaziatura, senza colore — nessuna
/// dimensione implica un colore, che è scelto al livello semantico.
class AppTypeScale {
  const AppTypeScale._();

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
  );
}
