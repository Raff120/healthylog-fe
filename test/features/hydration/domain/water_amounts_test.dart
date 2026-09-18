import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/hydration/domain/water_amounts.dart';
import 'package:healthylog/l10n/unit_system.dart';

/// LO-4bis: le quantità rapide non sono la conversione l'una dell'altra.
/// LO-7: la conversione di andata e ritorno restituisce il valore di
/// partenza, così che il cambio di sistema non alteri il registrato.
void main() {
  group('quantità rapide (AQ-6, LO-4bis)', () {
    test('nel sistema metrico valgono 150, 500 e 1000 millilitri', () {
      expect(WaterAmount.glass.millilitresIn(UnitSystem.metric), 150);
      expect(WaterAmount.smallBottle.millilitresIn(UnitSystem.metric), 500);
      expect(WaterAmount.bottle.millilitresIn(UnitSystem.metric), 1000);
    });

    test('nell\'imperiale sono le taglie d\'uso, non la conversione delle metriche', () {
      // 6, 16 e 32 once fluide: 150 ml convertiti darebbero 5,1 fl oz,
      // che nessuno legge come un bicchiere.
      expect(volumeToDisplay(WaterAmount.glass.millilitresIn(UnitSystem.imperial), UnitSystem.imperial).round(), 6);
      expect(
          volumeToDisplay(WaterAmount.smallBottle.millilitresIn(UnitSystem.imperial), UnitSystem.imperial).round(), 16);
      expect(volumeToDisplay(WaterAmount.bottle.millilitresIn(UnitSystem.imperial), UnitSystem.imperial).round(), 32);
    });
  });

  group('conversione dei volumi (LO-7)', () {
    test('nel sistema metrico il millilitro resta sé stesso', () {
      expect(volumeToDisplay(750, UnitSystem.metric), 750);
      expect(volumeToStorage(750, UnitSystem.metric), 750);
    });

    test('andata e ritorno nell\'imperiale restituiscono il valore di partenza', () {
      const millilitres = 946;
      final shown = volumeToDisplay(millilitres, UnitSystem.imperial);
      expect(volumeToStorage(shown, UnitSystem.imperial), millilitres);
    });
  });
}
