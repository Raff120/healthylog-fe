import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../data/account_role.dart';

/// Scelta del ruolo (5.1 interfaccia.md, RG-1): precede tutto perché è
/// irreversibile. Conduce direttamente al passaggio successivo, senza
/// pulsante di conferma.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Come userai HealthyLog?', style: typography.titleLarge.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: AppSpacing.lg),
                  _RoleCard(
                    icon: Icons.person_outline,
                    title: 'Seguo un piano',
                    description: 'Consulti la tua dieta, segni i pasti e registri gli allenamenti',
                    onTap: () => context.push('/register/details', extra: AccountRole.user),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RoleCard(
                    icon: Icons.medical_information_outlined,
                    title: 'Sono un nutrizionista',
                    description: 'Redigi e segui i piani dei tuoi pazienti',
                    onTap: () => context.push('/register/details', extra: AccountRole.nutritionist),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'La scelta non è modificabile in seguito',
                    style: typography.caption.copyWith(color: colors.textSecondary),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 32, color: colors.accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
