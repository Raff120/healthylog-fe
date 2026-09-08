import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_breakpoints.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/care_models.dart';
import '../providers/care_providers.dart';
import 'patient_detail_screen.dart';
import 'widgets/invite_patient_sheet.dart';
import 'widgets/patient_tile.dart';

/// *Pazienti* (9.1 interfaccia.md; NU-1, VA-1..VA-9): destinazione
/// iniziale del Nutrizionista. Richieste pendenti in cima (VA-9), elenco
/// dei Pazienti ordinabile per nome, aderenza o attività recente (VA-4)
/// e pulsante mobile per l'invito (9.3). Nessuna statistica aggregata
/// sull'insieme dei Pazienti (VA-8).
///
/// Su `expanded` e oltre, elenco a sinistra e dettaglio del Paziente
/// selezionato a destra (3.3 interfaccia.md).
class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  PatientSort _sort = PatientSort.name;
  String? _selectedPatientId;

  Future<void> _invite() async {
    final sent = await showInvitePatientSheet(context);
    if (sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Richiesta inviata.')));
    }
  }

  Future<void> _withdraw(CareLinkRequest request) async {
    await ref.read(careLinkRequestActionControllerProvider.notifier).withdraw(request.id);
    if (!mounted) return;
    ref.read(careLinkRequestActionControllerProvider)?.whenOrNull(
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
          ),
        );
  }

  void _openPatient(PatientSummary patient) {
    if (context.breakpoint.isAtLeastExpanded) {
      setState(() => _selectedPatientId = patient.userId);
    } else {
      context.push('/patients/${patient.userId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final patientsState = ref.watch(patientsProvider(_sort));
    final requestsState = ref.watch(careLinkRequestsProvider);
    // Tiene vivo il controller autoDispose per la durata della revoca
    // della richiesta (CP-8), che nessun altro punto osserva.
    ref.watch(careLinkRequestActionControllerProvider);
    final wide = context.breakpoint.isAtLeastExpanded;

    final list = patientsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          describeApiError(error.asApiException?.code ?? ''),
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ),
      data: (patients) {
        final requests = requestsState.value ?? const <CareLinkRequest>[];
        if (patients.isEmpty && requests.isEmpty) {
          return EmptyStateView(
            icon: Icons.groups_outlined,
            title: 'Nessun paziente collegato',
            text: 'Invita un paziente con il suo nome utente',
            actionLabel: 'Invita paziente',
            onAction: _invite,
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl * 2),
          children: [
            if (requests.isNotEmpty) ...[
              Text('RICHIESTE PENDENTI', style: typography.overline.copyWith(color: colors.textTertiary)),
              const SizedBox(height: AppSpacing.xs),
              for (final request in requests)
                _PendingRequestTile(request: request, onWithdraw: () => _withdraw(request)),
              const SizedBox(height: AppSpacing.md),
            ],
            if (patients.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: Text('PAZIENTI', style: typography.overline.copyWith(color: colors.textTertiary)),
                  ),
                  PopupMenuButton<PatientSort>(
                    tooltip: 'Ordina',
                    onSelected: (sort) => setState(() => _sort = sort),
                    itemBuilder: (context) => [
                      for (final sort in PatientSort.values)
                        CheckedPopupMenuItem(value: sort, checked: sort == _sort, child: Text(sort.label)),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_sort.label, style: typography.caption.copyWith(color: colors.textSecondary)),
                          Icon(Icons.arrow_drop_down, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final patient in patients)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: PatientTile(
                    patient: patient,
                    selected: wide && patient.userId == _selectedPatientId,
                    onTap: () => _openPatient(patient),
                  ),
                ),
            ],
          ],
        );
      },
    );

    final body = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 360, child: list),
              const VerticalDivider(width: 1),
              Expanded(
                child: _selectedPatientId == null
                    ? Center(
                        child: Text(
                          'Seleziona un paziente',
                          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                        ),
                      )
                    : PatientDetailScreen(
                        key: ValueKey(_selectedPatientId),
                        patientId: _selectedPatientId!,
                        embedded: true,
                      ),
              ),
            ],
          )
        : list;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Pazienti', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      // 9.1 interfaccia.md: "Pulsante mobile, icona user-plus. Conduce a 9.3".
      floatingActionButton: FloatingActionButton(
        onPressed: _invite,
        tooltip: 'Invita paziente',
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
      body: SafeArea(child: body),
    );
  }
}

/// 9.1 interfaccia.md, "Richieste pendenti": nome e cognome del
/// destinatario, data di invio, stato e azione Revoca (CP-8). Una
/// richiesta decaduta compare con l'indicazione della decadenza, senza
/// azione (CP-7).
class _PendingRequestTile extends StatelessWidget {
  const _PendingRequestTile({required this.request, required this.onWithdraw});

  final CareLinkRequest request;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final expired = request.status == CareLinkRequestStatus.expired;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.targetName, style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
                Text(
                  expired ? 'Decaduta' : 'Inviata il ${_formatDate(request.createdAt)} · In attesa',
                  style: typography.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (!expired) TextButton(onPressed: onWithdraw, child: const Text('Revoca')),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}
