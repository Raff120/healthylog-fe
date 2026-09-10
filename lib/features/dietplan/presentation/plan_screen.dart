import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_breakpoints.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';
import '../../care/domain/plan_competence.dart';
import '../../group/providers/cooking_group_providers.dart';
import '../../notification/presentation/widgets/notification_bell.dart';
import '../../workout/presentation/widgets/day_workouts_section.dart';
import '../../workout/presentation/widgets/workout_sheet.dart';
import '../../care/providers/care_providers.dart';
import '../../identity/providers/profile_providers.dart';
import '../data/plan_day.dart';
import '../data/plan_day_coverage.dart';
import '../domain/plan_day_date.dart';
import '../providers/diet_plan_providers.dart';
import '../providers/meal_swap_providers.dart';
import '../providers/plan_day_providers.dart';
import 'widgets/date_selector.dart';
import 'widgets/day_pager.dart';
import 'widgets/group_day_grid_view.dart';
import 'widgets/meal_card.dart';
import 'widgets/member_selector.dart';
import 'widgets/plan_status_banner.dart';
import 'widgets/segmented_view_control.dart';
import 'widgets/week_selector.dart';
import 'widgets/weekly_view.dart';

/// *Piano* (6.1 interfaccia.md; VG-1..VG-4, VS-1): schermata principale
/// dell'applicazione, destinazione di *Piano* nella barra di
/// navigazione. Raccoglie le due viste sul medesimo contenuto — giorno
/// (6.2) e settimana (6.4) — dietro il segmented control
/// dell'intestazione (6.1), condividendo un solo riferimento temporale
/// (`selectedDayProvider`, VS-14).
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final viewMode = ref.watch(selectedPlanViewProvider);
    final selectedDate = ref.watch(selectedDayProvider);
    final swapSelection = ref.watch(mealSwapSelectionProvider);
    // VG-8, GE-18: il selettore esiste solo per chi appartiene a un
    // Gruppo. Riservargli comunque la zona di sinistra sottraeva
    // larghezza al segmented control anche a chi non lo vede mai.
    final hasGroup = ref.watch(currentCookingGroupProvider).value != null;

    void selectDate(DateTime date) => ref.read(selectedDayProvider.notifier).select(date);
    void showDay(DateTime date) {
      // VS-14: il tocco su un giorno della settimana conduce alla
      // giornaliera di quel giorno, conservando il riferimento.
      selectDate(date);
      ref.read(selectedPlanViewProvider.notifier).select(PlanViewMode.day);
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        // VG-7, VG-8, 4.2 interfaccia.md: assente per l'Utente privo di
        // Gruppo (MemberSelector non presenta nulla in quel caso) e in
        // modalità di selezione dell'inversione.
        leading: swapSelection == null && hasGroup ? const MemberSelector() : null,
        // 6.1: il segmented control è largo 180 e sta al centro. La zona
        // di sinistra non può eccedere quanto resta una volta sottratte
        // quella larghezza e le azioni, altrimenti è il titolo a cedere:
        // su schermo stretto il selettore si restringe (il nome si tronca,
        // 4.2), non il comando delle due viste.
        leadingWidth: swapSelection == null && hasGroup
            ? (context.breakpoint.isCompact ? 140 : 190)
            : null,
        // 6.5 interfaccia.md: in modalità di selezione l'intestazione è
        // sostituita da "Scegli dove spostarlo" e l'azione Annulla.
        title: swapSelection == null
            ? SegmentedViewControl(
                value: viewMode,
                onChanged: (mode) => ref.read(selectedPlanViewProvider.notifier).select(mode),
              )
            : Text(context.l10n.swapChooseDestination, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
        actions: swapSelection == null
            ? [
                // MD-8, MD-11: modifica della sola giornata selezionata, sul
                // proprio piano e per chi ne ha titolo (non il Paziente, UT-8).
                if (viewMode == PlanViewMode.day) _DayMenu(selectedDate: selectedDate),
                // 12.3, 3.1: icona notifiche nell'intestazione di ogni
                // destinazione principale, dopo l'azione contestuale
                // (3.2). Assente mentre si sceglie dove spostare un
                // pasto: l'intestazione è allora dedicata all'inversione
                // (6.5) e l'unica azione ammessa è Annulla.
                const NotificationBell(),
              ]
            : [
                TextButton(
                  onPressed: () => ref.read(mealSwapSelectionProvider.notifier).cancel(),
                  child: Text(context.l10n.commonCancel),
                ),
              ],
      ),
      // 10.2 interfaccia.md: pulsante mobile in *Piano* per la
      // registrazione di un allenamento, con il foglio completo. 6.2: è
      // assente sulla giornata di un altro membro e in modalità
      // affiancata (CU-10, VG-10), e mentre si sceglie dove spostare un
      // pasto — l'intestazione stessa è allora dedicata all'inversione.
      floatingActionButton: swapSelection == null &&
              ref.watch(selectedGroupMemberProvider) == null &&
              !ref.watch(sideBySideModeProvider)
          ? FloatingActionButton(
              onPressed: () => showWorkoutSheet(context, date: selectedDate),
              backgroundColor: colors.accent,
              foregroundColor: colors.surface,
              tooltip: context.l10n.planRecordWorkout,
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppSpacing.motionScreenTransition,
          transitionBuilder: (child, animation) => SlideTransition(
            // 6.1: "Settimana entra da destra, Giorno da sinistra".
            position: Tween(
              begin: Offset(viewMode == PlanViewMode.week ? 0.05 : -0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: viewMode == PlanViewMode.day
              ? _DailyView(key: const ValueKey('day'), selectedDate: selectedDate, onSelect: selectDate)
              : _WeeklyTab(key: const ValueKey('week'), selectedDate: selectedDate, onNavigate: selectDate, onSelectDay: showDay),
        ),
      ),
    );
  }
}

