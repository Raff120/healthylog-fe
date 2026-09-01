import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../data/plan_status.dart';
import '../providers/diet_plan_providers.dart';
import 'diet_plan_management_screen.dart' show planPeriodLabel;
import 'widgets/day_preview.dart';
import 'widgets/delete_plan_dialog.dart';

/// Dettaglio di un piano Concluso (7.5 interfaccia.md, ST-7): sola
/// lettura, ridotta alla sola composizione dell'intestazione e dello
/// schema settimanale — periodi, statistiche e storico delle inversioni
/// restano a F27, che costruirà per intero questa schermata. L'unica
/// operazione qui presente è l'eliminazione (CV-10); riattivazione
/// (CV-7) e salvataggio come template (TP-5), pure ammesse da ST-7,
/// sono rinviate insieme al resto (deciso con l'utente, vedi
/// decisioni.md).
class DietPlanViewScreen extends ConsumerWidget {
  const DietPlanViewScreen({super.key, required this.planId});

  final String planId;

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDeletePlan(context, PlanStatus.completed);
    if (!confirmed) return;
    if (!context.mounted) return;
    await ref.read(dietPlanLifecycleControllerProvider.notifier).delete(planId);
    if (!context.mounted) return;
    final state = ref.read(dietPlanLifecycleControllerProvider);
    state?.whenOrNull(
      data: (_) => context.pushReplacement('/profile/plans'),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final planState = ref.watch(dietPlanScheduleControllerProvider(planId));
    ref.watch(dietPlanLifecycleControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          planState.value?.name ?? 'Piano concluso',
          style: typography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        actions: [
          if (planState.value != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _delete(context, ref);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'delete', child: Text('Elimina', style: TextStyle(color: colors.error))),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: planState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (plan) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('CONCLUSO', style: typography.overline.copyWith(color: colors.textTertiary)),
              const SizedBox(height: AppSpacing.xxs),
              Text(planPeriodLabel(plan, _formatDate), style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              for (final day in plan.weeklySchedule) DayPreview(day: day),
            ],
          ),
        ),
      ),
    );
  }
}
