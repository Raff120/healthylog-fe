import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';

/// Valore complessivo di una sezione di *Statistiche* (11.1, 11.2
/// interfaccia.md): numero in `displayLarge` con cifre a larghezza fissa
/// (2.3), unità in `titleMedium`, e una `caption` in colore secondario
/// dove occorra dire del periodo più di quanto il navigatore già dica.
///
/// La didascalia dichiara il periodo, non lo governa: i comandi stanno
/// sopra il contenuto (`StatisticsPeriodSelector`,
/// `StatisticsPeriodNavigator`), dove restano raggiungibili anche là dove
/// un valore complessivo non esista. Da quando il periodo osservato è
/// scritto nel navigatore (AD-8bis), la didascalia è **assente** su
/// settimana e mese, che vi si leggono per esteso: ripeterla due righe
/// sotto non direbbe nulla di nuovo.
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
    this.caption,
    this.emptyText,
  });

  /// Assente significa assenza di dati (AD-4), non zero.
  final String? value;

  final String? unit;

  /// Assente quando il navigatore già dice il periodo per esteso.
  final String? caption;
  /// AD-4: in assenza vale la constatazione predefinita, risolta alla
  /// costruzione perché richiede il contesto.
  final String? emptyText;

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
              emptyText ?? context.l10n.statisticsNoDataYet,
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
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(caption!, style: typography.caption.copyWith(color: colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
