import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';

/// Striscia informativa dello stato del piano (6.1 interfaccia.md, VG-18):
/// resa in superficie alternativa con testo secondario, mai in colore di
/// avviso — sono condizioni legittime, non anomalie.
///
/// [actionLabel] reca l'azione che la condizione ammette, come la ripresa
/// del piano sospeso; assente, la striscia è di sola constatazione.
class PlanStatusBanner extends StatelessWidget {
  const PlanStatusBanner({
    super.key,
    required this.text,
    this.actionLabel,
    this.onAction,
    this.actionLoading = false,
  });

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// 2.6: durante l'operazione il comando non si ripete.
  final bool actionLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      color: colors.surfaceAlt,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: actionLoading ? null : onAction,
              child: Text(actionLabel!, style: typography.label.copyWith(color: colors.accent)),
            ),
        ],
      ),
    );
  }
}
