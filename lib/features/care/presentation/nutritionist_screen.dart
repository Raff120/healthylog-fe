import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';
import '../data/care_models.dart';
import '../providers/care_providers.dart';
import 'widgets/care_confirmations.dart';
import 'widgets/care_link_request_sheet.dart';

/// Nutrizionista (9.3 interfaccia.md, "lato Utente"; 4.3 funzionale):
/// raggiunta da Profilo → Nutrizionista. Mostra il collegamento in corso
/// con l'azione di revoca (CP-14, CP-18), le richieste ricevute (CP-10)
/// e, in loro assenza, lo stato vuoto di 4.4 — una condizione legittima,
/// non una mancanza da colmare (RG-5): il collegamento nasce da un
/// invito del professionista (CP-1) e non può essere avviato da qui.
class NutritionistScreen extends ConsumerWidget {
  const NutritionistScreen({super.key});

  Future<void> _revoke(BuildContext context, WidgetRef ref, CareLink link) async {
    final confirmed = await confirmRevokeCareLink(context, asNutritionist: false);
    if (!confirmed || !context.mounted) return;
    await ref.read(revokeCareLinkControllerProvider.notifier).revoke(link.id);
    if (!context.mounted) return;
    ref.read(revokeCareLinkControllerProvider)?.whenOrNull(
          // CP-19, PZ-8, 9.3 interfaccia.md: "l'interfaccia lo comunica con una barra temporanea".
          data: (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.careLinkRevoked)),
          ),
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
          ),
        );
  }

  Future<void> _open(BuildContext context, CareLinkRequest request) async {
    final accepted = await showCareLinkRequestSheet(context, request);
    if (accepted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.careLinkedNow(request.nutritionistName))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final linkState = ref.watch(currentCareLinkProvider);
    final requestsState = ref.watch(careLinkRequestsProvider);
    // Tiene vivo il controller autoDispose per la durata della revoca
    // (nessun altro punto lo osserva) — stesso accorgimento della
    // redazione dello schema.
    ref.watch(revokeCareLinkControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(context.l10n.profileNutritionist, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: linkState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) {
            final code = error.asApiException?.code;
            if (code != 'RESOURCE_NOT_FOUND') {
              return Center(
                child: Text(describeApiError(context, code ?? ''), style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
              );
            }
            return requestsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  describeApiError(context, error.asApiException?.code ?? ''),
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              ),
              data: (requests) => requests.isEmpty
                  ? EmptyStateView(
                      icon: Icons.medical_services_outlined,
                      title: context.l10n.careNoNutritionist,
                      text: context.l10n.careManagePlanYourself,
                    )
                  : _ReceivedRequestsList(requests: requests, onOpen: (request) => _open(context, request)),
            );
          },
          data: (link) => _CurrentLinkView(link: link, onRevoke: () => _revoke(context, ref, link)),
        ),
      ),
    );
  }
}

/// 9.3 interfaccia.md, "Collegamento in corso — lato Utente": card con
/// il nome del professionista, la data del collegamento e l'azione Revoca.
class _CurrentLinkView extends StatelessWidget {
  const _CurrentLinkView({required this.link, required this.onRevoke});

  final CareLink link;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.careLinkActiveHeader, style: typography.overline.copyWith(color: colors.accent)),
              const SizedBox(height: AppSpacing.xxs),
              Text(link.nutritionistName, style: typography.titleLarge.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.xxs),
              Text(context.l10n.careLinkedSince(formatDate(context, link.createdAt)), style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.careNutritionistNotice,
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: TextButton(
            onPressed: onRevoke,
            child: Text(context.l10n.careRevokeLink, style: TextStyle(color: colors.error)),
          ),
        ),
      ],
    );
  }
}

/// CP-10: le richieste ricevute, ciascuna toccabile per aprire la
/// schermata di accettazione (CP-5).
class _ReceivedRequestsList extends StatelessWidget {
  const _ReceivedRequestsList({required this.requests, required this.onOpen});

  final List<CareLinkRequest> requests;
  final ValueChanged<CareLinkRequest> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(context.l10n.careRequestsReceivedHeader, style: typography.overline.copyWith(color: colors.textTertiary)),
        const SizedBox(height: AppSpacing.xs),
        for (final request in requests)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () => onOpen(request),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services_outlined, color: colors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(request.nutritionistName, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                            Text(
                              request.message == null || request.message!.isEmpty
                                  ? context.l10n.careRequestReceivedOn(formatDate(context, request.createdAt))
                                  : request.message!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.caption.copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.textTertiary),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

