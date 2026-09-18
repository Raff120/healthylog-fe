import 'package:flutter/widgets.dart';

import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';
import '../../../l10n/unit_system.dart';
import '../domain/water_amounts.dart';

/// Presentazione dei volumi (LO-4, LO-9, LO-10).
///
/// LO-7: i valori arrivano in millilitri, unità di conservazione, e sono
/// convertiti qui — al solo momento della visualizzazione.

/// Il volume nell'unità del sistema scelto.
///
/// Nel sistema metrico il litro subentra al millilitro dal migliaio in su:
/// «1,5 L» si legge, «1500 ml» si conta. Nell'imperiale l'oncia fluida
/// resta l'unità a ogni misura, non essendovene una maggiore d'uso
/// corrente per l'acqua bevuta.
String formatVolume(BuildContext context, int millilitres, UnitSystem system) {
  if (system == UnitSystem.imperial) {
    final ounces = volumeToDisplay(millilitres, system);
    return '${formatDecimal(context, ounces, decimals: 0)} ${context.l10n.unitFluidOunces}';
  }
  if (millilitres >= 1000) {
    return '${formatDecimal(context, millilitres / 1000)} ${context.l10n.unitLitres}';
  }
  return '${formatInteger(context, millilitres)} ${context.l10n.unitQuantityMilliliter}';
}

/// AQ-6: la denominazione della quantità rapida. Non è il volume: quello
/// l'accompagna, e insieme dicono che cosa si sta aggiungendo.
String waterAmountName(BuildContext context, WaterAmount amount) => switch (amount) {
      WaterAmount.glass => context.l10n.waterAmountGlass,
      WaterAmount.smallBottle => context.l10n.waterAmountSmallBottle,
      WaterAmount.bottle => context.l10n.waterAmountBottle,
    };
