import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';

/// Riga di una disaggregazione (11.1 interfaccia.md, AD-13): icona
/// facoltativa, denominazione, valore allineato a destra e barra di
/// riempimento sottile in colore accento.
///
/// AD-15: la barra è sempre in colore accento — non muta al variare del
/// valore, non essendovi soglie di merito. Il valore assente è assenza di
/// dati (AD-4): la barra non compare e al posto della percentuale sta un
/// trattino.
class BreakdownRow extends StatelessWidget {
  const BreakdownRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trailingText,
    this.fraction,
  });

  final String label;

  /// Testo del valore, assente se non vi sono dati.
  final String? value;

  final IconData? icon;

  /// Testo aggiuntivo accanto al valore (per esempio il numero di sessioni).
  final String? trailingText;

  /// Riempimento della barra, fra 0 e 1. Assente con il valore.
  final double? fraction;

  static const _barHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: colors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  label,
                  style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: typography.caption.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                value ?? '–',
                style: typography.label.copyWith(
                  color: value == null ? colors.textTertiary : colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: SizedBox(
              height: _barHeight,
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: colors.surfaceAlt)),
                  if (fraction != null)
                    FractionallySizedBox(
                      widthFactor: fraction!.clamp(0.0, 1.0),
                      heightFactor: 1,
                      child: ColoredBox(color: colors.accent),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
