import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/diet_plan.dart';
import '../slot_type_presentation.dart';

/// Un giorno dello schema settimanale, di sola lettura (7.4, 7.5
/// interfaccia.md): comune all'anteprima di un template e al dettaglio
/// di un piano concluso, "struttura identica" fra le due (7.5).
class DayPreview extends StatelessWidget {
  const DayPreview({super.key, required this.day});

  final DietPlanWeekDay day;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.dayOfWeek.label, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          if (day.slots.isEmpty)
            Text('Nessuno slot', style: typography.caption.copyWith(color: colors.textTertiary))
          else
            for (final slot in day.slots)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(slot.type.icon, size: 18, color: colors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.label?.isNotEmpty == true ? slot.label! : slot.type.displayName,
                            style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                          ),
                          if (slot.content != null && slot.content!.isNotEmpty)
                            Text(
                              slot.content!,
                              style: typography.caption.copyWith(color: colors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
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
