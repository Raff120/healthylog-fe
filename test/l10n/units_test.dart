import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/l10n/unit_system.dart';
import 'package:healthylog/l10n/units.dart';

/// LO-7: la conversione riguarda la sola presentazione. I valori sono
/// conservati in chilogrammi e centimetri, e il cambio di sistema NON
/// DEVE comportare perdita di precisione né alterazione dei dati
/// registrati.
void main() {
  group('conversione del peso (LO-4, LO-7)', () {
    test('il sistema metrico non converte alcunché', () {
      expect(weightToDisplay(72.4, UnitSystem.metric), 72.4);
      expect(weightToStorage(72.4, UnitSystem.metric), 72.4);
    });

    test('il sistema imperiale converte in libbre', () {
      expect(weightToDisplay(100, UnitSystem.imperial), closeTo(220.462, 0.001));
      expect(weightToStorage(220.462262184878, UnitSystem.imperial), closeTo(100, 1e-9));
    });

    test('il giro di conversione restituisce il valore di partenza', () {
      // LO-7: nessuna perdita di precisione al cambio di sistema.
      for (final kilograms in [0.0, 0.5, 42.0, 63.7, 72.45, 120.9, 250.0]) {
        final shown = weightToDisplay(kilograms, UnitSystem.imperial);
        expect(weightToStorage(shown, UnitSystem.imperial), closeTo(kilograms, 1e-9),
            reason: '$kilograms kg');
      }
    });
  });

  group('conversione delle lunghezze (LO-4, LO-7)', () {
    test('il sistema metrico non converte alcunché', () {
      expect(lengthToDisplay(96.5, UnitSystem.metric), 96.5);
      expect(lengthToStorage(96.5, UnitSystem.metric), 96.5);
    });

    test('il sistema imperiale converte in pollici', () {
      expect(lengthToDisplay(2.54, UnitSystem.imperial), closeTo(1, 1e-12));
      expect(lengthToStorage(1, UnitSystem.imperial), 2.54);
    });

    test('il giro di conversione restituisce il valore di partenza', () {
      for (final centimetres in [0.0, 1.0, 76.0, 96.5, 102.3, 180.0]) {
        final shown = lengthToDisplay(centimetres, UnitSystem.imperial);
        expect(lengthToStorage(shown, UnitSystem.imperial), closeTo(centimetres, 1e-9),
            reason: '$centimetres cm');
      }
    });

    test('l\'altezza in centimetri interi sopravvive al giro col decimale mostrato', () {
      // PR-6: l'altezza è conservata in centimetri interi e presentata in
      // pollici con un decimale. Un decimo di pollice vale 2,54 mm, meno
      // del mezzo centimetro su cui il ritorno arrotonda: il centimetro di
      // partenza si ritrova sempre.
      for (var centimetres = 120; centimetres <= 220; centimetres++) {
        final shownInches = double.parse(
          lengthToDisplay(centimetres.toDouble(), UnitSystem.imperial).toStringAsFixed(1),
        );
        expect(lengthToStorage(shownInches, UnitSystem.imperial).round(), centimetres,
            reason: '$centimetres cm');
      }
    });
  });

  group('sistema predefinito (LO-6)', () {
    test('è quello metrico', () {
      expect(UnitSystem.fallback, UnitSystem.metric);
      expect(UnitSystem.fromJson(null), UnitSystem.metric);
      expect(UnitSystem.fromJson('SCONOSCIUTO'), UnitSystem.metric);
    });

    test('rispecchia i valori del backend', () {
      expect(UnitSystem.fromJson('IMPERIAL'), UnitSystem.imperial);
      expect(UnitSystem.metric.toJson(), 'METRIC');
      expect(UnitSystem.imperial.toJson(), 'IMPERIAL');
    });
  });
}
