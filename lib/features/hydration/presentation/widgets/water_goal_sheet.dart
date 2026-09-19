import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../../l10n/unit_system.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../domain/water_amounts.dart';
import '../../providers/hydration_providers.dart';

/// Impostazione dell'obiettivo giornaliero d'acqua (AQ-11, AQ-12).
///
/// Si apre dalla sezione *Acqua* di *Statistiche* (11.1 interfaccia.md),
/// dove la linea di riferimento che ne discende (AQ-26) è sotto gli
/// occhi. Stava fra i dati personali, dove non lo si trovava (segnalato
/// dall'utente, vedi decisioni.md).
///
/// AQ-17 resta osservato: l'obiettivo non compare nella vista
/// quotidiana, che offre l'azione e non la misura. Le statistiche sono
/// la destinazione delle misure, ed è lì che un traguardo si dà e si
/// guarda.
Future<void> showWaterGoalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _WaterGoalSheet(),
  );
}

class _WaterGoalSheet extends ConsumerStatefulWidget {
  const _WaterGoalSheet();

  @override
  ConsumerState<_WaterGoalSheet> createState() => _WaterGoalSheetState();
}

class _WaterGoalSheetState extends ConsumerState<_WaterGoalSheet> {
  late final UnitSystem _units = ref.read(unitSystemProvider);
  late final TextEditingController _controller = TextEditingController(
    text: _initialText(ref.read(dailyWaterGoalProvider).value),
  );

  /// LO-4, LO-7: l'obiettivo è conservato in millilitri e presentato
  /// nell'unità del sistema scelto.
  String _initialText(int? goalMl) {
    if (goalMl == null) return '';
    final shown = volumeToDisplay(goalMl, _units);
    final rounded = double.parse(shown.toStringAsFixed(1));
    return rounded == rounded.roundToDouble() ? rounded.round().toString() : rounded.toString();
  }

  /// LO-10: il punto è ammesso quanto la virgola.
  int? get _millilitres {
    final shown = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    // AQ-24: nessun giudizio sulla congruità dell'obiettivo, solo la sua
    // leggibilità come numero.
    if (shown == null || shown <= 0) return null;
    return volumeToStorage(shown, _units);
  }

  Future<void> _save(int? valueMl) async {
    await ref.read(dailyWaterGoalProvider.notifier).save(valueMl);
    if (!mounted) return;
    if (ref.read(dailyWaterGoalProvider).hasError) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final goal = ref.watch(dailyWaterGoalProvider);
    final unit = _units == UnitSystem.imperial
        ? context.l10n.unitFluidOunces
        : context.l10n.unitQuantityMilliliter;

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
                  context.l10n.waterGoalLabel,
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xxs),
                // AQ-26: la didascalia ne dichiara l'unico impiego — e
                // che non è un contatore da rincorrere (AQ-17).
                Text(
                  context.l10n.waterGoalHelp,
                  style: typography.caption.copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('waterGoalField'),
                  label: context.l10n.measureWithUnit(context.l10n.waterGoalLabel, unit),
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: context.l10n.commonSave,
                  loading: goal.isLoading,
                  onPressed: _millilitres == null ? null : () => _save(_millilitres),
                ),
                // AQ-15, DS-20: la rimozione è un'azione esplicita, e le
                // giornate trascorse conservano l'obiettivo allora vigente.
                if (goal.value != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    key: const Key('waterGoalRemove'),
                    onPressed: goal.isLoading ? null : () => _save(null),
                    child: Text(context.l10n.waterGoalRemove),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
