import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/workout_models.dart';
import '../../data/workout_requests.dart';
import '../../providers/workout_providers.dart';
import 'workout_confirmations.dart';

/// Registrazione e modifica di un allenamento (10.2 interfaccia.md).
///
/// Un solo foglio per i tre punti di accesso: quello **completo** —
/// pulsante mobile di *Attività* o di *Piano* (RA-4) — quello **ridotto**
/// della spunta di un allenamento previsto, che eredita il tipo dalla
/// pianificazione e presenta i soli campi facoltativi (AL-13, RA-3), e la
/// modifica dall'elenco (RA-15).
Future<void> showWorkoutSheet(
  BuildContext context, {
  DateTime? date,
  Workout? existing,
  PlannedWorkout? planned,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _WorkoutSheet(
      date: date ?? existing?.date ?? DateTime.now(),
      existing: existing,
      planned: planned,
    ),
  );
}

class _WorkoutSheet extends ConsumerStatefulWidget {
  const _WorkoutSheet({required this.date, this.existing, this.planned});

  final DateTime date;
  final Workout? existing;

  /// AL-13: valorizzata dalla spunta di un allenamento previsto — il
  /// foglio si riduce ai campi facoltativi.
  final PlannedWorkout? planned;

  @override
  ConsumerState<_WorkoutSheet> createState() => _WorkoutSheetState();
}

class _WorkoutSheetState extends ConsumerState<_WorkoutSheet> {
  late final _activityTypeController =
      TextEditingController(text: widget.existing?.activityType ?? '');
  // CB-2: il campo delle calorie è presentato sempre vuoto in
  // registrazione; in modifica riporta il valore già registrato (CB-4).
  late final _caloriesController =
      TextEditingController(text: widget.existing?.caloriesBurned?.toString() ?? '');
  late final _noteController = TextEditingController(text: widget.existing?.note ?? '');
  late DateTime _date = _dateOnly(widget.date);
  String? _activityTypeError;

  bool get _isReduced => widget.planned != null;
  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _activityTypeController.dispose();
    _caloriesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// RA-6: il selettore non consente date successive a oggi — ciò che si
  /// prevede di fare si esprime con la pianificazione, non con la
  /// registrazione.
  Future<void> _pickDate() async {
    final today = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2000),
      lastDate: today,
      helpText: 'Quando lo hai svolto',
    );
    if (picked != null) setState(() => _date = _dateOnly(picked));
  }

  Future<void> _submit() async {
    final activityType = _activityTypeController.text.trim();
    if (!_isReduced && activityType.isEmpty) {
      setState(() => _activityTypeError = 'Indica il tipo di attività');
      return;
    }
    // CB-1: l'omissione delle calorie non è segnalata né impedisce il
    // salvataggio; un testo non numerico equivale all'assenza del valore.
    final calories = int.tryParse(_caloriesController.text.trim());
    final note = _noteController.text.trim();

    final controller = ref.read(workoutControllerProvider.notifier);
    if (_isEdit) {
      await controller.update(
        widget.existing!.id,
        UpdateWorkoutRequest(
          date: _date,
          activityType: activityType,
          caloriesBurned: calories,
          note: note.isEmpty ? null : note,
        ),
      );
    } else {
      // AL-6, RA-9: la registrazione di un secondo allenamento nella
      // medesima giornata è preceduta dalla conferma che mostra quello già
      // registrato. La spunta di un allenamento previsto ne è esclusa:
      // l'Utente sta dichiarando di aver svolto proprio quello (AL-13).
      if (!_isReduced && !await _confirmDuplicateIfNeeded()) return;
      await controller.create(
        CreateWorkoutRequest(
          date: _date,
          activityType: _isReduced ? null : activityType,
          caloriesBurned: calories,
          note: note.isEmpty ? null : note,
          plannedWorkoutId: widget.planned?.id,
        ),
      );
    }
    if (!mounted) return;
    final state = ref.read(workoutControllerProvider);
    if (state?.hasError ?? false) return;
    Navigator.of(context).pop();
  }

  Future<bool> _confirmDuplicateIfNeeded() async {
    final sameDay = await ref.read(workoutApiProvider).listByDate(_date);
    if (sameDay.isEmpty || !mounted) return true;
    return confirmDuplicateWorkout(context, existing: sameDay);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final saving = ref.watch(workoutControllerProvider)?.isLoading ?? false;

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
                  _isEdit
                      ? 'Modifica allenamento'
                      : _isReduced
                          ? widget.planned!.activityType
                          : 'Registra un allenamento',
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
                if (_isReduced) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  // RA-3: l'integrazione resta possibile ma non obbligatoria.
                  Text(
                    'Se vuoi, aggiungi calorie e nota. Puoi anche chiudere: l\'allenamento è registrato lo stesso.',
                    style: typography.caption.copyWith(color: colors.textTertiary),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                if (!_isReduced) ...[
                  _DateField(date: _date, onTap: _pickDate),
                  const SizedBox(height: AppSpacing.sm),
                  _ActivityTypeField(
                    controller: _activityTypeController,
                    errorText: _activityTypeError,
                    onChanged: (_) {
                      if (_activityTypeError != null) setState(() => _activityTypeError = null);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AppTextField(
                  label: 'Calorie bruciate',
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: AppSpacing.xxs),
                // 10.2 interfaccia.md, CB-2: nessun valore predefinito né
                // suggerito, neppure dagli allenamenti precedenti dello
                // stesso tipo.
                Text(
                  'Se lo sai. Non è obbligatorio.',
                  style: typography.caption.copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Nota',
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: _isEdit ? 'Salva' : 'Registra',
                  loading: saving,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// RA-5, RA-7: predefinita la data corrente, modificabile verso il passato.
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
              formatWorkoutDate(date),
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// AL-2: campo di testo con i suggerimenti dai tipi già impiegati — la
/// coerenza dei dati è favorita, non imposta: il testo resta libero.
class _ActivityTypeField extends ConsumerWidget {
  const _ActivityTypeField({
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(workoutActivityTypesProvider).value ?? const <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Tipo di attività',
          controller: controller,
          errorText: errorText,
          textCapitalization: TextCapitalization.sentences,
          onChanged: onChanged,
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              for (final suggestion in suggestions.take(6))
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    controller.text = suggestion;
                    onChanged(suggestion);
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Data breve, nel formato italiano già impiegato altrove; la
/// localizzazione dei formati resta a F29 (LO-9).
String formatWorkoutDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}
