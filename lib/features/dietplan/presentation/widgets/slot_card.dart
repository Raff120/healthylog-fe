import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/slot_type.dart';
import '../editable_slot.dart';
import '../slot_type_presentation.dart';

/// Card espandibile di uno slot (7.3 interfaccia.md). Chiusa: icona,
/// etichetta, contenuto troncato, maniglia di riordino. Aperta: i campi
/// di redazione (CD-8, GG-14, GG-15, AD-5) e la rimozione.
class SlotCard extends StatefulWidget {
  const SlotCard({
    super.key,
    required this.slot,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  final EditableSlot slot;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

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
        widget.slot.contentController,
        widget.slot.noteController,
        widget.slot.recipeNameController,
        widget.slot.recipeTextController,
      ];

  void _onFieldChanged() {
    if (widget.slot.recipeNameController.text.trim().isNotEmpty) {
      widget.slot.recipeNameError = null;
    }
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
                              : slot.type.displayName,
                          style: typography.bodyLarge.copyWith(color: colors.textPrimary),
                        ),
                        if (!slot.expanded)
                          Text(
                            slot.contentController.text.trim().isEmpty
                                ? 'Non specificato'
                                : slot.contentController.text.trim(),
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
                    AppTextField(label: 'Etichetta descrittiva', controller: slot.labelController),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppTextField(
                    label: 'Contenuto',
                    controller: slot.contentController,
                    minLines: 2,
                    maxLines: 5,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(label: 'Denominazione della ricetta', controller: slot.recipeNameController),
                  if (slot.recipeNameError != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(slot.recipeNameError!, style: typography.caption.copyWith(color: colors.error)),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Testo della ricetta',
                    controller: slot.recipeTextController,
                    minLines: 2,
                    maxLines: 6,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(label: 'Nota accessoria', controller: slot.noteController, minLines: 2, maxLines: 3),
                  const SizedBox(height: AppSpacing.md),
                  Text('Peso di aderenza: ${slot.adherenceWeight.toStringAsFixed(1)}',
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
                    'Quanto questo pasto incide sull\'aderenza. A zero non viene conteggiato.',
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: widget.onRemove,
                      icon: Icon(Icons.delete_outline, color: colors.error),
                      label: Text('Rimuovi', style: typography.label.copyWith(color: colors.error)),
                    ),
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
