import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../l10n/l10n_context.dart';
import '../providers/profile_providers.dart';
import 'widgets/privacy_policy_sheet.dart';

/// PV-8: l'aggiornamento sostanziale dell'informativa comporta una nuova
/// accettazione, richiesta al successivo accesso.
///
/// È uno sbarramento e non un avviso: finché l'accettazione manca,
/// l'instradamento riporta qui da qualunque rotta autenticata. La sola
/// via d'uscita, oltre ad accettare, è la disconnessione — che il Profilo
/// offre e questa schermata non replica.
class PrivacyAcceptanceScreen extends ConsumerStatefulWidget {
  const PrivacyAcceptanceScreen({super.key});

  @override
  ConsumerState<PrivacyAcceptanceScreen> createState() => _PrivacyAcceptanceScreenState();
}

class _PrivacyAcceptanceScreenState extends ConsumerState<PrivacyAcceptanceScreen> {
  bool _accepted = false;
  bool _submitting = false;

  Future<void> _accept() async {
    setState(() => _submitting = true);
    try {
      await ref.read(profileControllerProvider.notifier).acceptPrivacyPolicy();
    } catch (error) {
      if (!mounted) return;
      final code = error.asApiException?.code;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(context, code ?? ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.privacyPolicyUpdatedTitle,
                    style: typography.titleLarge.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.privacyPolicyUpdatedBody,
                    style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton(
                    onPressed: () => showPrivacyPolicySheet(context),
                    child: Text(l10n.privacyPolicyRead),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CheckboxListTile(
                    value: _accepted,
                    onChanged: (value) => setState(() => _accepted = value ?? false),
                    activeColor: colors.accent,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      l10n.privacyPolicyAccept,
                      style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppPrimaryButton(
                    label: l10n.commonContinue,
                    loading: _submitting,
                    onPressed: _accepted ? _accept : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
