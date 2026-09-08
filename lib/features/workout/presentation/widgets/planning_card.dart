import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/workout_models.dart';
import '../../providers/workout_providers.dart';
import 'planning_sheet.dart';
import 'weekly_goal_sheet.dart';

/// Card riepilogativa in cima alla sezione allenamenti (10.1
/// interfaccia.md): lo schema ricorrente vigente (AL-10), le previsioni
/// occasionali (AL-11) e l'obiettivo settimanale ove impostato (OS-1).
///
/// OS-10: l'obiettivo non reca alcun avanzamento in questa sede —
/// l'avanzamento compare nelle sole statistiche. In assenza di
/// pianificazione e obiettivo la card presenta le due azioni di
/// impostazione, senza presentarne l'assenza come una mancanza (PR-15,
/// RA-18, 4.4 interfaccia.md).
class PlanningCard extends ConsumerWidget {
  const PlanningCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final planned = ref.watch(plannedWorkoutsProvider).value ?? const <PlannedWorkout>[];
    final goal = ref.watch(weeklyWorkoutGoalProvider).value;
    final weekly = planned.where((plan) => plan.isWeekly).toList();
    final oneOff = planned.where((plan) => !plan.isWeekly).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PIANIFICAZIONE',
                style: typography.overline.copyWith(color: colors.textSecondary),
              ),
              TextButton(
                onPressed: () => showPlanningSheet(context),
                child: Text(weekly.isEmpty && oneOff.isEmpty ? 'Imposta' : 'Modifica'),
              ),
            ],
          ),
          if (weekly.isEmpty && oneOff.isEmpty)
            Text(
              'Nessun allenamento pianificato',
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            )
          else ...[
            _WeekStrip(weekly: weekly),
            if (oneOff.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final plan in oneOff)
                Text(
                  '${plan.activityType} — ${_formatDate(plan.date!)}',
                  style: typography.caption.copyWith(color: colors.textSecondary),
                ),
            ],
          ],
          const SizedBox(height: AppSpacing.sm),
          Divider(color: colors.dividerLight, height: 1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal == null
                      ? 'Nessun obiettivo settimanale'
                      : '$goal ${goal == 1 ? 'allenamento' : 'allenamenti'} a settimana',
                  style: typography.bodyMedium.copyWith(
                    color: goal == null ? colors.textSecondary : colors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showWeeklyGoalSheet(context),
                child: Text(goal == null ? 'Imposta' : 'Modifica'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 10.1 interfaccia.md: sette iniziali, quelli previsti in accento, con il
/// tipo di attività in `caption` sotto ciascun giorno previsto.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.weekly});

  final List<PlannedWorkout> weekly;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      children: [
        for (final day in Weekday.values)
          Expanded(
            child: Column(
              children: [
                Text(
                  day.initial,
                  style: typography.label.copyWith(
                    color: _typesOn(day).isEmpty ? colors.textTertiary : colors.accent,
                    fontWeight: _typesOn(day).isEmpty ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _typesOn(day).join(', '),
                  style: typography.caption.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<String> _typesOn(Weekday day) => weekly
      .where((plan) => plan.daysOfWeek.contains(day))
      .map((plan) => plan.activityType)
      .toList();
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}
