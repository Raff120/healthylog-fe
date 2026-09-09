import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../providers/workout_providers.dart';

/// Impostazione dell'obiettivo settimanale (OS-9: dalla sezione dedicata
/// agli allenamenti, non altrove).
///
/// OS-1, OS-4: un numero di sessioni, senza distinzione per tipo di
/// attività. OS-10: nessun avanzamento è presentato qui. OS-14: il
/// sistema non propone valori né ne raccomanda l'adeguamento.
Future<void> showWeeklyGoalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _WeeklyGoalSheet(),
  );
}

class _WeeklyGoalSheet extends ConsumerStatefulWidget {
  const _WeeklyGoalSheet();

  @override
  ConsumerState<_WeeklyGoalSheet> createState() => _WeeklyGoalSheetState();
}

class _WeeklyGoalSheetState extends ConsumerState<_WeeklyGoalSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(weeklyWorkoutGoalProvider).value?.toString() ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save(int? value) async {
    await ref.read(weeklyWorkoutGoalProvider.notifier).save(value);
    if (!mounted) return;
    if (ref.read(weeklyWorkoutGoalProvider).hasError) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final saving = ref.watch(weeklyWorkoutGoalProvider).isLoading;
    final current = ref.watch(weeklyWorkoutGoalProvider).value;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.workoutWeeklyGoal,
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xxs),
                // OS-2: obiettivo e pianificazione possono divergere, e il
                // sistema non li allinea.
                Text(
                  context.l10n.workoutWeeklyGoalHelp,
                  style: typography.caption.copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: context.l10n.workoutPerWeek,
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: context.l10n.commonSave,
                  loading: saving,
                  onPressed: () {
                    final value = int.tryParse(_controller.text.trim());
                    if (value == null || value <= 0) return;
                    _save(value);
                  },
                ),
                // OS-5, DS-11: la rimozione è un'azione esplicita; le
                // settimane trascorse conservano l'obiettivo allora vigente.
                if (current != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: saving ? null : () => _save(null),
                    child: Text(context.l10n.workoutRemoveGoal),
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