class _DailyView extends ConsumerWidget {
  const _DailyView({super.key, required this.selectedDate, required this.onSelect});

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(selectedGroupMemberProvider);
    final sideBySide = ref.watch(sideBySideModeProvider);

    return Column(
      children: [
        DateSelector(selectedDate: selectedDate, onSelect: onSelect),
        // VG-11: la riga di contesto non ha senso mentre si consultano
        // tutti i membri insieme (VG-12).
        if (!sideBySide) const MemberContextBanner(),
        Expanded(
          child: sideBySide
              ? _SideBySideContent(date: selectedDate)
              : _SingleMemberContent(selectedDate: selectedDate, member: member, onSelect: onSelect),
        ),
      ],
    );
  }
}

class _SideBySideContent extends ConsumerWidget {
  const _SideBySideContent({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(profileControllerProvider).value?.id;
    if (currentUserId == null) return const SizedBox.shrink();
    return GroupDayGridView(date: date, currentUserId: currentUserId);
  }
}

class _SingleMemberContent extends StatelessWidget {
  const _SingleMemberContent({required this.selectedDate, required this.member, required this.onSelect});

  final DateTime selectedDate;
  final String? member;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    // 6.2: "lo scorrimento orizzontale del contenuto cambia giorno" — lo
    // stesso gesto della riga dei giorni, qui applicato al contenuto
    // sottostante. Il giorno accanto segue il dito e si assesta a gesto
    // concluso: vedi DayPager.
    return DayPager(
      key: const Key('dailyViewContentSwipe'),
      selectedDate: selectedDate,
      onSelect: onSelect,
      dayBuilder: (context, date) => _DayPage(date: date, member: member),
    );
  }
}

/// Una giornata dentro il pager. Ciascuna pagina attende il proprio
/// giorno per conto suo: lo scorrimento resta possibile mentre il
/// giorno di arrivo si sta caricando, e il caricamento di quello accanto
/// comincia appena il gesto lo scopre, non a gesto concluso.
class _DayPage extends ConsumerWidget {
  const _DayPage({required this.date, required this.member});

  final DateTime date;
  final String? member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.typography;
    final colors = context.colors;
    final dayState = ref.watch(planDayProvider(date, userId: member));

    return AnimatedSwitcher(
      duration: AppSpacing.motionStateTransition,
      child: dayState.when(
        loading: () => const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          key: const ValueKey('error'),
          child: Text(
            describeApiError(context, error.asApiException?.code ?? ''),
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ),
        data: (day) => _DayContent(key: const ValueKey('data'), day: day),
      ),
    );
  }
}

class _WeeklyTab extends StatelessWidget {
  const _WeeklyTab({
    super.key,
    required this.selectedDate,
    required this.onNavigate,
    required this.onSelectDay,
  });

  final DateTime selectedDate;

  /// Frecce e "Questa settimana" (VS-12, VS-13): sposta il riferimento
  /// temporale senza lasciare la vista settimanale.
  final ValueChanged<DateTime> onNavigate;

  /// VS-14: tocco sull'intestazione di un giorno, passa alla vista
  /// giornaliera di quel giorno.
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final weekStart = startOfWeek(selectedDate);
    final currentWeekStart = startOfWeek(dateOnly(DateTime.now()));
    final isCurrentWeek = weekStart == currentWeekStart;

