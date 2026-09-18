import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../../l10n/unit_system.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../data/hydration_models.dart';
import '../../domain/water_amounts.dart';
import '../../providers/hydration_providers.dart';
import '../hydration_formatting.dart';
import 'water_amount_sheet.dart';
import 'water_day_sheet.dart';

/// Sezione dell'acqua nella vista giornaliera (AQ-16, 6.2
/// interfaccia.md): fra gli allenamenti e i pasti, perché è lì che si
/// registra il bere e non altrove nell'applicazione.
///
/// **Nessuna barra di riempimento, nessuna percentuale, nessuna ruota di
/// avanzamento** (AQ-16). Il totale raggiunto o superato non muta colore
/// e non produce alcuna celebrazione (AQ-23): la riga dice quanto si è
/// bevuto, non come si sta andando. È la deroga circoscritta a OS-11 di
/// AQ-17, e l'assenza della barra è ciò che la contiene.
///
/// AQ-19: la sezione è **sempre presente** sulla propria giornata, anche
/// a totale nullo — è la condizione in cui i comandi servono di più. In
/// ciò differisce dalla sezione degli allenamenti, che quando è vuota non
/// compare.
///
/// AQ-20, VA-12: assente sulla giornata di un altro membro del Gruppo, cui
/// il consumo d'acqua è riservato; il chiamante non la costruisce affatto
/// in quel caso.
class DayWaterSection extends ConsumerWidget {
  const DayWaterSection({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.typography;
    final colors = context.colors;
    final units = ref.watch(unitSystemProvider);
    final day = ref.watch(waterIntakeDayProvider(date)).value ?? WaterIntakeDay.empty(date);
    final goal = ref.watch(dailyWaterGoalProvider).value;
    // AQ-9: non si può aver bevuto domani — sulla giornata futura non vi
    // sono comandi, e il totale non ha nulla da dire.
    final isFuture = _isFuture(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, size: 16, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                context.l10n.waterSectionTitle,
                style: typography.overline.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          if (!isFuture) ...[
            const SizedBox(height: AppSpacing.xxs),
            _Total(day: day, goal: goal),
            const SizedBox(height: AppSpacing.xs),
            _QuickAdd(date: date, units: units),
          ],
        ],
      ),
    );
  }

  static bool _isFuture(DateTime date) {
    final now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .isAfter(DateTime(now.year, now.month, now.day));
  }
}

/// AQ-16: il bevuto della giornata e, se impostato, l'obiettivo. In forma
/// testuale: si dichiara una quantità, non una parte di traguardo.
///
/// Il tocco apre il foglio della giornata, da cui si annulla una singola
/// aggiunta (AQ-8).
class _Total extends ConsumerWidget {
  const _Total({required this.day, required this.goal});

  final WaterIntakeDay day;
  final int? goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.typography;
    final colors = context.colors;
    final units = ref.watch(unitSystemProvider);

    return InkWell(
      onTap: day.entries.isEmpty ? null : () => showWaterDaySheet(context, date: day.date),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatVolume(context, day.totalMl, units),
              // Colore primario, mai di stato: non è un giudizio (AQ-23).
              style: typography.titleMedium.copyWith(color: colors.textPrimary),
            ),
            if (goal != null) ...[
              const SizedBox(width: AppSpacing.xxs),
              Text(
                context.l10n.waterOfGoal(formatVolume(context, goal!, units)),
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AQ-5, AQ-6, AQ-7: le tre quantità rapide e la quantità libera.
///
/// Le pastiglie vanno a capo quando la larghezza non basta (2.4): su
/// schermo stretto una riga sola le comprimerebbe fino a rendere
/// illeggibile la quantità, che è ciò che occorre leggere.
class _QuickAdd extends ConsumerWidget {
  const _QuickAdd({required this.date, required this.units});

  final DateTime date;
  final UnitSystem units;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // AQ-5: il tocco registra senza conferma. L'errore si annulla dal
    // foglio della giornata (AQ-8), che è la ragione per cui la conferma
    // non serve.
    void add(int millilitres) =>
        ref.read(waterIntakeControllerProvider.notifier).add(date, millilitres);

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final amount in WaterAmount.values)
          _AmountChip(
            key: ValueKey('waterAmount-${amount.name}'),
            label: waterAmountName(context, amount),
            value: formatVolume(context, amount.millilitresIn(units), units),
            onTap: () => add(amount.millilitresIn(units)),
          ),
        // AQ-7: la quantità diversa da quelle previste, che non ha nome.
        _AmountChip(
          key: const ValueKey('waterAmount-custom'),
          icon: Icons.add,
          label: context.l10n.waterAddCustom,
          onTap: () => showWaterAmountSheet(context, date: date),
          iconOnly: true,
          iconColor: colors.accent,
        ),
      ],
    );
  }
}

/// Pastiglia di aggiunta rapida: fondo in superficie alternativa,
/// curvatura piena, altezza 40 (2.4 interfaccia.md).
class _AmountChip extends StatelessWidget {
  const _AmountChip({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.icon,
    this.iconOnly = false,
    this.iconColor,
  });

  final String label;
  final String? value;
  final IconData? icon;
  final bool iconOnly;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Semantics(
      button: true,
      label: value == null ? label : '$label $value',
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: SizedBox(
            height: AppSpacing.minInteractiveTarget,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(icon, size: 20, color: iconColor ?? colors.textSecondary),
                  if (!iconOnly) ...[
                    Text(label, style: typography.bodyMedium.copyWith(color: colors.textPrimary)),
                    if (value != null) ...[
                      const SizedBox(width: AppSpacing.xxs),
                      Text(value!, style: typography.caption.copyWith(color: colors.textSecondary)),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
