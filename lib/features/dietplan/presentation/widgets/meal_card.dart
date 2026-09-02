import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/plan_day.dart';
import '../../data/slot_status.dart';
import '../../data/slot_type.dart';
import '../slot_type_presentation.dart';

/// Card di sola lettura di uno slot della giornata (4.1 interfaccia.md,
/// VG-3, VG-4). A differenza di [SlotCard] (7.3, redazione) non consente
/// modifiche: la spunta (SP-1, F13) e l'inversione (MS-1, F17) restano
/// assenti.
class MealCard extends StatefulWidget {
  const MealCard({super.key, required this.slot});

  final PlanDaySlot slot;

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final consumption = context.consumptionColors;
    final slot = widget.slot;

    final hasContent = slot.content?.trim().isNotEmpty ?? false;
    final hasRecipe = slot.recipeName?.trim().isNotEmpty ?? false;
    final hasNote = slot.note?.trim().isNotEmpty ?? false;

    // "Da consumare" non ha colore proprio (2.2): il bordo resta nel
    // divisore forte, non in un accento di stato.
    final statusColor = switch (slot.status) {
      SlotStatus.consumed => consumption.consumed,
      SlotStatus.skipped => consumption.skipped,
      SlotStatus.toConsume => colors.dividerStrong,
    };

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(slot.type.icon, size: 20, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headerLabel(slot),
                      style: typography.overline.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (hasRecipe) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.soup_kitchen_outlined,
                            size: 16,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              slot.recipeName!.trim(),
                              style: typography.titleMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      hasContent ? slot.content!.trim() : 'Da definire',
                      style: typography.bodyLarge.copyWith(
                        color: hasContent
                            ? colors.textPrimary
                            : colors.textTertiary,
                      ),
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (_expanded && hasRecipe) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _openRecipeSheet(context, slot),
                          icon: Icon(
                            Icons.soup_kitchen_outlined,
                            size: 18,
                            color: colors.accent,
                          ),
                          label: Text(
                            'Vedi ricetta',
                            style: typography.label.copyWith(
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_expanded && hasNote) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              slot.note!.trim(),
                              style: typography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: AppSpacing.motionStateTransition,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// GG-10: lo spuntino usa la denominazione descrittiva assegnata nel
  /// piano quando presente, non l'etichetta generica del tipo.
  String _headerLabel(PlanDaySlot slot) {
    if (slot.type == SlotType.snack &&
        (slot.label?.trim().isNotEmpty ?? false)) {
      return slot.label!.trim();
    }
    return slot.type.displayName;
  }

  /// GG-15, GG-18: foglio modale a tre quarti di schermo. Il testo è
  /// libero e non strutturato: reso così com'è scritto (andate a capo ed
  /// elenchi puntati eventualmente già presenti), senza dedurne sezioni
  /// né alcuna interattività.
  void _openRecipeSheet(BuildContext context, PlanDaySlot slot) {
    final colors = context.colors;
    final typography = context.typography;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.75,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.recipeName!.trim(),
                  style: typography.titleLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      slot.recipeText?.trim().isNotEmpty == true
                          ? slot.recipeText!.trim()
                          : '',
                      style: typography.bodyLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
