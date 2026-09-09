/// Conversione e presentazione delle unità di misura (LO-4, LO-7).
///
/// **LO-7: la conversione riguarda la sola presentazione.** I valori sono
/// conservati e trasmessi in un'unica unità interna — chilogrammi per il
/// peso, centimetri per altezza e circonferenze — e passano di qui solo al
/// momento della visualizzazione e dell'inserimento. Nessun dato
/// memorizzato dipende dalla preferenza, sicché il cambio di sistema non
/// comporta perdita di precisione né alterazione del registrato.
///
/// **LO-8: da ciò discende la retroattività.** Il cambio si applica a
/// tutti i dati, storico e grafici compresi, senza che nulla sia
/// riscritto: sono le stesse funzioni a convertire ogni valore, quale ne
/// sia l'epoca.
///
/// LO-5: l'energia resta in chilocalorie in entrambi i sistemi e non
/// compare qui.
library;

import 'package:flutter/widgets.dart';

import 'l10n_context.dart';
import 'unit_system.dart';

/// Fattori esatti, non arrotondati: la conversione di andata e ritorno
/// deve restituire il valore di partenza (LO-7).
const double _poundsPerKilogram = 2.20462262184878;
const double _centimetresPerInch = 2.54;

/// Da chilogrammi all'unità di presentazione.
double weightToDisplay(double kilograms, UnitSystem system) =>
    system == UnitSystem.imperial ? kilograms * _poundsPerKilogram : kilograms;

/// Dall'unità di presentazione a chilogrammi, che è l'unità di
/// conservazione (LO-7).
double weightToStorage(double shown, UnitSystem system) =>
    system == UnitSystem.imperial ? shown / _poundsPerKilogram : shown;

/// Da centimetri all'unità di presentazione.
double lengthToDisplay(double centimetres, UnitSystem system) =>
    system == UnitSystem.imperial ? centimetres / _centimetresPerInch : centimetres;

/// Dall'unità di presentazione a centimetri.
double lengthToStorage(double shown, UnitSystem system) =>
    system == UnitSystem.imperial ? shown * _centimetresPerInch : shown;

/// Simbolo dell'unità di peso nel sistema scelto (LO-4).
String weightUnit(BuildContext context, UnitSystem system) =>
    system == UnitSystem.imperial ? context.l10n.unitPounds : context.l10n.unitKilograms;

/// Simbolo dell'unità di lunghezza nel sistema scelto (LO-4).
String lengthUnit(BuildContext context, UnitSystem system) =>
    system == UnitSystem.imperial ? context.l10n.unitInches : context.l10n.unitCentimetres;
