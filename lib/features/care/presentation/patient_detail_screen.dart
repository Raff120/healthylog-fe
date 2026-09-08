import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../dietplan/data/plan_status.dart';
import '../../dietplan/domain/plan_day_date.dart';
import '../../dietplan/providers/diet_plan_providers.dart';
import '../data/care_models.dart';
import '../providers/care_providers.dart';
import 'widgets/care_confirmations.dart';

/// Dettaglio del Paziente (9.2 interfaccia.md; VA-7, NU-2, NU-6):
/// intestazione con nome e data del collegamento, card del piano in
/// corso redatto dal Nutrizionista con le azioni di stato (7.1), gli
/// altri piani da lui redatti, e le azioni di creazione, modifica di
/// una giornata (MD-8) e revoca (CP-14, CP-18). Se il Paziente segue
/// un piano redatto da altri, la sezione presenta il solo "Crea piano",
/// senza alcun riferimento al piano esistente (ST-16, VA-3).
///
/// Statistiche e misurazioni (9.2) arrivano con F24/F25.
class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patientId, this.embedded = false});

  final String patientId;

  /// 3.3 interfaccia.md: incorporata a destra dell'elenco su `expanded`
  /// e oltre — senza barra dell'applicazione propria.
  final bool embedded;

  Future<void> _revoke(BuildContext context, WidgetRef ref, PatientDetail patient) async {
    final confirmed = await confirmRevokeCareLink(context, asNutritionist: true);
    if (!confirmed || !context.mounted) return;
    await ref.read(revokeCareLinkControllerProvider.notifier).revoke(patient.careLinkId);
    if (!context.mounted) return;
    final state = ref.read(revokeCareLinkControllerProvider);
    state?.whenOrNull(
      data: (_) {
        if (!embedded && context.canPop()) context.pop();
      },
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
      ),
    );
  }

  Future<void> _act(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    await action();
    if (!context.mounted) return;
    ref.read(dietPlanLifecycleControllerProvider)?.whenOrNull(
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
          ),
        );
  }

  Future<bool> _confirmSimple(BuildContext context, {required String title, required String message, required String confirmLabel}) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(confirmLabel)),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// MD-8, MD-11: scelta esplicita della giornata da modificare, distinta
  /// dalla modifica dello schema (MD-1) offerta dalla card del piano.
  Future<void> _editDay(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Giornata da modificare',
    );
    if (picked == null || !context.mounted) return;
    context.push('/plan-days/${isoDate(picked)}/edit?userId=$patientId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final state = ref.watch(patientDetailControllerProvider(patientId));
    final acting = ref.watch(dietPlanLifecycleControllerProvider)?.isLoading ?? false;
    // Tiene vivo il controller autoDispose per la durata della revoca.
    ref.watch(revokeCareLinkControllerProvider);

    final body = state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          describeApiError(error.asApiException?.code ?? ''),
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ),
      data: (patient) {
        final current = _currentPlan(patient.plans);
        final others = patient.plans.where((plan) => plan.id != current?.id).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.surfaceAlt,
                  child: Icon(Icons.person_outline, color: colors.textSecondary, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.fullName, style: typography.titleLarge.copyWith(color: colors.textPrimary)),
                      Text(
                        'Collegato dal ${_formatDate(patient.linkedAt)}',
                        style: typography.caption.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('PIANO IN CORSO', style: typography.overline.copyWith(color: colors.textTertiary)),
            const SizedBox(height: AppSpacing.xs),
            if (current == null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nessun piano in corso redatto da te.',
                      style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppPrimaryButton(
                      label: 'Crea piano',
                      onPressed: () => context.push('/diet-plans/new?patientId=$patientId'),
                    ),
                  ],
                ),
              )
            else
              _PatientPlanCard(
                plan: current,
                acting: acting,
                onEdit: () => current.status == PlanStatus.scheduled
                    ? _act(context, ref, () async {
                        await ref.read(dietPlanLifecycleControllerProvider.notifier).withdraw(current.id);
                        if (!context.mounted) return;
                        if (ref.read(dietPlanLifecycleControllerProvider)?.hasError ?? false) return;
                        context.push('/diet-plans/${current.id}/schedule');
                      })
                    : context.push('/diet-plans/${current.id}/schedule'),
                onSuspend: () => _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).suspend(current.id)),
                onResume: () => _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).resume(current.id)),
                onComplete: () async {
                  final confirmed = await _confirmSimple(context,
                      title: 'Concludere il piano?', message: 'Potrai sempre riattivarlo in seguito.', confirmLabel: 'Concludi');
                  if (!confirmed || !context.mounted) return;
                  await _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).complete(current.id));
                },
                onWithdraw: () async {
                  final confirmed = await _confirmSimple(context,
                      title: 'Ritirare il piano?', message: 'Il paziente non lo vedrà più.', confirmLabel: 'Ritira');
                  if (!confirmed || !context.mounted) return;
                  await _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).withdraw(current.id));
                },
                onActivateNow: () => _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).activate(current.id)),
                onEditDay: current.status == PlanStatus.active ? () => _editDay(context) : null,
              ),
            if (others.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('ALTRI PIANI REDATTI', style: typography.overline.copyWith(color: colors.textTertiary)),
              const SizedBox(height: AppSpacing.xs),
              for (final plan in others)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _PlanTile(
                    plan: plan,
                    onTap: () => context.push(
                      plan.status == PlanStatus.completed ? '/diet-plans/${plan.id}' : '/diet-plans/${plan.id}/schedule',
                    ),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (current != null)
              Center(
                child: TextButton(
                  onPressed: () => context.push('/diet-plans/new?patientId=$patientId'),
                  child: const Text('Crea un nuovo piano'),
                ),
              ),
            Center(
              child: TextButton(
                onPressed: () => _revoke(context, ref, patient),
                child: Text('Revoca il collegamento', style: TextStyle(color: colors.error)),
              ),
            ),
          ],
        );
      },
    );

    if (embedded) return body;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(state.value?.fullName ?? 'Paziente', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(child: body),
    );
  }

  /// PA-8: il piano "in corso" tra quelli redatti dal Nutrizionista —
  /// la stessa priorità di `findCurrentPlan`, sul solo sottoinsieme che
  /// egli ha titolo di conoscere (VA-3).
  static PatientPlanSummary? _currentPlan(List<PatientPlanSummary> plans) {
    for (final status in [PlanStatus.active, PlanStatus.suspended]) {
      for (final plan in plans) {
        if (plan.status == status) return plan;
      }
    }
    PatientPlanSummary? nearest;
    for (final plan in plans) {
      if (plan.status != PlanStatus.scheduled) continue;
      if (nearest == null || plan.startDate.isBefore(nearest.startDate)) nearest = plan;
    }
    return nearest;
  }
}

