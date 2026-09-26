import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/slot_type.dart';
import '../editable_slot.dart';
import 'slot_items_editor.dart';
import '../slot_type_presentation.dart';

/// Card espandibile di uno slot (7.3 interfaccia.md). Chiusa: icona,
/// etichetta, contenuto troncato, maniglia di riordino. Aperta: i campi
/// di redazione (CD-8, GG-14, GG-15, AD-5), la copia in altri slot
/// (CD-8bis) e la rimozione.
class SlotCard extends StatefulWidget {
  const SlotCard({
    super.key,
    required this.slot,
    required this.index,
    required this.onChanged,
    required this.onRemove,
    this.onCopy,
    this.showAdherenceWeight = true,
  });

  final EditableSlot slot;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  /// CD-8bis: "Copia in…". `null` quando non vi sono slot di destinazione
  /// ammessi, e l'azione non compare (7.3 interfaccia.md).
  final VoidCallback? onCopy;

  /// MD-8: nella modifica della singola occorrenza il peso di aderenza
  /// non è in gioco — resta quello dello slot (o il predefinito per uno
  /// nuovo): il cursore non compare.
  final bool showAdherenceWeight;

  @override
  State<SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends State<SlotCard> {
  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onFieldChanged);
    }
    super.dispose();
  }

  List<TextEditingController> get _controllers => [
        widget.slot.labelController,
        widget.slot.noteController,
      ];

  void _onFieldChanged() {
    setState(() {});
    widget.onChanged();
  }

  void _toggleExpanded() {
    setState(() => widget.slot.expanded = !widget.slot.expanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final slot = widget.slot;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(slot.type.icon, color: colors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.type == SlotType.snack && slot.labelController.text.trim().isNotEmpty
                              ? slot.labelController.text.trim()
                              : slotTypeLabel(context, slot.type),
                          style: typography.bodyLarge.copyWith(color: colors.textPrimary),
                        ),
                        if (!slot.expanded)
                          // 7.3: da chiusa la card dice che cosa contiene, non
                          // in quale quantità — le denominazioni, su una riga.
                          Text(
                            slot.items.isEmpty
                                ? context.l10n.slotNotSpecified
                                : slot.items.map((item) => item.nameController.text.trim()).join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.caption.copyWith(color: colors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: widget.index,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      child: Icon(Icons.drag_handle, color: colors.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (slot.expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: AppSpacing.md),
                  if (slot.type == SlotType.snack) ...[
                    AppTextField(label: context.l10n.slotDescriptiveLabel, controller: slot.labelController),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  SlotItemsEditor(items: slot.items, onChanged: _onFieldChanged),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(label: context.l10n.slotAccessoryNote, controller: slot.noteController, minLines: 2, maxLines: 3),
                  if (widget.showAdherenceWeight) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(context.l10n.slotAdherenceWeight(slot.adherenceWeight.toStringAsFixed(1)),
                      style: typography.bodyMedium.copyWith(color: colors.textPrimary)),
                  Slider(
                    value: slot.adherenceWeight,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    activeColor: colors.accent,
                    label: slot.adherenceWeight.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() => slot.adherenceWeight = value);
                      widget.onChanged();
                    },
                  ),
                  Text(
                    context.l10n.slotAdherenceWeightHelp,
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppSpacing.xs,
                    children: [
                      if (widget.onCopy != null)
                        TextButton.icon(
                          onPressed: widget.onCopy,
                          icon: Icon(Icons.content_copy, color: colors.accent),
                          label: Text(context.l10n.slotCopyAction, style: typography.label.copyWith(color: colors.accent)),
                        ),
                      TextButton.icon(
                        onPressed: widget.onRemove,
                        icon: Icon(Icons.delete_outline, color: colors.error),
                        label: Text(context.l10n.commonRemove, style: typography.label.copyWith(color: colors.error)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
