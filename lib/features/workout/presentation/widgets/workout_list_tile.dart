import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/workout_models.dart';

/// Voce dell'elenco degli allenamenti (10.1 interfaccia.md): alta 68, con
/// data, tipo di attività, calorie se indicate e nota se presente
/// (RA-11). L'icona distingue gli allenamenti svolti a fronte di una
/// pianificazione da quelli registrati spontaneamente (RA-13).
///
/// RA-14: il tocco conduce alla modifica.
class WorkoutListTile extends StatelessWidget {
  const WorkoutListTile({super.key, required this.workout, this.onTap});

  final Workout workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.heightListItemTwoLines),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDate(workout.date),
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          workout.activityType,
                          style: typography.titleMedium.copyWith(color: colors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (workout.fromPlanning) ...[
                        const SizedBox(width: AppSpacing.xxs),
                        Icon(Icons.event_available, size: 16, color: colors.textTertiary),
                      ],
                    ],
                  ),
                  if (workout.note != null && workout.note!.isNotEmpty)
                    Text(
                      workout.note!,
                      style: typography.caption.copyWith(color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // CB-8: il valore è presentato sul singolo allenamento cui si
            // riferisce, mai aggregato (CB-9).
            if (workout.caloriesBurned != null)
              Text(
                '${workout.caloriesBurned} kcal',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}
