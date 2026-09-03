import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/plan_day.dart';
import '../../data/slot_status.dart';
import '../../data/slot_type.dart';
import '../slot_type_presentation.dart';

/// Riga sintetica di uno slot nella vista settimanale (VS-3, 6.4
/// interfaccia.md): indicatore di stato, icona del tipo, contenuto
/// troncato a una riga. A differenza di `MealCard` (vista giornaliera)
/// non consente la spunta: qui si consulta soltanto (VS-4). Il tocco
/// prolungato per l'inversione (6.5) è compito di F17.
class WeekSlotRow extends StatelessWidget {
  const WeekSlotRow({super.key, required this.slot});

  final PlanDaySlot slot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final consumption = context.consumptionColors;
    final hasContent = slot.content?.trim().isNotEmpty ?? false;

    final dotColor = switch (slot.status) {
      SlotStatus.consumed => consumption.consumed,
      SlotStatus.skipped => consumption.skipped,
      // "Da consumare" non ha indicatore proprio (2.2, 6.4 interfaccia.md).
      SlotStatus.toConsume => null,
    };

    return InkWell(
      onTap: () => _openDetailSheet(context, slot),
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
    );
  }
}

/// VS-4: il contenuto integrale, con nota e ricetta, senza abbandonare
/// la vista settimanale — un foglio modale, non una nuova schermata.
void _openDetailSheet(BuildContext context, PlanDaySlot slot) {
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
