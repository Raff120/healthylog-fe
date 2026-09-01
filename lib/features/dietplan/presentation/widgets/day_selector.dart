import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/weekday.dart';
import '../editable_slot.dart';

/// Selettore dei giorni (7.3 interfaccia.md): sette segmenti con le
/// iniziali, il giorno in redazione evidenziato in accento, un punto in
/// colore di errore sotto l'iniziale per i giorni con slot privi di
/// contenuto (CD-15) — l'unica segnalazione di incompletezza ammessa
/// nell'applicazione (2.6).
class DaySelector extends StatelessWidget {
  const DaySelector({super.key, required this.days, required this.selected, required this.onSelect});

  final List<EditableDay> days;
  final Weekday selected;
  final ValueChanged<Weekday> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((day) {
          final isSelected = day.dayOfWeek == selected;
          return InkWell(
            onTap: () => onSelect(day.dayOfWeek),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: AppSpacing.minInteractiveTarget / 2,
                    backgroundColor: isSelected ? colors.accent : colors.surfaceAlt,
                    child: Text(
                      day.dayOfWeek.initial,
                      style: typography.label.copyWith(
                        color: isSelected ? colors.surface : colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  SizedBox(
                    height: AppSpacing.xxs,
                    width: AppSpacing.xxs,
                    child: day.hasIncompleteSlot
                        ? DecoratedBox(
                            decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
