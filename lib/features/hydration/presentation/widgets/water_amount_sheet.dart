import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../../l10n/unit_system.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../domain/water_amounts.dart';
import '../../providers/hydration_providers.dart';
import '../hydration_formatting.dart';

/// AQ-7: la quantità diversa da quelle previste dai tre comandi rapidi.
/// Un campo solo, nell'unità del sistema scelto (LO-4).
Future<void> showWaterAmountSheet(BuildContext context, {required DateTime date}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _WaterAmountSheet(date: date),
  );
}

class _WaterAmountSheet extends ConsumerStatefulWidget {
  const _WaterAmountSheet({required this.date});

  final DateTime date;

  @override
  ConsumerState<_WaterAmountSheet> createState() => _WaterAmountSheetState();
}

class _WaterAmountSheetState extends ConsumerState<_WaterAmountSheet> {
  final TextEditingController _controller = TextEditingController();
  late final UnitSystem _units = ref.read(unitSystemProvider);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// LO-7, LO-10: il valore è scritto nell'unità di presentazione e
  /// convertito in millilitri, che sono l'unità di conservazione. Il
  /// separatore decimale è quello della lingua, e vi si ammette anche il
  /// punto: chi scrive «1.5» intende un litro e mezzo.
  int? get _millilitres {
    final shown = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (shown == null || shown <= 0) return null;
    return volumeToStorage(shown, _units);
  }

  Future<void> _save() async {
    final amount = _millilitres;
    if (amount == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final notice = context.l10n.waterAddedNotice(formatVolume(context, amount, _units));
    final failure = describeApiError(context, '');
    final added = await ref.read(waterIntakeControllerProvider.notifier).add(widget.date, amount);
    if (!mounted) return;
    // Fallita, il foglio resta dov'è: la quantità scritta non va riscritta
    // per riprovare (4.5).
    if (!added) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
      return;
    }
    Navigator.of(context).pop();
    // 4.5: la constatazione dell'aggiunta, che altrove non si vedrebbe.
    messenger.showSnackBar(SnackBar(content: Text(notice)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final saving = ref.watch(waterIntakeControllerProvider)?.isLoading ?? false;
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
                  context.l10n.waterCustomTitle,
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('waterCustomAmountField'),
                  label: '${context.l10n.waterCustomAmount} ($unit)',
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  label: context.l10n.commonSave,
                  loading: saving,
                  onPressed: _millilitres == null ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
