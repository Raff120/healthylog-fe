import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_context.dart';
import 'app_primary_button.dart';

/// Stato vuoto uniforme (2.6 interfaccia.md): icona a 48 in colore
/// terziario, titolo, testo facoltativo, azione primaria facoltativa —
/// centrato, spaziatura `xxl` attorno al blocco. La stessa composizione
/// in tutta l'applicazione, perché chi la incontra su una schermata la
/// riconosca su tutte le altre (FE-9).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.text,
    this.actionLabel,
    this.onAction,
    this.actionLoading = false,
  });

  final IconData icon;
  final String title;
  final String? text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: typography.titleMedium.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (text != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                text!,
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 200,
                child: AppPrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  loading: actionLoading,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
