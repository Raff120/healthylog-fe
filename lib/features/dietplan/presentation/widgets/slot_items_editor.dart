import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/slot_item.dart';
import '../../domain/slot_item_format.dart';
import '../editable_slot.dart';

/// Redazione degli elementi di uno slot (7.3 interfaccia.md): elenco
/// riordinabile di righe compatte che si aprono sul posto, ciascuna col
/// genere, la denominazione, la quantità con la sua unità ovvero il testo
/// della ricetta, e le proprie alternative (GG-12, GG-22, GG-25).
///
/// Serve identica allo schema del piano, al template e alla modifica della
/// singola giornata (CD-8, TP-12, MD-8): la redazione è la stessa.
class SlotItemsEditor extends StatefulWidget {
  const SlotItemsEditor({super.key, required this.items, required this.onChanged});

  final List<EditableItem> items;
  final VoidCallback onChanged;

  @override
  State<SlotItemsEditor> createState() => _SlotItemsEditorState();
}

class _SlotItemsEditorState extends State<SlotItemsEditor> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.editItemsTitle,
            style: typography.label.copyWith(color: colors.textSecondary)),
        const SizedBox(height: AppSpacing.xxs),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: widget.items.length,
          onReorderItem: (oldIndex, newIndex) {
            setState(() => widget.items.insert(newIndex, widget.items.removeAt(oldIndex)));
            widget.onChanged();
          },
          itemBuilder: (context, index) => _ItemEditor(
            key: ObjectKey(widget.items[index]),
            item: widget.items[index],
            index: index,
            onChanged: () {
              setState(() {});
              widget.onChanged();
            },
            onRemove: () {
              setState(() => widget.items.removeAt(index).dispose());
              widget.onChanged();
            },
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() => widget.items.add(EditableItem(expanded: true)));
              widget.onChanged();
            },
            icon: Icon(Icons.add, size: 18, color: colors.accent),
            label: Text(context.l10n.editItemAdd,
                style: typography.label.copyWith(color: colors.accent)),
          ),
        ),
      ],
    );
  }
}

class _ItemEditor extends StatelessWidget {
  const _ItemEditor({
    super.key,
    required this.item,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  final EditableItem item;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final quantity = formatSlotItemQuantity(context, item.quantity, item.unitCode);
    final hasErrors = item.errors.isNotEmpty ||
        item.alternatives.any((alternative) => alternative.errors.isNotEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: hasErrors ? Border.all(color: colors.error) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              item.expanded = !item.expanded;
              onChanged();
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_handle, size: 18, color: colors.textTertiary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (item.isRecipe) ...[
                    Icon(Icons.soup_kitchen_outlined, size: 16, color: colors.textSecondary),
                    const SizedBox(width: AppSpacing.xxs),
                  ],
                  Expanded(
                    child: Text(
                      item.nameController.text.trim().isEmpty
                          ? context.l10n.editItemName
                          : item.nameController.text.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodyMedium.copyWith(
                        color: item.nameController.text.trim().isEmpty
                            ? colors.textTertiary
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                  if (quantity != null) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    Text(quantity, style: typography.caption.copyWith(color: colors.textSecondary)),
                  ],
                  if (item.alternatives.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      context.l10n.mealItemAlternativesCount(item.alternatives.length),
                      style: typography.caption.copyWith(color: colors.textTertiary),
                    ),
                  ],
                  Icon(item.expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18, color: colors.textTertiary),
                ],
              ),
            ),
          ),
          if (item.expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KindSelector(
                    kindCode: item.kindCode,
                    onChanged: (kind) {
                      item.kindCode = kind;
                      // GG-12: cambiando genere cadono i campi propri
                      // dell'altro, che il modello non ammette insieme.
                      if (item.isRecipe) {
                        item.quantity = null;
                        item.unitCode = null;
                      } else {
                        item.recipeTextController.clear();
                      }
                      item.errors.clear();
                      onChanged();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField(
                    label: context.l10n.editItemName,
                    controller: item.nameController,
                    errorText: item.errors['name'],
                    onChanged: (_) {
                      if (item.errors.remove('name') != null) onChanged();
                    },
                  ),
                  if (!item.isRecipe) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _QuantityFields(
                      quantity: item.quantity,
                      unitCode: item.unitCode,
                      quantityError: item.errors['quantity'],
                      unitError: item.errors['unit'],
                      onChanged: (quantity, unitCode) {
                        item.quantity = quantity;
                        item.unitCode = unitCode;
                        item.errors.remove('quantity');
                        item.errors.remove('unit');
                        onChanged();
                      },
                    ),
                  ],
                  if (item.isRecipe) ...[
                    const SizedBox(height: AppSpacing.xs),
                    AppTextField(
                      label: context.l10n.slotRecipeText,
                      controller: item.recipeTextController,
                      minLines: 2,
                      maxLines: 6,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  _Alternatives(item: item, onChanged: onChanged),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onRemove,
                      icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                      label: Text(context.l10n.commonRemove,
                          style: typography.label.copyWith(color: colors.error)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// GG-12: due generi soltanto, e il cambio conserva la denominazione.
class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.kindCode, required this.onChanged});

  final String kindCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'FOOD', label: Text(context.l10n.editItemKindFood)),
        ButtonSegment(value: 'RECIPE', label: Text(context.l10n.editItemKindRecipe)),
      ],
      selected: {kindCode == 'RECIPE' ? 'RECIPE' : 'FOOD'},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

/// GG-22: valore e unità sono presenti entrambi o nessuno dei due, e il
/// numero si scrive col separatore della lingua (LO-10).
class _QuantityFields extends StatefulWidget {
  const _QuantityFields({
    required this.quantity,
    required this.unitCode,
    required this.onChanged,
    this.quantityError,
    this.unitError,
  });

  final num? quantity;
  final String? unitCode;
  final String? quantityError;
  final String? unitError;
  final void Function(num? quantity, String? unitCode) onChanged;

  @override
  State<_QuantityFields> createState() => _QuantityFieldsState();
}

class _QuantityFieldsState extends State<_QuantityFields> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialText());
  }

  String _initialText() {
    final quantity = widget.quantity;
    if (quantity == null) return '';
    final text = quantity.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final units = QuantityUnit.values;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            label: context.l10n.editItemQuantity,
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            errorText: widget.quantityError,
            onChanged: (value) => widget.onChanged(_parse(value), widget.unitCode),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: widget.unitCode,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.editItemUnit,
              errorText: widget.unitError,
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('—')),
              for (final unit in units)
                DropdownMenuItem<String>(
                  value: unit.toJson(),
                  child: Text(unitMenuLabel(context, unit)),
                ),
              // CO-7quater: un'unità che questa versione non conosce resta
              // scegliibile com'è, anziché sparire dal menu al primo tocco.
              if (widget.unitCode != null && QuantityUnit.tryFromJson(widget.unitCode) == null)
                DropdownMenuItem<String>(value: widget.unitCode, child: Text(widget.unitCode!)),
            ],
            onChanged: (value) => widget.onChanged(_parse(_controller.text), value),
          ),
        ),
      ],
    );
  }

  /// Accoglie entrambi i separatori: chi scrive «2.5» in italiano intende
  /// pur sempre due e mezzo.
  static num? _parse(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return num.tryParse(normalized);
  }
}

