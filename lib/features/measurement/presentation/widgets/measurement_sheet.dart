import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/measurement_models.dart';
import '../../data/measurement_requests.dart';
import '../../providers/measurement_providers.dart';

/// Registrazione e modifica di una misurazione (10.3 interfaccia.md).
///
/// PR-12: peso e circonferenze sono tutti facoltativi; PR-13: almeno un
/// valore è richiesto, e il tentativo di salvare un modulo vuoto è
/// impedito con messaggio sul modulo.
///
/// I campi non compilati **restano vuoti** e non sono precompilati con i
/// valori della misurazione precedente: precompilarli produrrebbe dati mai
/// rilevati — lo stesso principio che CB-2 pone per le calorie.
///
/// [patientId]: NU-12, PR-17 — il Nutrizionista registra per conto del
/// proprio Paziente, tipicamente a seguito di una visita.
Future<void> showMeasurementSheet(
  BuildContext context, {
  BodyMeasurement? existing,
  String? patientId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _MeasurementSheet(existing: existing, patientId: patientId),
  );
}

class _MeasurementSheet extends ConsumerStatefulWidget {
  const _MeasurementSheet({this.existing, this.patientId});

  final BodyMeasurement? existing;
  final String? patientId;

  @override
  ConsumerState<_MeasurementSheet> createState() => _MeasurementSheetState();
}

class _MeasurementSheetState extends ConsumerState<_MeasurementSheet> {
  late final _weight = _controllerFor(widget.existing?.weightKg);
  late final _waist = _controllerFor(widget.existing?.circumferences.waist);
  late final _hips = _controllerFor(widget.existing?.circumferences.hips);
  late final _chest = _controllerFor(widget.existing?.circumferences.chest);
  late final _arm = _controllerFor(widget.existing?.circumferences.arm);
  late final _thigh = _controllerFor(widget.existing?.circumferences.thigh);
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  late DateTime _date = widget.existing?.date ?? _dateOnly(DateTime.now());
  String? _error;

  static TextEditingController _controllerFor(double? value) =>
      TextEditingController(text: value == null ? '' : _formatNumber(value));

  @override
  void dispose() {
    for (final controller in [_weight, _waist, _hips, _chest, _arm, _thigh, _note]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _valueOf(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  Future<void> _submit() async {
    final circumferences = BodyCircumferences(
      waist: _valueOf(_waist),
      hips: _valueOf(_hips),
      chest: _valueOf(_chest),
      arm: _valueOf(_arm),
      thigh: _valueOf(_thigh),
    );
    final weight = _valueOf(_weight);
    // PR-13: la nota non è un valore rilevato — da sola non basta.
    if (weight == null && circumferences.isEmpty) {
      setState(() => _error = 'Inserisci almeno un valore');
      return;
    }
    final note = _note.text.trim();

    final controller = ref.read(measurementControllerProvider.notifier);
    if (widget.existing != null) {
      await controller.update(
        widget.existing!.id,
        UpdateBodyMeasurementRequest(
          date: _date,
          weightKg: weight,
          circumferences: circumferences,
          note: note.isEmpty ? null : note,
        ),
        patientId: widget.patientId,
      );
    } else {
      await controller.create(
        CreateBodyMeasurementRequest(
          date: _date,
          weightKg: weight,
          circumferences: circumferences,
          note: note.isEmpty ? null : note,
          userId: widget.patientId,
        ),
      );
    }
    if (!mounted) return;
    if (ref.read(measurementControllerProvider)?.hasError ?? false) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final saving = ref.watch(measurementControllerProvider)?.isLoading ?? false;

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
                  widget.existing != null ? 'Modifica misurazione' : 'Registra una misurazione',
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
                if (widget.patientId != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  // NU-12: la misurazione resta distinguibile come rilevata
                  // dal professionista, e il Paziente non potrà modificarla.
                  Text(
                    'La registri tu: la persona potrà consultarla ma non modificarla.',
                    style: typography.caption.copyWith(color: colors.textTertiary),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _DateField(date: _date, onTap: _pickDate),
                const SizedBox(height: AppSpacing.sm),
                _NumberField(label: 'Peso (kg)', controller: _weight, onChanged: _clearError),
                const SizedBox(height: AppSpacing.sm),
                _NumberField(label: 'Vita (cm)', controller: _waist, onChanged: _clearError),
                const SizedBox(height: AppSpacing.sm),
                _NumberField(label: 'Fianchi (cm)', controller: _hips, onChanged: _clearError),
                const SizedBox(height: AppSpacing.sm),
                _NumberField(label: 'Torace (cm)', controller: _chest, onChanged: _clearError),
                const SizedBox(height: AppSpacing.sm),
                _NumberField(label: 'Braccio (cm)', controller: _arm, onChanged: _clearError),
                const SizedBox(height: AppSpacing.sm),
                _NumberField(label: 'Coscia (cm)', controller: _thigh, onChanged: _clearError),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Nota', controller: _note, minLines: 2, maxLines: 4),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(_error!, style: typography.caption.copyWith(color: colors.error)),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(label: 'Salva', loading: saving, onPressed: _submit),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: _dateOnly(DateTime.now()),
    );
    if (picked != null) setState(() => _date = _dateOnly(picked));
  }
}

/// Le unità sono indicate accanto a ciascun campo (10.3); la preferenza
/// dell'Utente sul sistema di misura (LO-4) resta a F29.
class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller, required this.onChanged});

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      onChanged: onChanged,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        height: AppSpacing.heightTextField,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(color: colors.dividerStrong),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: colors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              formatMeasurementDate(date),
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

String formatMeasurementDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}

/// Senza decimali superflui: 72 anziché 72.0.
String _formatNumber(double value) =>
    value == value.roundToDouble() ? value.round().toString() : value.toString();

String formatMeasurementValue(double value) => _formatNumber(value);
