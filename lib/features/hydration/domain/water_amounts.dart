/// Quantità e volumi dell'idratazione (AQ-6, LO-4, LO-4bis).
///
/// **LO-7: la conversione riguarda la sola presentazione.** I valori sono
/// conservati e trasmessi in millilitri (CO-17) e passano di qui al solo
/// momento della visualizzazione e dell'inserimento.
library;

import '../../../l10n/unit_system.dart';

/// Fattore esatto, non arrotondato: la conversione di andata e ritorno
/// deve restituire il valore di partenza (LO-7). È l'oncia fluida
/// statunitense.
const double _millilitresPerFluidOunce = 29.5735295625;

/// Da millilitri all'unità di presentazione (LO-4).
double volumeToDisplay(int millilitres, UnitSystem system) =>
    system == UnitSystem.imperial ? millilitres / _millilitresPerFluidOunce : millilitres.toDouble();

/// Dall'unità di presentazione ai millilitri, che sono l'unità di
/// conservazione (LO-7).
int volumeToStorage(double shown, UnitSystem system) =>
    (system == UnitSystem.imperial ? shown * _millilitresPerFluidOunce : shown).round();

/// Una delle tre quantità di aggiunta rapida (AQ-6): un bicchiere, una
/// bottiglietta, una bottiglia.
enum WaterAmount {
  glass,
  smallBottle,
  bottle;

  /// LO-4bis: le quantità **non sono la conversione l'una dell'altra**.
  /// In ciascun sistema corrispondono alle taglie d'uso comune: 150 ml in
  /// once farebbero 5,1 fl oz, che nessuno legge come un bicchiere. La
  /// conversione esatta si applica invece a ogni valore registrato.
  int millilitresIn(UnitSystem system) => switch ((this, system)) {
        (WaterAmount.glass, UnitSystem.metric) => 150,
        (WaterAmount.smallBottle, UnitSystem.metric) => 500,
        (WaterAmount.bottle, UnitSystem.metric) => 1000,
        // 6, 16 e 32 once fluide, riportate ai millilitri che si
        // conservano (CO-17).
        (WaterAmount.glass, UnitSystem.imperial) => 177,
        (WaterAmount.smallBottle, UnitSystem.imperial) => 473,
        (WaterAmount.bottle, UnitSystem.imperial) => 946,
      };
}