    return Column(
      children: [
        WeekSelector(
          weekStart: weekStart,
          onPrevious: () => onNavigate(weekStart.subtract(const Duration(days: 7))),
          onNext: () => onNavigate(weekStart.add(const Duration(days: 7))),
          onCurrentWeek: isCurrentWeek ? null : () => onNavigate(currentWeekStart),
        ),
        const MemberContextBanner(),
        Expanded(child: WeeklyView(weekStart: weekStart, onSelectDay: onSelectDay)),
      ],
    );
  }
}

/// VG-18, PA-10: natura della giornata quando non ordinaria. Sospensione
/// e assenza di piano sostituiscono l'intero contenuto con lo stato
/// vuoto previsto da 4.4 interfaccia.md; programmato e concluso restano
/// visibili con la striscia informativa di 6.1 sopra il contenuto — non
/// sono condizioni che impediscono la consultazione, solo che la
/// segnalano.
class _DayContent extends ConsumerWidget {
  const _DayContent({super.key, required this.day});

  final PlanDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(selectedGroupMemberProvider);
    // AL-12, VG-6: gli allenamenti previsti e registrati compaiono sopra
    // i pasti, in una sezione distinta. CU-10, VG-10: assente sulla
    // giornata di un altro membro del Gruppo, cui sono riservati.
    //
    // La sezione precede il contenuto in ogni condizione di copertura,
    // sospensione e assenza di piano comprese: l'attività fisica è
    // indipendente dal piano alimentare e non è preclusa quando questo è
    // interrotto (AL-8, RA-8, SA-14) — 6.2 lo dice per la giornata senza
    // pasti, e la ragione vale identica per le altre (vedi decisioni.md).
    if (member == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DayWorkoutsSection(date: day.date),
          Expanded(child: _MealsContent(day: day)),
        ],
      );
    }
    return _MealsContent(day: day);
  }
}

/// La parte alimentare della giornata, che la sezione degli allenamenti
/// sovrasta senza mescolarvisi (AL-12: "chiaramente distinti").
class _MealsContent extends ConsumerWidget {
  const _MealsContent({required this.day});

  final PlanDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(selectedGroupMemberProvider);
    // CU-9: la giornata di un altro membro del Gruppo non offre mai
    // azioni sulla gestione del piano stesso (ripresa, creazione) — il
    // Cuoco riorganizza quando un pasto è consumato, non decide del
    // piano (CU-2, CU-3 riguardano solo spunta e inversione).
    final readOnly = member != null;
    // CU-2, CU-3: il Cuoco può invece spuntare e invertire sul piano di
    // un membro del proprio Gruppo.
    final canOperate = member == null || ref.watch(isCookProvider);
    // UT-8, TR-17 (F22): il Paziente non dispone del piano redatto dal
    // proprio Nutrizionista — né lo riprende, né ne crea uno proprio.
    final careLink = ref.watch(currentCareLinkOrNullProvider);
    final canManage = !readOnly && !ref.watch(isPlanLockedProvider(day.planId));
    final canCreate = !readOnly && canCreateOwnPlan(careLink);
    switch (day.coverage) {
      case PlanDayCoverage.suspended:
        // ref.watch (non solo read) tiene vivo il controller autoDispose
        // per la durata dell'operazione, oltre a pilotare l'indicatore
        // di attesa del pulsante (2.6).
        final resuming =
            ref.watch(dietPlanLifecycleControllerProvider)?.isLoading ?? false;
        return EmptyStateView(
          icon: Icons.pause_circle_outline,
          title: context.l10n.planSuspended,
          text: context.l10n.planSuspendedHint,
          actionLabel: canManage ? context.l10n.planActionResume : null,
          actionLoading: resuming,
          onAction: !canManage
              ? null
              : () async {
                  await ref
                      .read(dietPlanLifecycleControllerProvider.notifier)
                      .resume(day.planId!);
                  ref.invalidate(planDayProvider(day.date));
                },
        );
      case PlanDayCoverage.none:
        final ownedPlans = readOnly ? null : ref.watch(ownedDietPlansProvider);
        final everCreated = readOnly || (ownedPlans?.value?.isNotEmpty ?? true);
        if (!canCreate && !everCreated) {
          // 7.1 interfaccia.md: al Paziente privo di piani, la constatazione neutra.
          return EmptyStateView(
            icon: Icons.calendar_month_outlined,
            title: context.l10n.planNoneYet,
            text: context.l10n.planPatientNoPlanYet,
          );
        }
        return everCreated
            ? EmptyStateView(
                icon: Icons.event_busy,
                title: context.l10n.planNoneForThisDay,
              )
            : EmptyStateView(
                icon: Icons.calendar_month_outlined,
                title: context.l10n.plansStartHere,
                text: context.l10n.planCreateFirst,
                actionLabel: context.l10n.planCreateSubmit,
                onAction: () => context.push('/diet-plans/new'),
              );
      case PlanDayCoverage.scheduled:
      case PlanDayCoverage.completed:
      case PlanDayCoverage.active:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (day.coverage == PlanDayCoverage.scheduled)
              PlanStatusBanner(
                text: context.l10n.planStartsOn(formatDate(context, day.planStartDate!)),
              )
            else if (day.coverage == PlanDayCoverage.completed)
              PlanStatusBanner(
                text: context.l10n.planCompletedOn(formatDate(context, day.planEndDate!)),
              ),
            Expanded(
              child: _SlotsOrEmpty(
                slots: day.slots,
                date: day.date,
                canCheck: day.coverage == PlanDayCoverage.active && canOperate,
                planId: day.planId,
                member: member,
              ),
            ),
          ],
        );
    }
  }
}

