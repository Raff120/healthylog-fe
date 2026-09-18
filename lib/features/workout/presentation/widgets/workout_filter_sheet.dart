import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../l10n/formats.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/workout_activity.dart';
import '../../providers/workout_providers.dart';
import '../workout_activity_presentation.dart';

/// Filtri dell'elenco (RA-12, 10.1 interfaccia.md): sport — tra quelli
/// già impiegati — e periodo. I filtri attivi sono presentati
/// come chip sotto l'intestazione, rimovibili singolarmente (vedi
/// `ActivityScreen`).
Future<void> showWorkoutFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _WorkoutFilterSheet(),
  );
}

class _WorkoutFilterSheet extends ConsumerStatefulWidget {
  const _WorkoutFilterSheet();

  @override
  ConsumerState<_WorkoutFilterSheet> createState() => _WorkoutFilterSheetState();
}

class _WorkoutFilterSheetState extends ConsumerState<_WorkoutFilterSheet> {
  late WorkoutFilters _filters = ref.read(workoutFilterControllerProvider);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final used = ref.watch(workoutActivitiesProvider).value ?? const <WorkoutActivityUsage>[];

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
              Text(context.l10n.workoutFilters, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              Text(context.l10n.workoutActivityType, style: typography.overline.copyWith(color: colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              if (used.isEmpty)
                Text(
                  context.l10n.workoutNoTypesYet,
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                )
              else
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    // AL-2: le voci sono gli sport praticati; l'attività
                    // denominata dall'Utente vi figura col proprio nome.
                    for (final usage in used)
                      FilterChip(
                        avatar: Icon(workoutActivityIcon(usage.activity), size: 16),
                        label: Text(workoutActivityName(context, usage.activity, usage.customName)),
                        selected: _filters.activity == usage.activity &&
                            _filters.customName == usage.customName,
                        onSelected: (selected) => setState(() {
                          _filters = WorkoutFilters(
                            activity: selected ? usage.activity : null,
                            customName: selected ? usage.customName : null,
                            from: _filters.from,
                            to: _filters.to,
                          );
                        }),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Text(context.l10n.workoutPeriod, style: typography.overline.copyWith(color: colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    initialDateRange: _filters.from != null && _filters.to != null
                        ? DateTimeRange(start: _filters.from!, end: _filters.to!)
                        : null,
                  );
                  if (range == null) return;
                  setState(() {
                    _filters = WorkoutFilters(
                      activity: _filters.activity,
                      customName: _filters.customName,
                      from: range.start,
                      to: range.end,
                    );
                  });
                },
                icon: const Icon(Icons.date_range_outlined, size: 18),
                label: Text(
                  _filters.from == null || _filters.to == null
                      ? context.l10n.workoutPickPeriod
                      : '${formatDate(context, _filters.from!)} — ${formatDate(context, _filters.to!)}',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: context.l10n.commonApply,
                onPressed: () {
                  ref.read(workoutFilterControllerProvider.notifier).apply(_filters);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () {
                  ref.read(workoutFilterControllerProvider.notifier).clear();
                  Navigator.of(context).pop();
                },
                child: Text(context.l10n.workoutClearFilters),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

