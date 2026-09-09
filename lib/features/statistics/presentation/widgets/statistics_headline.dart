import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';

/// Valore complessivo di una sezione di *Statistiche* (11.1, 11.2
/// interfaccia.md): numero in `displayLarge` con cifre a larghezza fissa
/// (2.3), unità in `titleMedium`, periodo considerato in `caption` colore
/// secondario.
///
/// Quando [onCaptionTap] è valorizzato la didascalia **è** il selettore
/// del periodo (AD-8): reca la freccia del menu e il colore accento delle
/// azioni. Il comando e la sua etichetta sono la stessa cosa, invece che
/// due righe distinte che dicono lo stesso — vedi
/// `showStatisticsPeriodMenu`.
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
    this.emptyText,
    this.onCaptionTap,
  });

  /// Assente significa assenza di dati (AD-4), non zero.
  final String? value;

  final String? unit;
  final String caption;
  /// AD-4: in assenza vale la constatazione predefinita, risolta alla
  /// costruzione perché richiede il contesto.
  final String? emptyText;

  /// Riceve il contesto della didascalia, cui il menu si ancora.
  final void Function(BuildContext captionContext)? onCaptionTap;

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
          const SizedBox(height: AppSpacing.xxs),
          if (onCaptionTap == null)
            Text(caption, style: typography.caption.copyWith(color: colors.textSecondary))
          else
            Builder(
              builder: (captionContext) => InkWell(
                onTap: () => onCaptionTap!(captionContext),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          caption,
                          style: typography.caption.copyWith(color: colors.accent),
                        ),
                      ),
                      Icon(Icons.expand_more, size: 18, color: colors.accent),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