class _SlotsOrEmpty extends StatelessWidget {
  const _SlotsOrEmpty({
    required this.slots,
    required this.date,
    required this.canCheck,
    required this.planId,
    required this.member,
  });

  final List<PlanDaySlot> slots;
  final DateTime date;

  /// SP-11: false su Programmato e Concluso, gli unici casi in cui questo
  /// widget è raggiunto con `coverage` diverso da Attivo (Sospeso e
  /// assenza di piano sostituiscono l'intero contenuto, vedi
  /// `_DayContent`). CU-2, CU-3: anche false per un membro non Cuoco.
  final bool canCheck;

  /// Piano che copre la giornata, per l'avvio dell'inversione (6.5
  /// interfaccia.md) dalla card espansa.
  final String? planId;

  /// CU-3: il membro su cui si sta operando, `null` per il proprio piano.
  final String? member;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      // GG-7: condizione legittima, non un errore — nessuna azione.
      return EmptyStateView(
        icon: Icons.restaurant_outlined,
        title: context.l10n.planNoMealsPlanned,
      );
    }

    // VG-3: nell'ordinamento definito dal piano — già garantito dal
    // backend (GG-8), nessun riordino qui.
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      itemCount: slots.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.xs),
      // VG-4: tutti gli slot restano sempre visibili, quale sia il loro
      // stato — nessun filtro qui.
      itemBuilder: (context, index) =>
          MealCard(slot: slots[index], date: date, canCheck: canCheck, planId: planId, member: member),
    );
  }
}


/// UT-8, PZ-4: se il piano indicato — il proprio, quello che copre la
/// giornata — è redatto dal Nutrizionista con cui vige un collegamento.
/// `false` finché piani o collegamento non sono noti.
final isPlanLockedProvider = Provider.family<bool, String?>((ref, planId) {
  if (planId == null) return false;
  final careLink = ref.watch(currentCareLinkOrNullProvider);
  if (careLink == null) return false;
  final plans = ref.watch(ownedDietPlansProvider).value;
  if (plans == null) return false;
  for (final plan in plans) {
    if (plan.id == planId) return isPlanLockedForPatient(plan, careLink);
  }
  return false;
});

/// MD-8: menu della giornata — "Modifica questa giornata", sul proprio
/// piano Attivo, per chi ne ha titolo (MD-15). Assente su un membro del
/// Gruppo (CU-9) e, per il Paziente, sul piano del Nutrizionista (UT-8).
class _DayMenu extends ConsumerWidget {
  const _DayMenu({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(selectedGroupMemberProvider);
    final sideBySide = ref.watch(sideBySideModeProvider);
    if (member != null || sideBySide) return const SizedBox.shrink();
    final day = ref.watch(planDayProvider(selectedDate)).value;
    if (day == null || day.coverage != PlanDayCoverage.active) return const SizedBox.shrink();
    if (ref.watch(isPlanLockedProvider(day.planId))) return const SizedBox.shrink();
    if (dateOnly(selectedDate).isBefore(dateOnly(DateTime.now()))) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      tooltip: context.l10n.planMoreActions,
      onSelected: (value) {
        if (value == 'edit-day') context.push('/plan-days/${isoDate(selectedDate)}/edit');
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit-day', child: Text(context.l10n.planEditThisDay)),
      ],
    );
  }
}
