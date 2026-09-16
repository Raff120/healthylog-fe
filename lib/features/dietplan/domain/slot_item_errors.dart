import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';
import '../presentation/editable_slot.dart';

/// Percorso di un campo di elemento negli errori di validazione (ER-14):
/// `days[2].slots[0].items[1].name` nello schema e nel template,
/// `slots[0].items[1].alternatives[0].unit` nella singola giornata.
final RegExp _itemFieldPattern = RegExp(
  r'^(?:days\[(\d+)\]\.)?slots\[(\d+)\]\.items\[(\d+)\](?:\.alternatives\[(\d+)\])?\.(\w+)$',
);

/// Esito dell'applicazione: se qualche errore è stato riportato, e su quale
/// giorno — che la schermata dello schema deve poi mostrare (7.3).
typedef SlotItemErrorOutcome = ({bool matched, int? dayIndex});

/// 7.3 interfaccia.md: «gli errori di validazione ricevuti dal server (ER-14)
/// sono riportati sul campo esatto, aprendo lo slot e l'elemento che lo
/// contengono». Qui si traducono i percorsi in errori sui campi in redazione.
///
/// [slotAt] restituisce lo slot in redazione dati l'indice del giorno — nullo
/// nella modifica della singola giornata — e quello dello slot, ovvero `null`
/// se il percorso non corrisponde a nulla di presente: una risposta che parli
/// di uno slot che non c'è più non deve far cadere la schermata.
SlotItemErrorOutcome applySlotItemErrors(
  BuildContext context,
  List<dynamic>? fields,
  EditableSlot? Function(int? dayIndex, int slotIndex) slotAt,
) {
  var matched = false;
  int? firstDay;
  for (final entry in fields ?? const []) {
    if (entry is! Map) continue;
    final field = entry['field'] as String?;
    final code = entry['code'] as String? ?? '';
    final match = field == null ? null : _itemFieldPattern.firstMatch(field);
    if (match == null) continue;

    final dayIndex = match.group(1) == null ? null : int.parse(match.group(1)!);
    final slot = slotAt(dayIndex, int.parse(match.group(2)!));
    if (slot == null) continue;
    final itemIndex = int.parse(match.group(3)!);
    if (itemIndex >= slot.items.length) continue;
    final item = slot.items[itemIndex];
    final alternativeIndex = match.group(4) == null ? null : int.parse(match.group(4)!);
    if (alternativeIndex != null && alternativeIndex >= item.alternatives.length) continue;

    final name = match.group(5)!;
    final errors = alternativeIndex == null ? item.errors : item.alternatives[alternativeIndex].errors;
    errors[name] = _message(context, name, code);
    slot.expanded = true;
    item.expanded = true;
    matched = true;
    firstDay ??= dayIndex;
  }
  return (matched: matched, dayIndex: firstDay);
}

String _message(BuildContext context, String field, String code) {
  final l10n = context.l10n;
  return switch ((field, code)) {
    ('name', _) => l10n.editItemNameRequired,
    ('quantity', 'REQUIRED') => l10n.editItemQuantityRequired,
    ('unit', 'REQUIRED') => l10n.editItemUnitRequired,
    ('quantity', _) => l10n.editItemQuantityInvalid,
    _ => l10n.validationInvalidValue,
  };
}
