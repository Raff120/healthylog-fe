import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../data/plan_day.dart';
import '../../data/slot_status.dart';
import '../../data/slot_type.dart';
import '../../providers/meal_swap_providers.dart';
import '../slot_type_presentation.dart';

/// Riga sintetica di uno slot nella vista settimanale (VS-3, 6.4
/// interfaccia.md): indicatore di stato, icona del tipo, contenuto
/// troncato a una riga. A differenza di `MealCard` (vista giornaliera)
/// non consente la spunta: qui si consulta soltanto (VS-4), salvo la
/// modalità di selezione dell'inversione (6.5), avviata dal tocco
/// prolungato (VS-8).
class WeekSlotRow extends ConsumerStatefulWidget {
  const WeekSlotRow({super.key, required this.day, required this.slot});

  final PlanDay day;
  final PlanDaySlot slot;

  @override
  ConsumerState<WeekSlotRow> createState() => _WeekSlotRowState();
}

class _WeekSlotRowState extends ConsumerState<WeekSlotRow> {
  /// IN-21, 6.5 interfaccia.md: il primo tocco su uno slot non
  /// compatibile resta silenzioso; solo chi insiste, toccandolo di
  /// nuovo, riceve la ragione.
  bool _incompatibleTapped = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final consumption = context.consumptionColors;
    final slot = widget.slot;
    final hasContent = slot.content?.trim().isNotEmpty ?? false;

    final origin = ref.watch(mealSwapSelectionProvider);
    if (origin == null) {
      _incompatibleTapped = false;
    }
    final highlight = origin == null ? null : mealSwapHighlightFor(origin, widget.day, slot);

    final dotColor = switch (slot.status) {
      SlotStatus.consumed => consumption.consumed,
      SlotStatus.skipped => consumption.skipped,
      // "Da consumare" non ha indicatore proprio (2.2, 6.4 interfaccia.md).
      SlotStatus.toConsume => null,
    };

    return Opacity(
      // 6.5 interfaccia.md: opacità 40% per gli slot non compatibili.
      opacity: highlight == MealSwapHighlight.incompatible ? 0.4 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: switch (highlight) {
            MealSwapHighlight.origin => Border.all(color: colors.accent, width: 2),
            MealSwapHighlight.compatible => Border.all(color: colors.accent, width: 1),
            _ => null,
          },
          color: highlight == MealSwapHighlight.origin ? colors.accentSubtle : null,
        ),
        child: InkWell(
          onTap: () => _onTap(context, origin, highlight),
          onLongPress: origin == null && isMealSwapOriginEligible(widget.day, slot)
              ? () => ref.read(mealSwapSelectionProvider.notifier).start(MealSwapOrigin(
                    planId: widget.day.planId!,
                    date: widget.day.date,
                    slotId: slot.slotId,
                    type: slot.type,
                    status: slot.status,
                  ))
              : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs, horizontal: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 8,
                  height: 8,
                  child: dotColor == null
                      ? null
                      : DecoratedBox(decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(slot.type.icon, size: 16, color: colors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    hasContent ? slot.content!.trim() : 'Da definire',
                    style: typography.bodyMedium.copyWith(
                      color: hasContent ? colors.textPrimary : colors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, MealSwapOrigin? origin, MealSwapHighlight? highlight) {
    if (origin == null) {
      // VS-4: fuori dalla selezione, il tocco apre il contenuto integrale.
      // 6.5 interfaccia.md, 3.3: il tocco prolungato non deve restare
      // l'unica via all'inversione — qui l'azione "Sposta", se ammessa.
      final eligible = isMealSwapOriginEligible(widget.day, widget.slot);
      _openDetailSheet(
        context,
        widget.slot,
        onMove: eligible
            ? () {
                Navigator.of(context).pop();
                ref.read(mealSwapSelectionProvider.notifier).start(MealSwapOrigin(
                      planId: widget.day.planId!,
                      date: widget.day.date,
                      slotId: widget.slot.slotId,
                      type: widget.slot.type,
                      status: widget.slot.status,
                    ));
              }
            : null,
      );
      return;
    }
    switch (highlight!) {
      case MealSwapHighlight.origin:
        // Non un gesto di rinuncia elencato da 6.5, ma non contraddice
        // "il tocco fuori dalla griglia... abbandonano l'operazione": il
        // tocco sulla stessa origine non ha altra azione sensata.
        ref.read(mealSwapSelectionProvider.notifier).cancel();
      case MealSwapHighlight.compatible:
        ref.read(mealSwapControllerProvider.notifier).swap(origin, widget.day.date, widget.slot.slotId);
      case MealSwapHighlight.incompatible:
        if (_incompatibleTapped) {
          // Sempre non nullo qui: `highlight` è già incompatibile.
          final reason = mealSwapRejectionReason(origin, widget.day, widget.slot)!;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeApiError(reason))));
        }
        setState(() => _incompatibleTapped = true);
    }
  }
}

/// VS-4: il contenuto integrale, con nota e ricetta, senza abbandonare
/// la vista settimanale — un foglio modale, non una nuova schermata.
/// [onMove] è l'azione di inversione (5, 6.5 interfaccia.md), assente
/// (`null`) quando lo slot non è ammissibile come origine.
void _openDetailSheet(BuildContext context, PlanDaySlot slot, {required VoidCallback? onMove}) {
  final colors = context.colors;
  final typography = context.typography;
  final hasContent = slot.content?.trim().isNotEmpty ?? false;
  final hasRecipe = slot.recipeName?.trim().isNotEmpty ?? false;
  final hasNote = slot.note?.trim().isNotEmpty ?? false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.7,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(slot.type.icon, size: 20, color: colors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(_headerLabel(slot), style: typography.overline.copyWith(color: colors.textSecondary)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasRecipe) ...[
                        Text(
                          slot.recipeName!.trim(),
                          style: typography.titleMedium.copyWith(color: colors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      Text(
                        hasContent ? slot.content!.trim() : 'Da definire',
                        style: typography.bodyLarge.copyWith(
                          color: hasContent ? colors.textPrimary : colors.textTertiary,
                        ),
                      ),
                      if (hasRecipe && (slot.recipeText?.trim().isNotEmpty ?? false)) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(slot.recipeText!.trim(), style: typography.bodyMedium.copyWith(color: colors.textPrimary)),
                      ],
                      if (hasNote) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: colors.textSecondary),
                            const SizedBox(width: AppSpacing.xxs),
                            Expanded(
                              child: Text(
                                slot.note!.trim(),
                                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (onMove != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onMove,
                    icon: Icon(Icons.swap_horiz, size: 18, color: colors.accent),
                    label: Text('Sposta', style: typography.label.copyWith(color: colors.accent)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

/// GG-10: lo spuntino usa la denominazione descrittiva assegnata nel
/// piano quando presente, non l'etichetta generica del tipo.
String _headerLabel(PlanDaySlot slot) {
  if (slot.type == SlotType.snack && (slot.label?.trim().isNotEmpty ?? false)) {
    return slot.label!.trim();
  }
  return slot.type.displayName;
}
