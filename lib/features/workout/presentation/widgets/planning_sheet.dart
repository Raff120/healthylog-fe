import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/workout_models.dart';
import '../../data/workout_requests.dart';
import '../../providers/workout_providers.dart';
import '../weekday_presentation.dart';

/// Modifica della pianificazione (10.1 interfaccia.md): selezione dei
/// giorni della settimana (AL-10), tipo di attività, e l'azione per
/// aggiungere un allenamento occasionale su una data specifica (AL-11).
///
/// AL-16: la modifica non altera i giorni trascorsi — una `caption` lo
/// dichiara, ed è ciò che il backend attua chiudendo la vigenza dello
/// schema precedente (DS-14).
Future<void> showPlanningSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _PlanningSheet(),
  );
}

class _PlanningSheet extends ConsumerWidget {
  const _PlanningSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final planned = ref.watch(plannedWorkoutsProvider).value ?? const <PlannedWorkout>[];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.workoutPlanning,
                style: typography.titleMedium.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                context.l10n.workoutPlanningNotice,
                style: typography.caption.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final plan in planned)
                _PlannedRow(key: ValueKey(plan.id), plan: plan),
              if (planned.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    context.l10n.workoutNonePlannedDot,
                    style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => showPlannedWorkoutEditor(context, recurrence: WorkoutRecurrence.weekly),
                icon: const Icon(Icons.repeat, size: 18),
                label: Text(context.l10n.workoutAddRecurring),
              ),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: () => showPlannedWorkoutEditor(context, recurrence: WorkoutRecurrence.oneOff),
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(context.l10n.workoutAddOneOff),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Voce della pianificazione vigente, con modifica e cessazione (AL-16).
class _PlannedRow extends ConsumerWidget {
  const _PlannedRow({super.key, required this.plan});

  final PlannedWorkout plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(plan.isWeekly ? Icons.repeat : Icons.event_outlined, size: 18, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.activityType, style: typography.bodyMedium.copyWith(color: colors.textPrimary)),
                Text(
                  plan.isWeekly
                      ? plan.daysOfWeek.map((day) => workoutWeekdayLabel(context, day)).join(', ')
                      : _formatDate(plan.date!),
                  style: typography.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.commonEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => showPlannedWorkoutEditor(context, recurrence: plan.recurrence, existing: plan),
          ),
          IconButton(
            tooltip: context.l10n.workoutCease,
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => ref.read(plannedWorkoutControllerProvider.notifier).cease(plan.id),
          ),
        ],
      ),
    );
  }
}

/// Modulo di una singola pianificazione, ricorrente od occasionale.
Future<void> showPlannedWorkoutEditor(
  BuildContext context, {
  required WorkoutRecurrence recurrence,
  PlannedWorkout? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _PlannedWorkoutEditor(recurrence: recurrence, existing: existing),
  );
}

class _PlannedWorkoutEditor extends ConsumerStatefulWidget {
  const _PlannedWorkoutEditor({required this.recurrence, this.existing});

  final WorkoutRecurrence recurrence;
  final PlannedWorkout? existing;

  @override
  ConsumerState<_PlannedWorkoutEditor> createState() => _PlannedWorkoutEditorState();
}

class _PlannedWorkoutEditorState extends ConsumerState<_PlannedWorkoutEditor> {
  late final _activityTypeController =
      TextEditingController(text: widget.existing?.activityType ?? '');
  late final Set<Weekday> _days = {...?widget.existing?.daysOfWeek};
  late DateTime _date = widget.existing?.date ?? _dateOnly(DateTime.now());
  String? _error;

  bool get _isWeekly => widget.recurrence == WorkoutRecurrence.weekly;

  @override
  void dispose() {
    _activityTypeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final activityType = _activityTypeController.text.trim();
    if (activityType.isEmpty) {
      setState(() => _error = context.l10n.workoutActivityTypeRequired);
      return;
    }
    if (_isWeekly && _days.isEmpty) {
      setState(() => _error = context.l10n.workoutPickAtLeastOneDay);
      return;
    }
    final controller = ref.read(plannedWorkoutControllerProvider.notifier);
    final days = _days.toList()..sort((a, b) => a.index.compareTo(b.index));
    if (widget.existing != null) {
      await controller.update(
        widget.existing!.id,
        UpdatePlannedWorkoutRequest(
          activityType: activityType,
          daysOfWeek: _isWeekly ? days : const [],
          date: _isWeekly ? null : _date,
        ),
      );
    } else {
      await controller.create(
        _isWeekly
            ? CreatePlannedWorkoutRequest.weekly(daysOfWeek: days, activityType: activityType)
            : CreatePlannedWorkoutRequest.oneOff(date: _date, activityType: activityType),
      );
    }
    if (!mounted) return;
    if (ref.read(plannedWorkoutControllerProvider)?.hasError ?? false) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final saving = ref.watch(plannedWorkoutControllerProvider)?.isLoading ?? false;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isWeekly ? context.l10n.workoutRecurring : context.l10n.workoutOneOff,
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: context.l10n.workoutActivityType,
                  controller: _activityTypeController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_isWeekly)
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      for (final day in Weekday.values)
                        FilterChip(
                          label: Text(workoutWeekdayInitial(context, day)),
                          selected: _days.contains(day),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _days.add(day);
                            } else {
                              _days.remove(day);
                            }
                            _error = null;
                          }),
                        ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: _dateOnly(DateTime.now()),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) setState(() => _date = _dateOnly(picked));
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(_formatDate(_date)),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(_error!, style: typography.caption.copyWith(color: colors.error)),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(label: context.l10n.commonSave, loading: saving, onPressed: _submit),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}
