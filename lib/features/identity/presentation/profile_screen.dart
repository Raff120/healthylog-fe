import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/session_controller.dart';
import '../providers/profile_providers.dart';
import '../providers/sessions_providers.dart';

/// Profilo (12.1 interfaccia.md): intestazione personale, elenco delle
/// sezioni, disconnessione in fondo. Le sole sezioni già realizzate
/// compaiono: Piani, Gruppo e Nutrizionista appartengono a feature non
/// ancora avviate e non sono quindi presenti (2.6: gli elementi per
/// funzioni inesistenti non compaiono, non sono disabilitati).
/// "Dispositivi collegati" appartiene propriamente a Impostazioni (12.2),
/// non ancora realizzata (F29): resta qui finché non trova la propria
/// sede definitiva, segnalato in decisioni.md.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Disconnetti'),
        content: const Text('Vuoi disconnetterti da questo dispositivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Disconnetti', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // AC-13, TK-19: la disconnessione revoca la sessione anche lato
    // server, non solo l'archivio locale — altrimenti il token di
    // rinnovo resterebbe valido e la sessione comparirebbe ancora tra
    // i dispositivi attivi. Se il server non è raggiungibile, la
    // rimozione locale procede comunque: TK-19 impone la rimozione dei
    // dati locali, non che essa dipenda dalla raggiungibilità del server.
    final session = ref.read(sessionControllerProvider).value;
    if (session != null) {
      try {
        await ref.read(sessionsApiProvider).logoutCurrentDevice(session.refreshToken);
      } catch (_) {
        // Ignorato di proposito: vedi commento sopra.
      }
    }
    await ref.read(sessionControllerProvider.notifier).clear();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(backgroundColor: colors.background, elevation: 0, scrolledUnderElevation: 0),
      body: SafeArea(
        child: profileState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (profile) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colors.surfaceAlt,
                      child: Icon(Icons.person_outline, color: colors.textSecondary, size: 32),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.firstName} ${profile.lastName}',
                            style: typography.titleLarge.copyWith(color: colors.textPrimary),
                          ),
                          Text(
                            '@${profile.username}',
                            style: typography.caption.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _ProfileSection(
                  icon: Icons.person_outline,
                  label: 'Dati personali',
                  onTap: () => context.push('/profile/personal-data'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProfileSection(
                  icon: Icons.devices_outlined,
                  label: 'Dispositivi collegati',
                  onTap: () => context.push('/profile/devices'),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () => _confirmLogout(context, ref),
                    child: Text('Disconnetti', style: TextStyle(color: colors.error)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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
              Icon(icon, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: typography.bodyLarge.copyWith(color: colors.textPrimary))),
              Icon(Icons.chevron_right, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
