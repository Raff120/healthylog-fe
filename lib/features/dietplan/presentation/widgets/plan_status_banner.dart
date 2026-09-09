import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';

/// Striscia informativa dello stato del piano (6.1 interfaccia.md, VG-18):
/// resa in superficie alternativa con testo secondario, mai in colore di
/// avviso — sono condizioni legittime, non anomalie.
class PlanStatusBanner extends StatelessWidget {
  const PlanStatusBanner({super.key, required this.text});

  final String text;

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
      child: Text(
        text,
        style: typography.bodyMedium.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
