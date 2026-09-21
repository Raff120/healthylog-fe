import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../editable_slot.dart';
import '../editable_weeks.dart';

/// Selettore delle settimane dello schema (7.3 interfaccia.md, PA-2):
/// un segmento per settimana, quella in redazione in accento, e sotto il
/// segmento il medesimo punto di incompletezza dei giorni (CD-15).
/// Scorre in orizzontale quando le etichette non entrano nella larghezza.
///
/// Non compare con una settimana sola: lo schema si presenta allora come
/// prima dei piani su più settimane (vedi [ScheduleNavigation]).
class ScheduleWeekSelector extends StatelessWidget {
  const ScheduleWeekSelector({super.key, required this.days, required this.selected, required this.onSelect});

  final List<EditableDay> days;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
          for (var week = 1; week <= days.weekCount; week++)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _WeekSegment(
                label: context.l10n.scheduleWeek(week),
                selected: week == selected,
                incomplete: days.weekHasIncompleteSlot(week),
                onTap: () => onSelect(week),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekSegment extends StatelessWidget {
  const _WeekSegment({
    required this.label,
    required this.selected,
    required this.incomplete,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool incomplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          selected: selected,
          button: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              constraints: const BoxConstraints(minHeight: AppSpacing.minInteractiveTarget),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: selected ? colors.accent : colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                label,
                style: typography.label.copyWith(color: selected ? colors.surface : colors.textPrimary),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        SizedBox(
          height: AppSpacing.xxs,
          width: AppSpacing.xxs,
          child: incomplete
              ? DecoratedBox(decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle))
              : null,
        ),
      ],
    );
  }
}