/// Card del piano in corso (7.1 interfaccia.md, riusata da 9.2): le
/// azioni sono quelle di chi ha titolo di disporne — qui il
/// Nutrizionista sui piani da lui redatti (NU-2, NU-6).
class _PatientPlanCard extends StatelessWidget {
  const _PatientPlanCard({
    required this.plan,
    required this.acting,
    required this.onEdit,
    required this.onSuspend,
    required this.onResume,
    required this.onComplete,
    required this.onWithdraw,
    required this.onActivateNow,
    required this.onEditDay,
  });

  final PatientPlanSummary plan;
  final bool acting;
  final VoidCallback onEdit;
  final VoidCallback onSuspend;
  final VoidCallback onResume;
  final VoidCallback onComplete;
  final VoidCallback onWithdraw;
  final VoidCallback onActivateNow;
  final VoidCallback? onEditDay;

  String get _statusLabel => switch (plan.status) {
        PlanStatus.active => 'In corso',
        PlanStatus.suspended => 'Sospeso',
        PlanStatus.scheduled => 'Programmato',
        _ => '',
      };

  List<(String, VoidCallback)> get _actions => switch (plan.status) {
        PlanStatus.active => [('Modifica', onEdit), ('Sospendi', onSuspend), ('Concludi', onComplete)],
        PlanStatus.suspended => [('Modifica', onEdit), ('Riprendi', onResume), ('Concludi', onComplete)],
        PlanStatus.scheduled => [('Modifica', onEdit), ('Ritira', onWithdraw), ('Attiva ora', onActivateNow)],
        _ => const [],
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusLabel.toUpperCase(), style: typography.overline.copyWith(color: colors.accent)),
          const SizedBox(height: AppSpacing.xxs),
          Text(plan.name, style: typography.titleLarge.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.xxs),
          Text(_periodLabel(plan), style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final (label, action) in _actions)
                OutlinedButton(onPressed: acting ? null : action, child: Text(label)),
              if (onEditDay != null)
                OutlinedButton.icon(
                  onPressed: acting ? null : onEditDay,
                  icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                  label: const Text('Modifica una giornata'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan, required this.onTap});

  final PatientPlanSummary plan;
  final VoidCallback onTap;

  String get _statusLabel => switch (plan.status) {
        PlanStatus.draft => 'Bozza',
        PlanStatus.scheduled => 'Programmato',
        PlanStatus.completed => 'Concluso',
        PlanStatus.active => 'In corso',
        PlanStatus.suspended => 'Sospeso',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: plan.status == PlanStatus.scheduled ? colors.accent : colors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                    Text('$_statusLabel · ${_periodLabel(plan)}', style: typography.caption.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

String _periodLabel(PatientPlanSummary plan) {
  final start = _formatDate(plan.startDate);
  if (plan.endDate == null) return 'Dal $start';
  return '$start – ${_formatDate(plan.endDate!)}';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}
