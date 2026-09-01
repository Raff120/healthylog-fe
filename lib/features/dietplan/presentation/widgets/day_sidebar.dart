import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/weekday.dart';
import '../editable_slot.dart';

/// Navigazione dei giorni su schermo ampio (7.3 interfaccia.md, MP-6):
/// affiancata alla redazione del giorno selezionato, non sostituita da
/// essa come in `compact` (`DaySelector`). Stesso segnale di
/// incompletezza (CD-15).
class DaySidebar extends StatelessWidget {
  const DaySidebar({super.key, required this.days, required this.selected, required this.onSelect});

  final List<EditableDay> days;
  final Weekday selected;
  final ValueChanged<Weekday> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: days.map((day) {
        final isSelected = day.dayOfWeek == selected;
        return InkWell(
          onTap: () => onSelect(day.dayOfWeek),
          child: Container(
            color: isSelected ? colors.accentSubtle : null,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    day.dayOfWeek.label,
                    style: typography.bodyLarge.copyWith(
                      color: isSelected ? colors.accent : colors.textPrimary,
                    ),
                  ),
                ),
                if (day.hasIncompleteSlot)
                  DecoratedBox(
                    decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                    child: const SizedBox(width: AppSpacing.xxs, height: AppSpacing.xxs),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
