import 'package:flutter/material.dart';

import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/formats.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/slot_type.dart';
import '../slot_type_presentation.dart';

/// 6.5, 4.5 interfaccia.md: l'inversione di due slot si compie previa
/// conferma semplice, che nomina i due pasti. Rinunciare lascia attiva la
/// selezione, per sceglierne un altro.
Future<bool> confirmMealSwap(
  BuildContext context, {
  required DateTime firstDate,
  required SlotType firstType,
  required DateTime secondDate,
  required SlotType secondType,
}) {
  String slot(DateTime date, SlotType type) =>
      context.l10n.mealSwapConfirmSlot(slotTypeLabel(context, type), formatWeekdayDayAndMonth(context, date));
  return _confirmSwap(
    context,
    title: context.l10n.mealSwapConfirmTitle,
    body: context.l10n.mealSwapConfirmBody(slot(firstDate, firstType), slot(secondDate, secondType)),
  );
}

/// IN-28: la medesima conferma per lo scambio di giornate intere.
Future<bool> confirmDaySwap(BuildContext context, {required DateTime firstDate, required DateTime secondDate}) =>
    _confirmSwap(
      context,
      title: context.l10n.daySwapConfirmTitle,
      body: context.l10n.daySwapConfirmBody(
        formatWeekdayDayAndMonth(context, firstDate),
        formatWeekdayDayAndMonth(context, secondDate),
      ),
    );

Future<bool> _confirmSwap(BuildContext context, {required String title, required String body}) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.swapConfirmAction),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
