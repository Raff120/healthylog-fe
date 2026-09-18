import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../providers/workout_providers.dart';
import '../workout_activity_presentation.dart';

/// Allenamenti in coda al pannello del giorno nella vista settimanale
/// (AL-12, VS-6, 6.4 interfaccia.md): la sola denominazione dello sport e lo stato
/// di svolgimento, **senza possibilità di registrazione** — quella
/// avviene dalla destinazione *Allenamenti* (RA-4), o dalla vista
/// giornaliera con la spunta di un allenamento previsto (RA-3).
///
/// CU-10, VG-10: assente sulla settimana di un altro membro del Gruppo,
/// cui gli allenamenti sono riservati.
class WeekDayWorkouts extends ConsumerWidget {
  const WeekDayWorkouts({super.key, required this.weekStart, required this.date});

  final DateTime weekStart;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final week = ref.watch(weekWorkoutsProvider(weekStart)).value;
    if (week == null) return const SizedBox.shrink();

    final day = week.where((entry) => _sameDay(entry.date, date)).firstOrNull;
    if (day == null || day.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xxs, AppSpacing.xs, AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: AppSpacing.sm, color: colors.dividerLight),
          // AL-2: la denominazione discende dal codice, nella lingua
          // corrente. La cella settimanale è troppo stretta perché
          // all'icona di stato se ne affianchi una seconda (VS-6).
          for (final workout in day.recorded)
            _Row(
              label: workoutActivityName(context, workout.activityCode, workout.activityType),
              done: true,
            ),
          for (final planned in day.pendingPlanned)
            _Row(
              label: workoutActivityName(context, planned.activityCode, planned.activityType),
              done: false,
            ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: done ? colors.confirm : colors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Text(
              label,
              style: typography.caption.copyWith(color: colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
