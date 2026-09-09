import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../l10n/l10n_context.dart';
import '../../care/providers/care_providers.dart';
import '../../group/providers/cooking_group_providers.dart';
import '../providers/profile_providers.dart';

/// Eliminazione dell'account (12.2 interfaccia.md; PV-16, PV-19).
///
/// 12.2: schermata dedicata, non un semplice riquadro di conferma.
/// Presenta l'elenco di quanto sarà cancellato (PV-19), l'indicazione del
/// periodo di ripensamento (PV-17) e, per il Paziente, cosa il
/// Nutrizionista conserverà (PV-21, PV-22). Per il Proprietario di un
/// gruppo, la successione automatica o lo scioglimento (PV-20).
///
/// La conferma è rafforzata (4.5), ma non è richiesta la digitazione di
/// alcun testo: il ripensamento assolve la medesima funzione con minore
/// attrito.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _submitting = false;

  Future<void> _request() async {
    final confirmed = await _confirm();
    if (!confirmed || !mounted) return;
    setState(() => _submitting = true);
    try {
      // PV-17: la richiesta apre il ripensamento; l'instradamento porta
      // da sé alla schermata che lo constata.
      await ref.read(profileControllerProvider.notifier).requestDeletion();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<bool> _confirm() async {
    final colors = context.colors;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountGracePeriod),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAccountConfirm, style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;
    final profile = ref.watch(profileControllerProvider).value;
    // PV-20: la conseguenza sul Gruppo dipende dall'esservi Proprietario
    // e dall'esservi altri membri (GR-16, GR-18).
    final group = ref.watch(currentCookingGroupProvider).value;
    final isOwner = group != null && profile != null && group.ownerId == profile.id;
    final isOnlyMember = group != null && group.members.length == 1;
    // PV-21: la conservazione riguarda il solo Paziente collegato.
    final hasNutritionist = ref.watch(currentCareLinkProvider).value != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.deleteAccountTitle, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(l10n.deleteAccountIntro, style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            for (final loss in [
              l10n.deleteAccountLossPlans,
              l10n.deleteAccountLossStatistics,
              l10n.deleteAccountLossActivity,
              l10n.deleteAccountLossMemberships,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                child: Text(loss, style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
              ),
            const SizedBox(height: AppSpacing.md),
            _Notice(text: l10n.deleteAccountGracePeriod),
            if (hasNutritionist) ...[
              const SizedBox(height: AppSpacing.xs),
              _Notice(text: l10n.deleteAccountNutritionistKeeps),
            ],
            if (isOwner) ...[
              const SizedBox(height: AppSpacing.xs),
              _Notice(
                text: isOnlyMember
                    ? l10n.deleteAccountGroupDissolution
                    : l10n.deleteAccountGroupSuccession,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: l10n.deleteAccountConfirm,
              loading: _submitting,
              onPressed: _request,
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(text, style: typography.caption.copyWith(color: colors.textPrimary)),
    );
  }
}
