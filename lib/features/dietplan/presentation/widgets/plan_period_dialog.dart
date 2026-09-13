import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../l10n/formats.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/diet_plan.dart';
import '../../data/diet_plan_requests.dart';
import '../../data/plan_status.dart';
import '../../domain/plan_day_date.dart';
import '../../providers/diet_plan_providers.dart';
import '../plan_overlap_message.dart';
import 'date_field.dart';

/// Modifica del periodo di validità (PA-6, `PATCH /diet-plans/{id}`),
/// dal menu della redazione dello schema (7.3 interfaccia.md). Le date
/// modificabili dipendono dallo stato, con la stessa regola del server,
/// qui solo anticipata: in Bozza e Programmato inizio e fine (CV-6), in
/// Attivo e Sospeso la sola fine. Restituisce il piano aggiornato, o
/// `null` se il dialogo è annullato.
Future<DietPlan?> showPlanPeriodDialog(BuildContext context, {required DietPlan plan}) {
  return showDialog<DietPlan>(context: context, builder: (_) => _PlanPeriodDialog(plan: plan));
}

class _PlanPeriodDialog extends ConsumerStatefulWidget {
  const _PlanPeriodDialog({required this.plan});

  final DietPlan plan;

  @override
  ConsumerState<_PlanPeriodDialog> createState() => _PlanPeriodDialogState();
}

class _PlanPeriodDialogState extends ConsumerState<_PlanPeriodDialog> {
  late DateTime _startDate = widget.plan.startDate;
  late DateTime? _endDate = widget.plan.endDate;
  late bool _indefinite = widget.plan.endDate == null;
  String? _startError;
  String? _endError;
  String? _formError;
  bool _saving = false;

  /// L'inizio di un piano già in vigore è storia (TR-8): resta visibile,
  /// ma non si modifica.
  bool get _startLocked =>
      widget.plan.status == PlanStatus.active || widget.plan.status == PlanStatus.suspended;

  DateTime get _tomorrow => dateOnly(DateTime.now()).add(const Duration(days: 1));

  /// Il Programmato inizia da domani in poi: anticiparlo a oggi è
  /// l'attivazione anticipata (CV-4), che ha una propria azione.
  DateTime get _firstStartDate => widget.plan.status == PlanStatus.scheduled ? _tomorrow : DateTime(2020);

  /// La fine non precede l'inizio, e su un piano in vigore cade dopo oggi:
  /// una fine odierna è la conclusione (CV-5), anch'essa con una propria
  /// azione.
  DateTime get _firstEndDate => _startLocked && _tomorrow.isAfter(_startDate) ? _tomorrow : _startDate;

  DateTime _atLeast(DateTime value, DateTime first) => value.isBefore(first) ? first : value;

  void _clearErrors() {
    _startError = null;
    _endError = null;
    _formError = null;
  }

  Future<void> _pickStartDate() async {
    final first = _firstStartDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: _atLeast(_startDate, first),
      firstDate: first,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      _clearErrors();
    });
  }

  Future<void> _pickEndDate() async {
    final first = _firstEndDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: _atLeast(_endDate ?? first, first),
      firstDate: first,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      _clearErrors();
    });
  }

  Future<void> _save() async {
    final endDate = _indefinite ? null : _endDate;
    setState(_clearErrors);
    if (!_indefinite && endDate == null) {
      setState(() => _endError = context.l10n.validationRequired);
      return;
    }
    if (endDate != null && endDate.isBefore(_startDate)) {
      setState(() => _endError = context.l10n.planPeriodEndBeforeStart);
      return;
    }
    setState(() => _saving = true);
    // Il PATCH riporta l'intero modulo: denominazione e note restano
    // quelle del piano.
    final request = UpdateDietPlanRequest(
      name: widget.plan.name,
      startDate: _startDate,
      endDate: endDate,
      notes: widget.plan.notes,
    );
    try {
      final updated =
          await ref.read(dietPlanScheduleControllerProvider(widget.plan.id).notifier).updateDetails(request);
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _showError(error);
      });
    }
  }

  void _showError(Object error) {
    final exception = error.asApiException;
    switch (exception?.code) {
      case 'PLAN_PERIOD_OVERLAP':
        _formError = describePlanOverlap(context, error);
      case 'VALIDATION_FAILED':
        final fields = (exception?.body as Map?)?['fields'] as List? ?? const [];
        for (final item in fields) {
          final field = (item as Map)['field'] as String?;
          final code = item['code'] as String?;
          if (field == 'startDate') {
            _startError = _describeFieldCode('startDate', code);
          } else if (field == 'endDate') {
            _endError = _describeFieldCode('endDate', code);
          }
        }
        if (_startError == null && _endError == null) {
          _formError = describeApiError(context, 'VALIDATION_FAILED');
        }
      default:
        _formError = describeApiError(context, exception?.code ?? '');
    }
  }

  String _describeFieldCode(String field, String? code) {
    final l10n = context.l10n;
    return switch (code) {
      'NOT_EDITABLE' => l10n.planPeriodStartLocked,
      'NOT_FUTURE' => field == 'startDate' ? l10n.planPeriodStartNotFuture : l10n.planPeriodEndNotFuture,
      'BEFORE_START_DATE' => l10n.planPeriodEndBeforeStart,
      'REQUIRED' => l10n.validationRequired,
      _ => l10n.validationInvalidValue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.planPeriodEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateField(
              label: context.l10n.planStartDate,
              value: _startDate,
              errorText: _startError,
              onTap: _startLocked || _saving ? null : _pickStartDate,
              formatter: (date) => formatDate(context, date),
            ),
            if (_startLocked) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(context.l10n.planPeriodStartLocked, style: typography.caption.copyWith(color: colors.textSecondary)),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(context.l10n.planOpenEnded, style: typography.bodyMedium.copyWith(color: colors.textPrimary)),
                ),
                Switch(
                  value: _indefinite,
                  activeThumbColor: colors.accent,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() {
                            _indefinite = value;
                            _clearErrors();
                          }),
                ),
              ],
            ),
            if (!_indefinite) ...[
              const SizedBox(height: AppSpacing.sm),
              DateField(
                label: context.l10n.planEndDate,
                value: _endDate,
                errorText: _endError,
                onTap: _saving ? null : _pickEndDate,
                formatter: (date) => formatDate(context, date),
              ),
            ],
            if (_formError != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(_formError!, style: typography.caption.copyWith(color: colors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(onPressed: _saving ? null : _save, child: Text(context.l10n.commonSave)),
      ],
    );
  }
}
