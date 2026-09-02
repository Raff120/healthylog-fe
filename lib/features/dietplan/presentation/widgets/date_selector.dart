import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../domain/plan_day_date.dart';

const _italianMonths = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

/// La localizzazione vera (LO-1, formati per lingua) è compito di F29:
/// qui, come nel resto del client prima di quella feature, i nomi sono
/// cablati in italiano.
String _monthYearLabel(DateTime date) =>
    '${_italianMonths[date.month - 1]} ${date.year}';

/// Selettore della data della vista giornaliera (4.3 interfaccia.md,
/// VG-16, VG-17): intestazione mese/anno che apre il calendario e riga
/// dei sette giorni della settimana corrente, toccabile per il salto
/// diretto. La navigazione non ha alcun limite temporale (VG-16, VG-17).
class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onSelect,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final today = dateOnly(DateTime.now());
    final weekStart = startOfWeek(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _openCalendar(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xxs,
            ),
            child: Text(
              _monthYearLabel(selectedDate),
              style: typography.titleMedium.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
        GestureDetector(
          // 4.3: "lo scorrimento orizzontale della riga conduce alle
          // settimane adiacenti".
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -200) {
              onSelect(weekStart.add(const Duration(days: 7)));
            } else if (velocity > 200) {
              onSelect(weekStart.subtract(const Duration(days: 7)));
            }
          },
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final day = weekStart.add(Duration(days: i));
                          return _DayColumn(
                            date: day,
                            selected: day == selectedDate,
                            isToday: day == today,
                            onTap: () => onSelect(day),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCalendar(BuildContext context) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => _CalendarSheet(initialDate: selectedDate),
    );
    if (picked != null) onSelect(picked);
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final weekday = weekdayOf(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.accent : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday.initial,
                style: typography.overline.copyWith(
                  color: selected ? colors.surface : colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${date.day}',
                style: typography.titleMedium.copyWith(
                  color: selected ? colors.surface : colors.textPrimary,
                ),
              ),
              if (isToday && !selected) ...[
                const SizedBox(height: 2),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 4, height: 4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Foglio modale su schermo stretto (4.3): la variante a riquadro
/// ancorato su schermo ampio è rinviata (vedi decisioni.md), sul modello
/// di altre adattività non ancora differenziate per larghezza.
class _CalendarSheet extends StatelessWidget {
  const _CalendarSheet({required this.initialDate});

  final DateTime initialDate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        // VG-16, VG-17: nessun limite pratico alla navigazione — un
        // secolo in ciascuna direzione, oltre l'estensione che
        // CalendarDatePicker richiede comunque di dichiarare.
        child: CalendarDatePicker(
          initialDate: initialDate,
          firstDate: DateTime(initialDate.year - 100),
          lastDate: DateTime(initialDate.year + 100),
          onDateChanged: (date) => Navigator.of(context).pop(date),
        ),
      ),
    );
  }
}
