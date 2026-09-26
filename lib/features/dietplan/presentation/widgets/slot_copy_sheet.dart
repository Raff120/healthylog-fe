import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/slot_type.dart';
import '../editable_slot.dart';
import '../editable_weeks.dart';
import '../slot_type_presentation.dart';
import '../weekday_presentation.dart';

/// Un gruppo di slot di destinazione nel foglio della copia: i soli slot
/// ammessi di un giorno, sotto il suo nome. [title] `null` nella modifica
/// della singola giornata, dove il giorno è uno solo.
class SlotCopyGroup {
  const SlotCopyGroup({this.title, required this.slots});

  final String? title;
  final List<EditableSlot> slots;
}

/// CD-8bis, 7.3 interfaccia.md: le destinazioni offerte dalla redazione
/// dello schema del piano e del template — ogni altro slot di ogni giorno,
/// di ogni settimana —, sotto il nome del giorno e, quando le settimane sono
/// più d'una, della settimana.
List<SlotCopyGroup> scheduleCopyGroups(BuildContext context, List<EditableDay> days, EditableSlot source) {
  final manyWeeks = days.weekCount > 1;
  return [
    for (final (day, slots) in days.copyTargetsFor(source))
      SlotCopyGroup(
        title: manyWeeks
            ? context.l10n.scheduleWeekDay(day.week, weekdayLabel(context, day.dayOfWeek))
            : weekdayLabel(context, day.dayOfWeek),
        slots: slots,
      ),
  ];
}

/// CD-8bis, 7.3 interfaccia.md: copia il contenuto di [source] negli slot
/// che si scelgono fra [groups], previa conferma semplice (4.5) se qualcuno
/// dei prescelti ha già elementi. Comune alla redazione del piano, del
/// template e della singola giornata, che la differenziano solo nelle
/// destinazioni offerte e nel peso ([includeAdherenceWeight], MD-8).
///
/// Restituisce `true` se la copia è avvenuta: la redazione ne prende atto
/// segnando le modifiche non salvate (CD-10, CD-11).
Future<bool> copySlotContent(
  BuildContext context, {
  required EditableSlot source,
  required List<SlotCopyGroup> groups,
  bool includeAdherenceWeight = true,
}) async {
  final targets = await showModalBottomSheet<List<EditableSlot>>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _SlotCopySheet(source: source, groups: groups),
  );
  if (targets == null || targets.isEmpty || !context.mounted) return false;

  final replaced = targets.where((slot) => !slot.isEmpty).length;
  if (replaced > 0) {
    final confirmed = await _confirmReplace(context, replaced);
    if (confirmed != true || !context.mounted) return false;
  }

  for (final target in targets) {
    target.replaceContentWith(source, includeAdherenceWeight: includeAdherenceWeight);
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.slotCopyDone(targets.length))));
  return true;
}

/// Il nome con cui lo slot si presenta: l'etichetta dello spuntino, se
/// data (GG-10), altrimenti il tipo.
String _slotTitle(BuildContext context, EditableSlot slot) =>
    slot.type == SlotType.snack && slot.labelController.text.trim().isNotEmpty
    ? slot.labelController.text.trim()
    : slotTypeLabel(context, slot.type);

Future<bool?> _confirmReplace(BuildContext context, int replaced) {
  final colors = context.colors;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.slotCopyReplaceTitle),
      content: Text(context.l10n.slotCopyReplaceBody(replaced)),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.commonCancel)),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.slotCopyReplaceAction),
        ),
      ],
    ),
  );
}

class _SlotCopySheet extends StatefulWidget {
  const _SlotCopySheet({required this.source, required this.groups});

  final EditableSlot source;
  final List<SlotCopyGroup> groups;

  @override
  State<_SlotCopySheet> createState() => _SlotCopySheetState();
}

class _SlotCopySheetState extends State<_SlotCopySheet> {
  final Set<EditableSlot> _selected = {};

  void _toggle(EditableSlot slot) {
    setState(() => _selected.contains(slot) ? _selected.remove(slot) : _selected.add(slot));
  }

  /// Nell'ordine in cui il foglio li presenta, non in quello della scelta.
  List<EditableSlot> get _orderedSelection => [
    for (final group in widget.groups)
      for (final slot in group.slots)
        if (_selected.contains(slot)) slot,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                context.l10n.slotCopySheetTitle(_slotTitle(context, widget.source)),
                style: typography.titleMedium.copyWith(color: colors.textPrimary),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final group in widget.groups) ...[
                    if (group.title != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxs),
                        child: Text(group.title!, style: typography.label.copyWith(color: colors.textSecondary)),
                      ),
                    for (final slot in group.slots)
                      CheckboxListTile(
                        value: _selected.contains(slot),
                        onChanged: (_) => _toggle(slot),
                        activeColor: colors.accent,
                        secondary: Icon(slot.type.icon, color: colors.textSecondary),
                        title: Text(
                          _slotTitle(context, slot),
                          style: typography.bodyLarge.copyWith(color: colors.textPrimary),
                        ),
                        subtitle: Text(
                          slot.items.isEmpty
                              ? context.l10n.slotNotSpecified
                              : slot.items.map((item) => item.nameController.text.trim()).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.caption.copyWith(color: colors.textSecondary),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppPrimaryButton(
                label: context.l10n.slotCopyConfirm,
                onPressed: _selected.isEmpty ? null : () => Navigator.of(context).pop(_orderedSelection),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
