import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../../l10n/unit_system.dart';
import '../../../../l10n/units.dart';
import '../../providers/profile_providers.dart';

/// Impostazione del peso obiettivo (PR-8, PR-10).
///
/// Si apre dal segmento *Corpo* di *Statistiche* (11.3 interfaccia.md),
/// dove la linea di riferimento che ne discende (AN-6) è sotto gli
/// occhi. Stava fra i dati personali, dove non lo si trovava (segnalato
/// dall'utente, vedi decisioni.md).
///
/// PR-9, AN-9: nessun giudizio sul valore, nessuna distanza residua,
/// nessun tempo stimato. È un riferimento che l'Utente si dà.
Future<void> showTargetWeightSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _TargetWeightSheet(),
  );
}

class _TargetWeightSheet extends ConsumerStatefulWidget {
  const _TargetWeightSheet();

  @override
  ConsumerState<_TargetWeightSheet> createState() => _TargetWeightSheetState();
}

class _TargetWeightSheetState extends ConsumerState<_TargetWeightSheet> {
  late final UnitSystem _units = ref.read(unitSystemProvider);
  late final TextEditingController _controller = TextEditingController(
    text: _initialText(ref.read(profileControllerProvider).value?.targetWeightKg),
  );

  bool _saving = false;

  /// LO-4, LO-7: il peso è conservato in chilogrammi e presentato
  /// nell'unità del sistema scelto.
  String _initialText(double? targetWeightKg) {
    if (targetWeightKg == null) return '';
    final shown = weightToDisplay(targetWeightKg, _units);
    final rounded = double.parse(shown.toStringAsFixed(1));
    return rounded == rounded.roundToDouble() ? rounded.round().toString() : rounded.toString();
  }

  /// LO-10: il punto è ammesso quanto la virgola. PR-9: la sola
  /// leggibilità come numero, nessun giudizio sulla congruità.
  double? get _kilograms {
    final shown = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (shown == null || shown <= 0) return null;
    return weightToStorage(shown, _units);
  }

  Future<void> _save(double? targetWeightKg) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).saveTargetWeight(targetWeightKg);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      // Fallito, il foglio resta dov'è: il valore scritto non va
      // riscritto per riprovare (4.5).
      messenger.showSnackBar(SnackBar(
        content: Text(describeApiError(context, error.asApiException?.code ?? '')),
      ));
      return;
    }
    if (!mounted) return;
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
    final current = ref.watch(profileControllerProvider).value?.targetWeightKg;

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
                  context.l10n.personalDataTargetWeight,
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xxs),
                // AN-6: la didascalia ne dichiara l'unico impiego.
                Text(
                  context.l10n.targetWeightHelp,
                  style: typography.caption.copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('targetWeightField'),
                  label: context.l10n.measureWithUnit(
                    context.l10n.personalDataTargetWeight,
                    weightUnit(context, _units),
                  ),
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: context.l10n.commonSave,
                  loading: _saving,
                  onPressed: _kilograms == null ? null : () => _save(_kilograms),
                ),
                // PR-10: la rimozione è un'azione esplicita.
                if (current != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    key: const Key('targetWeightRemove'),
                    onPressed: _saving ? null : () => _save(null),
                    child: Text(context.l10n.targetWeightRemove),
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
