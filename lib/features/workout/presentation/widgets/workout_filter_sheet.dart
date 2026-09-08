import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../providers/workout_providers.dart';

/// Filtri dell'elenco (RA-12, 10.1 interfaccia.md): tipo di attività —
/// tra quelli già impiegati — e periodo. I filtri attivi sono presentati
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
    final types = ref.watch(workoutActivityTypesProvider).value ?? const <String>[];

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
              Text('Filtri', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              Text('Tipo di attività', style: typography.overline.copyWith(color: colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              if (types.isEmpty)
                Text(
                  'Nessun tipo ancora registrato.',
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                )
              else
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    for (final type in types)
                      FilterChip(
                        label: Text(type),
                        selected: _filters.activityType == type,
                        onSelected: (selected) => setState(() {
                          _filters = WorkoutFilters(
                            activityType: selected ? type : null,
                            from: _filters.from,
                            to: _filters.to,
                          );
                        }),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Text('Periodo', style: typography.overline.copyWith(color: colors.textSecondary)),
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
                      activityType: _filters.activityType,
                      from: range.start,
                      to: range.end,
                    );
                  });
                },
                icon: const Icon(Icons.date_range_outlined, size: 18),
                label: Text(
                  _filters.from == null || _filters.to == null
                      ? 'Scegli un periodo'
                      : '${_formatDate(_filters.from!)} — ${_formatDate(_filters.to!)}',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: 'Applica',
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
                child: const Text('Rimuovi i filtri'),
              ),
            ],
          ),
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
