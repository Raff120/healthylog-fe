import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../providers/workout_providers.dart';
import 'workout_sheet.dart';

/// Sezione degli allenamenti nella vista giornaliera (AL-12, VG-6, 6.2
/// interfaccia.md): compare **sopra i pasti**, distinta da questi ultimi
/// dal fondo in superficie alternativa.
///
/// Gli allenamenti già registrati ma non pianificati vi compaiono nella
/// medesima sezione, già spuntati. In assenza di previsti e registrati la
/// sezione non compare.
///
/// CU-10, VG-10: la sezione è assente sulla giornata di un altro membro
/// del Gruppo — gli allenamenti sono riservati; il chiamante non la
/// costruisce affatto in quel caso.
class DayWorkoutsSection extends ConsumerWidget {
  const DayWorkoutsSection({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.typography;
    final colors = context.colors;
    final day = ref.watch(dayWorkoutsProvider(date)).value;
    if (day == null || day.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ALLENAMENTO',
            style: typography.overline.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxs),
          for (final planned in day.pendingPlanned)
            _WorkoutRow(
              key: ValueKey('planned-${planned.id}'),
              label: planned.activityType,
              done: false,
              // AL-13, RA-3: la marcatura come svolto genera la
              // registrazione ereditando il tipo, e apre il foglio ridotto
              // per calorie e nota — che si può ignorare chiudendolo.
              onCheck: () => showWorkoutSheet(context, date: date, planned: planned),
            ),
          for (final workout in day.recorded)
            _WorkoutRow(
              key: ValueKey('recorded-${workout.id}'),
              label: workout.activityType,
              done: true,
              calories: workout.caloriesBurned,
              onCheck: () => showWorkoutSheet(context, existing: workout),
            ),
        ],
      ),
    );
  }
}

/// Card alta 56 con icona, tipo di attività e un solo pulsante di spunta:
/// l'allenamento è svolto o non lo è, non esiste lo stato *saltato*
/// (AL-13, 6.2 interfaccia.md).
class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({
    super.key,
    required this.label,
    required this.done,
    required this.onCheck,
    this.calories,
  });

  final String label;
  final bool done;
  final int? calories;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(Icons.directions_run, size: 20, color: colors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: typography.bodyLarge.copyWith(color: colors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // CB-8: le calorie sul singolo allenamento cui si riferiscono.
            if (calories != null)
              Text(
                '$calories kcal',
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
            IconButton(
              tooltip: done ? 'Modifica' : 'Segna come svolto',
              onPressed: onCheck,
              icon: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? colors.confirm : colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
