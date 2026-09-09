import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../care/domain/plan_competence.dart';
import '../../care/providers/care_providers.dart';
import '../data/diet_plan.dart';
import '../data/plan_status.dart';
import '../domain/current_diet_plan.dart';
import '../providers/diet_plan_providers.dart';
import 'widgets/delete_plan_dialog.dart';

/// Gestione dei piani (7.1 interfaccia.md, raggiunta da Profilo → Piani):
/// la card del piano in corso (Attivo, Sospeso o il prossimo Programmato,
/// PA-8) con le azioni di stato di F10 (CV-2, AS-11, CV-4, CV-S1, CV-S6,
/// CV-5, MD-1), seguita dalle voci compatte degli altri piani — Bozza,
/// altri Programmato (PA-9) e Conclusi. Pulsante di creazione sempre
/// presente salvo che per il Paziente (7.1: "Il pulsante è assente al
/// Paziente", UT-8, F22), a cui non compaiono nemmeno le azioni sul
/// piano redatto dal proprio Nutrizionista (TR-17) — la card lo indica
/// con "Redatto da [Nome]".
///
/// L'eliminazione (CV-10, CV-11) è offerta qui solo dalla card, per il
/// Sospeso — mai per l'Attivo, che CV-11 esclude. Non compare invece
/// sulle voci compatte, dove il tocco che apre il piano l'avrebbe resa
/// troppo facile da premere per errore (segnalato dall'utente, vedi
/// decisioni.md): per Bozza, Programmato e Concluso resta raggiungibile
/// dal menu della schermata che il tocco apre, redazione o
/// (`DietPlanViewScreen`) la vista di sola lettura del Concluso — la cui
/// riattivazione (CV-7) resta comunque a F27, che la costruirà per
/// intero.
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
  Future<void> _editScheduled(BuildContext context, WidgetRef ref, String planId) async {
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

  /// MD-1: un piano Attivo o Sospeso si modifica direttamente, senza
  /// alcuna transizione di stato — a differenza del Programmato, resta
  /// esattamente nello stesso stato mentre lo si redige.
  void _editInPlace(BuildContext context, String planId) => context.push('/diet-plans/$planId/schedule');

  /// CV-10: mai proposta per l'Attivo (CV-11 la esclude a monte, nessun
  /// chiamante la offre in quel caso).
  Future<void> _delete(BuildContext context, WidgetRef ref, String planId, PlanStatus status) async {
    final confirmed = await confirmDeletePlan(context, status);
    if (!confirmed) return;
    if (!context.mounted) return;
    await _act(context, ref, () => ref.read(dietPlanLifecycleControllerProvider.notifier).delete(planId));
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
    final listState = ref.watch(ownedDietPlansProvider);
    final acting = ref.watch(dietPlanLifecycleControllerProvider)?.isLoading ?? false;
    // UT-8, F22: il collegamento vigente decide le facoltà sul piano.
    final careLink = ref.watch(currentCareLinkOrNullProvider);
    final canCreate = canCreateOwnPlan(careLink);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Piani', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      // 7.1 interfaccia.md: "Pulsante mobile in basso a destra", sempre
      // presente — non solo nello stato vuoto.
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push('/diet-plans/new'),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: listState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (plans) {
            if (plans.isEmpty && !canCreate) {
              // 7.1 interfaccia.md: "Per il Paziente privo di piani assegnati,
              // la constatazione neutra che il nutrizionista non ne ha
              // ancora redatti, senza azione".
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Il tuo nutrizionista non ha ancora redatto un piano.',
                    style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (plans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Inizia da qui', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
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

            final current = findCurrentPlan(plans);
            final others = plans.where((plan) => plan.id != current?.id).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
              children: [
                if (current != null) ...[
                  _CurrentPlanCard(
                    plan: current,
                    acting: acting,
                    locked: isPlanLockedForPatient(current, careLink),
                    authorName: current.authorId == careLink?.nutritionistId ? careLink?.nutritionistName : null,
                    formatDate: _formatDate,
                    onSuspend: () => _suspend(context, ref, current.id),
                    onResume: () => _resume(context, ref, current.id),
                    onComplete: () => _complete(context, ref, current.id),
                    onWithdraw: () => _withdraw(context, ref, current.id),
                    onActivateNow: () => _activateNow(context, ref, current.id),
                    onEditScheduled: () => _editScheduled(context, ref, current.id),
                    onEditInPlace: () => _editInPlace(context, current.id),
                    onDelete: () => _delete(context, ref, current.id, current.status),
                  ),
                  if (others.isNotEmpty) const SizedBox(height: AppSpacing.md),
                ],
                for (final plan in others)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _OtherPlanTile(
                      plan: plan,
                      formatDate: _formatDate,
                      // UT-8: il piano bloccato si apre in sola lettura, come il Concluso.
                      onTap: () => context.push(
                          plan.status == PlanStatus.completed || isPlanLockedForPatient(plan, careLink)
                              ? '/diet-plans/${plan.id}'
                              : '/diet-plans/${plan.id}/schedule'),
                    ),
                  ),
              ],
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
    required this.locked,
    required this.authorName,
    required this.formatDate,
    required this.onSuspend,
    required this.onResume,
    required this.onComplete,
    required this.onWithdraw,
    required this.onActivateNow,
    required this.onEditScheduled,
    required this.onEditInPlace,
    required this.onDelete,
  });

  final DietPlan plan;
  final bool acting;

  /// UT-8, TR-17: redatto dal proprio Nutrizionista — nessuna azione.
  final bool locked;

  /// 7.1 interfaccia.md: "Redatto da [Nome]" se di un Nutrizionista.
  final String? authorName;
  final String Function(DateTime) formatDate;
  final VoidCallback onSuspend;
  final VoidCallback onResume;
  final VoidCallback onComplete;
  final VoidCallback onWithdraw;
  final VoidCallback onActivateNow;
  final VoidCallback onEditScheduled;
  final VoidCallback onEditInPlace;
  final VoidCallback onDelete;

  String get _statusLabel => switch (plan.status) {
        PlanStatus.active => 'In corso',
        PlanStatus.suspended => 'Sospeso',
        PlanStatus.scheduled => 'Programmato',
        _ => '',
      };

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
          Text(planPeriodLabel(plan, formatDate), style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
          if (authorName != null && authorName!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text('Redatto da $authorName', style: typography.caption.copyWith(color: colors.textTertiary)),
          ],
          if (locked) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Il contenuto del piano è a cura del tuo nutrizionista: puoi spuntare e invertire i pasti.',
              style: typography.caption.copyWith(color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final action in locked ? const <_PlanAction>[] : _actionsFor(plan.status))
                OutlinedButton(
                  onPressed: acting ? null : action.onPressed,
                  style: action.destructive
                      ? OutlinedButton.styleFrom(foregroundColor: colors.error, side: BorderSide(color: colors.error))
                      : null,
                  child: Text(action.label),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// MD-1: Attivo e Sospeso si modificano ora direttamente (`onEditInPlace`),
  /// non solo il Programmato (`onEditScheduled`, via ritiro). CV-10:
  /// "Elimina" compare solo per il Sospeso — mai per l'Attivo (CV-11).
  List<_PlanAction> _actionsFor(PlanStatus status) => switch (status) {
        PlanStatus.active => [
            _PlanAction('Modifica', onEditInPlace),
            _PlanAction('Sospendi', onSuspend),
            _PlanAction('Concludi', onComplete),
          ],
        PlanStatus.suspended => [
            _PlanAction('Modifica', onEditInPlace),
            _PlanAction('Riprendi', onResume),
            _PlanAction('Concludi', onComplete),
            _PlanAction('Elimina', onDelete, destructive: true),
          ],
        PlanStatus.scheduled => [
            _PlanAction('Modifica', onEditScheduled),
            _PlanAction('Ritira', onWithdraw),
            _PlanAction('Attiva ora', onActivateNow),
          ],
        _ => const [],
      };
}

class _PlanAction {
  const _PlanAction(this.label, this.onPressed, {this.destructive = false});

  final String label;
  final VoidCallback onPressed;
  final bool destructive;
}

/// Voce compatta di un piano diverso da quello in corso (7.1
/// interfaccia.md, "Voci dell'elenco"): una Bozza da riprendere, un altro
/// Programmato oltre al più vicino (PA-9), o un piano Concluso. Il tocco
/// apre la redazione per Bozza/Programmato, la vista di sola lettura per
/// il Concluso; per un Programmato ulteriore non esiste ancora
/// un'anteprima dedicata (assente da 7.1 per questo caso, non ancora
/// incontrato in pratica), apre comunque la redazione.
///
/// Nessun pulsante di eliminazione qui: accostato al tocco che apre il
/// piano, il rischio di premerlo per errore era troppo alto (segnalato
/// dall'utente, vedi decisioni.md). Resta raggiungibile dal menu della
/// schermata che il tocco apre — redazione per Bozza/Programmato, vista
/// di sola lettura per il Concluso — mai qui.
class _OtherPlanTile extends StatelessWidget {
  const _OtherPlanTile({required this.plan, required this.formatDate, required this.onTap});

  final DietPlan plan;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  String get _statusLabel => switch (plan.status) {
        PlanStatus.draft => 'Bozza',
        PlanStatus.scheduled => 'Programmato',
        PlanStatus.completed => 'Concluso',
        _ => '',
      };

  Color _dotColor(BuildContext context) {
    final colors = context.colors;
    // 7.1 interfaccia.md: accento se Programmato, terziario se Concluso
    // — per la Bozza, non prevista lì, si usa lo stesso terziario per
    // non introdurre un terzo significato cromatico non documentato.
    return plan.status == PlanStatus.scheduled ? colors.accent : colors.textTertiary;
  }

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
                decoration: BoxDecoration(color: _dotColor(context), shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                    Text(
                      '$_statusLabel · ${planPeriodLabel(plan, formatDate)}',
                      style: typography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              // ST-2, 7.1: l'aderenza come numero puro in colore primario,
              // senza colorazione di merito né barra di avanzamento
              // (AD-15). Non compare per i Programmati, dove non esiste, né
              // per quello in corso, la cui collocazione sono le statistiche.
              if (plan.adherence != null) ...[
                Text(
                  '${plan.adherence!.round()}%',
                  style: typography.label.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Icon(Icons.chevron_right, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

String planPeriodLabel(DietPlan plan, String Function(DateTime) formatDate) {
  final start = formatDate(plan.startDate);
  if (plan.endDate == null) return 'Dal $start';
  return '$start – ${formatDate(plan.endDate!)}';
}
