import 'package:flutter/widgets.dart';

import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';
import '../data/slot_item.dart';

/// Presentazione della quantità di un elemento (GG-22, GG-24, 4.1
/// interfaccia).
///
/// La quantità è contenuto redatto dall'autore e non è mai convertita: si
/// presenta nell'unità in cui è stata scritta, quale che sia il sistema di
/// unità scelto dall'Utente (LO-3). Il sistema di LO-4 riguarda le sole
/// grandezze corporee e non tocca i piani.
///
/// `null` quando la quantità manca: un alimento può esserne privo — «verdure
/// a volontà» — e la ricetta lo è sempre (GG-12).
String? formatSlotItemQuantity(BuildContext context, num? quantity, String? unitCode) {
  if (quantity == null || unitCode == null) return null;
  final number = formatDecimal(context, quantity.toDouble(), decimals: 2);
  final unit = QuantityUnit.tryFromJson(unitCode);
  // CO-7quater: un'unità aggiunta dopo questa versione del client è resa col
  // proprio codice anziché taciuta — meglio «2 BARATTOLO» di una quantità muta.
  if (unit == null) return '$number $unitCode';
  return '$number ${_unitName(context, unit, quantity)}';
}

String _unitName(BuildContext context, QuantityUnit unit, num quantity) {
  final l10n = context.l10n;
  return switch (unit) {
    QuantityUnit.gram => l10n.unitQuantityGram,
    QuantityUnit.milliliter => l10n.unitQuantityMilliliter,
    QuantityUnit.piece => l10n.unitQuantityPiece(quantity),
    QuantityUnit.slice => l10n.unitQuantitySlice(quantity),
    QuantityUnit.tablespoon => l10n.unitQuantityTablespoon(quantity),
    QuantityUnit.teaspoon => l10n.unitQuantityTeaspoon(quantity),
    QuantityUnit.portion => l10n.unitQuantityPortion(quantity),
    QuantityUnit.cup => l10n.unitQuantityCup(quantity),
    QuantityUnit.glass => l10n.unitQuantityGlass(quantity),
    QuantityUnit.jar => l10n.unitQuantityJar(quantity),
    QuantityUnit.can => l10n.unitQuantityCan(quantity),
    QuantityUnit.smallCup => l10n.unitQuantitySmallCup(quantity),
    QuantityUnit.handful => l10n.unitQuantityHandful(quantity),
  };
}

/// Denominazione e quantità su una riga sola, per i contesti che non possono
/// comporle in due stili — l'esportazione, l'anteprima compatta.
String slotItemLabel(BuildContext context, String name, num? quantity, String? unitCode) {
  final formatted = formatSlotItemQuantity(context, quantity, unitCode);
  return formatted == null ? name : '$name  $formatted';
}