/// GG-25: alternative di un elemento, prive di alternative proprie.
class _Alternatives extends StatelessWidget {
  const _Alternatives({required this.item, required this.onChanged});

  final EditableItem item;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final alternative in item.alternatives)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(context.l10n.mealItemAlternativePrefix,
                        style: typography.caption.copyWith(color: colors.textSecondary)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: colors.textTertiary),
                      onPressed: () {
                        item.alternatives.remove(alternative);
                        alternative.dispose();
                        onChanged();
                      },
                    ),
                  ],
                ),
                _KindSelector(
                  kindCode: alternative.kindCode,
                  onChanged: (kind) {
                    alternative.kindCode = kind;
                    if (alternative.isRecipe) {
                      alternative.quantity = null;
                      alternative.unitCode = null;
                    } else {
                      alternative.recipeTextController.clear();
                    }
                    alternative.errors.clear();
                    onChanged();
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  label: context.l10n.editItemName,
                  controller: alternative.nameController,
                  errorText: alternative.errors['name'],
                  onChanged: (_) {
                    if (alternative.errors.remove('name') != null) onChanged();
                  },
                ),
                if (!alternative.isRecipe) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _QuantityFields(
                    quantity: alternative.quantity,
                    unitCode: alternative.unitCode,
                    quantityError: alternative.errors['quantity'],
                    unitError: alternative.errors['unit'],
                    onChanged: (quantity, unitCode) {
                      alternative.quantity = quantity;
                      alternative.unitCode = unitCode;
                      alternative.errors.remove('quantity');
                      alternative.errors.remove('unit');
                      onChanged();
                    },
                  ),
                ],
                if (alternative.isRecipe) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField(
                    label: context.l10n.slotRecipeText,
                    controller: alternative.recipeTextController,
                    minLines: 2,
                    maxLines: 4,
                  ),
                ],
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              item.alternatives.add(EditableAlternative());
              onChanged();
            },
            icon: Icon(Icons.add, size: 16, color: colors.accent),
            label: Text(context.l10n.editItemAlternativeAdd,
                style: typography.caption.copyWith(color: colors.accent)),
          ),
        ),
      ],
    );
  }
}
