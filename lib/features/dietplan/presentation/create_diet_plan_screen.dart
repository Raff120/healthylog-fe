import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/diet_plan_requests.dart';
import '../domain/diet_plan_field_validators.dart';
import '../providers/diet_plan_providers.dart';

/// Creazione del piano da zero (7.2 interfaccia.md, CD-1, CD-4). La scelta
/// dell'origine (da zero / da template, CT-1) non compare: nessun
/// template esiste finché F09 non li introduce, quindi la seconda card
/// sarebbe sempre assente (7.2, "La seconda card è assente quando non si
/// possiedono template") — si passa direttamente ai dati. Il destinatario
/// (CD-2, riservato al Nutrizionista) e le note generali (PA-13, non
/// ancora accettate da `POST /diet-plans`) non compaiono per lo stesso
/// motivo di scope registrato in decisioni.md.
class CreateDietPlanScreen extends ConsumerStatefulWidget {
  const CreateDietPlanScreen({super.key});

  @override
  ConsumerState<CreateDietPlanScreen> createState() => _CreateDietPlanScreenState();
}

class _CreateDietPlanScreenState extends ConsumerState<CreateDietPlanScreen> {
  final _name = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _indefinite = true;
  bool _submitted = false;
  String? _overlapMessage;

  final Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _startDate = _nextMonday(DateTime.now());
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// 7.2 interfaccia.md: "Predefinita: il lunedì successivo" — il lunedì
  /// corrente se si compila oggi stesso di lunedì, altrimenti il primo a
  /// venire.
  DateTime _nextMonday(DateTime from) {
    final date = DateTime(from.year, from.month, from.day);
    final daysUntilMonday = (DateTime.monday - date.weekday + 7) % 7;
    return date.add(Duration(days: daysUntilMonday));
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _overlapMessage = null;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _overlapMessage = null;
      });
    }
  }

  bool _validate() {
    final errors = <String, String?>{
      'name': validatePlanName(_name.text),
      'startDate': _startDate == null ? 'REQUIRED' : null,
    };
    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
    });
    return errors.values.every((error) => error == null);
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _overlapMessage = null;
    });
    if (!_validate()) return;

    await ref.read(createDietPlanControllerProvider.notifier).create(
          CreateDietPlanRequest(
            name: _name.text.trim(),
            startDate: _startDate!,
            endDate: _indefinite ? null : _endDate,
          ),
        );

    final state = ref.read(createDietPlanControllerProvider);
    if (!mounted || state == null) return;
    state.whenOrNull(
      data: (plan) => context.pushReplacement('/diet-plans/${plan.id}/schedule'),
      error: (error, _) {
        final exception = error.asApiException;
        if (exception?.code == 'PLAN_PERIOD_OVERLAP') {
          final body = exception?.body as Map?;
          final conflictingName = body?['conflictingPlanName'] as String?;
          setState(() {
            _overlapMessage = conflictingName == null
                ? 'Il periodo si sovrappone a un piano esistente.'
                : 'Si sovrappone a "$conflictingName".';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(exception?.code ?? ''))),
          );
        }
      },
    );
  }

  String? _errorFor(String field) => _submitted ? _describeFieldError(_fieldErrors[field]) : null;

  String? _describeFieldError(String? code) {
    return switch (code) {
      null => null,
      'REQUIRED' => 'Campo obbligatorio',
      'TOO_LONG' => 'Troppo lungo',
      _ => 'Valore non valido',
    };
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final loading = ref.watch(createDietPlanControllerProvider)?.isLoading ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Nuovo piano', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(label: 'Denominazione', controller: _name, errorText: _errorFor('name')),
                  const SizedBox(height: AppSpacing.sm),
                  _DateField(
                    label: 'Data di inizio',
                    value: _startDate,
                    errorText: _errorFor('startDate'),
                    onTap: _pickStartDate,
                    formatter: _formatDate,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'A tempo indeterminato',
                          style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                        ),
                      ),
                      Switch(
                        value: _indefinite,
                        activeThumbColor: colors.accent,
                        onChanged: (value) => setState(() {
                          _indefinite = value;
                          _overlapMessage = null;
                        }),
                      ),
                    ],
                  ),
                  if (!_indefinite) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _DateField(
                      label: 'Data di fine',
                      value: _endDate,
                      errorText: null,
                      onTap: _pickEndDate,
                      formatter: _formatDate,
                    ),
                  ],
                  if (_overlapMessage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(_overlapMessage!, style: typography.caption.copyWith(color: colors.error)),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(label: 'Crea piano', loading: loading, onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo data generico (7.2 interfaccia.md), sul modello di `BirthDateField`
/// (identity/presentation/widgets): qui non promosso a widget condiviso,
/// le due sole occorrenze restano in questa schermata.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.errorText,
    required this.onTap,
    required this.formatter,
  });

  final String label;
  final DateTime? value;
  final String? errorText;
  final VoidCallback onTap;
  final String Function(DateTime) formatter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: AppSpacing.heightTextField,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: hasError ? colors.error : colors.dividerStrong),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value == null ? label : formatter(value!),
              style: typography.bodyLarge.copyWith(
                color: value == null ? colors.textSecondary : colors.textPrimary,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(errorText!, style: typography.caption.copyWith(color: colors.error)),
        ],
      ],
    );
  }
}
