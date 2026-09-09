import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';

/// Valore complessivo di una sezione di *Statistiche* (11.1, 11.2
/// interfaccia.md): numero in `displayLarge` con cifre a larghezza fissa
/// (2.3), unità in `titleMedium`, periodo considerato in `caption` colore
/// secondario.
///
/// AD-15, SA-16: il valore è reso in colore **primario**, mai in colore di
/// stato — non è un giudizio. Nessuna soglia, nessun livello, nessuna
/// denominazione valutativa.
///
/// AD-4: in assenza di dati il numero è sostituito da una constatazione,
/// non da uno zero.
class StatisticsHeadline extends StatelessWidget {
  const StatisticsHeadline({
    super.key,
    required this.value,
    required this.unit,
    required this.caption,
    this.emptyText = 'Non ci sono ancora dati',
  });

  /// Assente significa assenza di dati (AD-4), non zero.
  final String? value;

  final String? unit;
  final String caption;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value == null)
            Text(
              emptyText,
              style: typography.titleMedium.copyWith(color: colors.textSecondary),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value!,
                  style: typography.displayLarge.copyWith(color: colors.textPrimary),
                ),
                if (unit != null) ...[
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    unit!,
                    style: typography.titleMedium.copyWith(color: colors.textPrimary),
                  ),
                ],
              ],
            ),
          const SizedBox(height: AppSpacing.xxs),
          Text(caption, style: typography.caption.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}
