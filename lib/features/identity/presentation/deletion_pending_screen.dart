import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';
import '../providers/profile_providers.dart';
import '../providers/sessions_providers.dart';

/// PV-17, 12.2 interfaccia.md: durante il ripensamento l'account
/// disattivato presenta all'accesso una schermata che constata la
/// richiesta in corso, indica la data di cancellazione definitiva e offre
/// l'azione «Annulla eliminazione».
///
/// L'annullamento ripristina integralmente l'account e riporta
/// all'applicazione — l'instradamento vi torna da sé non appena il
/// profilo non è più in ripensamento.
class DeletionPendingScreen extends ConsumerStatefulWidget {
  const DeletionPendingScreen({super.key});

  @override
  ConsumerState<DeletionPendingScreen> createState() => _DeletionPendingScreenState();
}

class _DeletionPendingScreenState extends ConsumerState<DeletionPendingScreen> {
  bool _submitting = false;

  Future<void> _cancel() async {
    setState(() => _submitting = true);
    try {
      await ref.read(profileControllerProvider.notifier).cancelDeletion();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _logout() async {
    final session = ref.read(sessionControllerProvider).value;
    if (session != null) {
      try {
        await ref.read(sessionsApiProvider).logoutCurrentDevice(session.refreshToken);
      } catch (_) {
        // Ignorato di proposito: TK-19 impone la rimozione dei dati
        // locali, non che essa dipenda dalla raggiungibilità del server.
      }
    }
    await ref.read(sessionControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;
    final profile = ref.watch(profileControllerProvider).value;
    final effectiveAt = profile?.deletionEffectiveAt;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.hourglass_empty, size: 48, color: colors.textTertiary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.deletionPendingTitle,
                    textAlign: TextAlign.center,
                    style: typography.titleLarge.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (effectiveAt != null)
                    Text(
                      l10n.deletionPendingBody(formatDate(context, effectiveAt)),
                      textAlign: TextAlign.center,
                      style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    label: l10n.deletionPendingCancel,
                    loading: _submitting,
                    onPressed: _cancel,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // AC-13, TK-19: la disconnessione resta l'altra via
                  // d'uscita. Come nel Profilo, la revoca lato server è
                  // tentata ma la rimozione locale procede comunque.
                  TextButton(
                    onPressed: _submitting ? null : _logout,
                    child: Text(l10n.profileLogout),
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
