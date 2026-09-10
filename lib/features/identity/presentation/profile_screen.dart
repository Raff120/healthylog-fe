import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/session_controller.dart';
import '../../../l10n/l10n_context.dart';
import '../../notification/presentation/widgets/notification_bell.dart';
import '../data/account_role.dart';
import '../providers/profile_providers.dart';
import '../providers/sessions_providers.dart';
import 'widgets/profile_section_tile.dart';

/// Profilo (12.1 interfaccia.md): intestazione personale, elenco delle
/// sezioni, disconnessione in fondo. "Piani" (7.1 interfaccia.md, F10)
/// apre la gestione del piano in corso. "Gruppo" (8.1, 8.2
/// interfaccia.md, F19) apre la sua gestione e composizione.
/// "Nutrizionista" (9.3, F21) il collegamento e le richieste ricevute.
/// Al Nutrizionista compaiono le sole voci *Dati personali* e
/// *Impostazioni* (12.1: non ha gruppo, collegamenti in qualità di
/// paziente, né piani propri — NU-10, NU-11, RG-2).
/// "Impostazioni" (12.2, F11) raccoglie ora anche "Dispositivi
/// collegati", che non compare più qui direttamente (vedi decisioni.md).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(context.l10n.profileLogout),
        content: Text(context.l10n.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.profileLogout, style: TextStyle(color: colors.error)),
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
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        // 12.3, 3.1: icona notifiche nell'intestazione di ogni
        // destinazione principale.
        actions: const [NotificationBell()],
      ),
      body: SafeArea(
        child: profileState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(context, error.asApiException?.code ?? ''),
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
                ProfileSectionTile(
                  icon: Icons.person_outline,
                  label: context.l10n.profilePersonalData,
                  onTap: () => context.push('/profile/personal-data'),
                ),
                // NU-11, GE-4, NU-10, 12.1 interfaccia.md: piani propri, Gruppo e
                // collegamento in qualità di paziente sono del solo Utente.
                if (profile.role == AccountRole.user) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ProfileSectionTile(
                    icon: Icons.calendar_month_outlined,
                    label: context.l10n.profilePlans,
                    onTap: () => context.push('/profile/plans'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ProfileSectionTile(
                    icon: Icons.groups_outlined,
                    label: context.l10n.profileGroup,
                    onTap: () => context.push('/group'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ProfileSectionTile(
                    icon: Icons.medical_services_outlined,
                    label: context.l10n.profileNutritionist,
                    onTap: () => context.push('/profile/nutritionist'),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                ProfileSectionTile(
                  icon: Icons.settings_outlined,
                  label: context.l10n.profileSettings,
                  onTap: () => context.push('/profile/settings'),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () => _confirmLogout(context, ref),
                    child: Text(context.l10n.profileLogout, style: TextStyle(color: colors.error)),
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
