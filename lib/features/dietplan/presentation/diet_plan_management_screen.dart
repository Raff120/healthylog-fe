import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../data/diet_plan.dart';
import '../data/plan_status.dart';
import '../providers/diet_plan_providers.dart';

/// Gestione del piano in corso (7.1 interfaccia.md, raggiunta da Profilo
/// → Piani): la card del piano Attivo, Sospeso o Programmato, con le
/// azioni di stato di F10 (CV-2, AS-11, CV-4, CV-S1, CV-S6, CV-5).
///
/// Non compare qui — assente dallo scopo di questa feature, vedi
/// decisioni.md — l'elenco dei piani conclusi (ST-1, ST-2, F27, che
/// dipende dall'aderenza di F25) né alcuna Bozza non ancora confermata
/// (7.1 non la prevede fra gli stati della card; resta raggiungibile
/// solo nella sessione in cui è stata creata, F08).
class DietPlanManagementScreen extends ConsumerWidget {
  const DietPlanManagementScreen({super.key});

  Future<bool> _confirmSimple(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// CV-S1, CV-S6, CV-4: reversibili, nessuna conferma (4.5 interfaccia.md).
  Future<void> _suspend(BuildContext context, WidgetRef ref, String planId) =>
      _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).suspend(planId));

  Future<void> _resume(BuildContext context, WidgetRef ref, String planId) =>
      _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).resume(planId));

  Future<void> _activateNow(BuildContext context, WidgetRef ref, String planId) =>
      _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).activate(planId));

  /// CV-5: "Concludere un piano attivo" — conferma semplice (4.5 interfaccia.md).
  Future<void> _complete(BuildContext context, WidgetRef ref, String planId) async {
    final confirmed = await _confirmSimple(
      context,
      title: 'Concludere il piano?',
      message: 'Potrai sempre riattivarlo in seguito.',
      confirmLabel: 'Concludi',
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).complete(planId));
  }

  /// AS-11: "Ritirare un piano programmato" — conferma semplice.
  Future<void> _withdraw(BuildContext context, WidgetRef ref, String planId) async {
    final confirmed = await _confirmSimple(
      context,
      title: 'Ritirare il piano?',
      message: 'Tornerà in Bozza: potrai riprenderlo dalla redazione.',
      confirmLabel: 'Ritira',
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).withdraw(planId));
  }

  /// CV-6: la modifica di un piano Programmato passa dal ritiro (nessun
  /// altro meccanismo la consente sul backend), ma qui l'intento è
  /// proseguire subito nella redazione, non restare nello stato
  /// ritirato: nessuna conferma propria, a differenza di "Ritira" da
  /// sola (4.5 interfaccia.md la riserva a quell'azione).
  Future<void> _edit(BuildContext context, WidgetRef ref, String planId) async {
    await ref.read(dietPlanLifecycleControllerProvider.notifier).withdraw(planId);
    if (!context.mounted) return;
    final state = ref.read(dietPlanLifecycleControllerProvider);
    if (state?.hasError ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(state?.error?.asApiException?.code ?? ''))),
      );
      return;
    }
    context.push('/diet-plans/$planId/schedule');
  }

  Future<void> _act(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    await action();
    if (!context.mounted) return;
    final state = ref.read(dietPlanLifecycleControllerProvider);
    state?.whenOrNull(
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final planState = ref.watch(currentDietPlanProvider);
    final acting = ref.watch(dietPlanLifecycleControllerProvider)?.isLoading ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Piani', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
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
          data: (plan) {
            if (plan == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Inizia da qui',
                        style: typography.titleMedium.copyWith(color: colors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Non hai ancora un piano alimentare.',
                        style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: 200,
                        child: AppPrimaryButton(
                          label: 'Crea piano',
                          onPressed: () => context.push('/diet-plans/new'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _CurrentPlanCard(
                plan: plan,
                acting: acting,
                formatDate: _formatDate,
                onSuspend: () => _suspend(context, ref, plan.id),
                onResume: () => _resume(context, ref, plan.id),
                onComplete: () => _complete(context, ref, plan.id),
                onWithdraw: () => _withdraw(context, ref, plan.id),
                onActivateNow: () => _activateNow(context, ref, plan.id),
                onEdit: () => _edit(context, ref, plan.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Card del piano in corso (7.1 interfaccia.md): etichetta di stato,
/// denominazione, periodo, azioni secondo lo stato.
class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.plan,
    required this.acting,
    required this.formatDate,
    required this.onSuspend,
    required this.onResume,
    required this.onComplete,
    required this.onWithdraw,
    required this.onActivateNow,
    required this.onEdit,
  });

  final DietPlan plan;
  final bool acting;
  final String Function(DateTime) formatDate;
  final VoidCallback onSuspend;
  final VoidCallback onResume;
  final VoidCallback onComplete;
  final VoidCallback onWithdraw;
  final VoidCallback onActivateNow;
  final VoidCallback onEdit;

  String get _statusLabel => switch (plan.status) {
        PlanStatus.active => 'In corso',
        PlanStatus.suspended => 'Sospeso',
        PlanStatus.scheduled => 'Programmato',
        _ => '',
      };

  String get _period {
    final start = formatDate(plan.startDate);
    if (plan.endDate == null) return 'Dal $start';
    return '$start – ${formatDate(plan.endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusLabel.toUpperCase(), style: typography.overline.copyWith(color: colors.accent)),
          const SizedBox(height: AppSpacing.xxs),
          Text(plan.name, style: typography.titleLarge.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.xxs),
          Text(_period, style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final action in _actionsFor(plan.status))
                OutlinedButton(
                  onPressed: acting ? null : action.onPressed,
                  child: Text(action.label),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<_PlanAction> _actionsFor(PlanStatus status) => switch (status) {
        PlanStatus.active => [
            _PlanAction('Sospendi', onSuspend),
            _PlanAction('Concludi', onComplete),
          ],
        PlanStatus.suspended => [
            _PlanAction('Riprendi', onResume),
            _PlanAction('Concludi', onComplete),
          ],
        PlanStatus.scheduled => [
            _PlanAction('Modifica', onEdit),
            _PlanAction('Ritira', onWithdraw),
            _PlanAction('Attiva ora', onActivateNow),
          ],
        _ => const [],
      };
}

class _PlanAction {
  const _PlanAction(this.label, this.onPressed);

  final String label;
  final VoidCallback onPressed;
}
