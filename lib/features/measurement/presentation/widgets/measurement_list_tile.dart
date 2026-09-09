import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/measurement_models.dart';
import 'measurement_sheet.dart';

/// Voce dell'elenco delle misurazioni (10.3 interfaccia.md): alta 68, in
/// ordine cronologico decrescente (AN-4), con data, peso e circonferenze
/// in forma sintetica.
///
/// AN-5, PR-17: l'icona distingue le misurazioni registrate dal
/// Nutrizionista da quelle registrate dall'Utente — le due fonti possono
/// differire per strumento e condizioni di rilevazione (NU-12).
class MeasurementListTile extends StatelessWidget {
  const MeasurementListTile({super.key, required this.measurement, this.onTap});

  final BodyMeasurement measurement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final circumferences = measurement.circumferences.entries;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.heightListItemTwoLines),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        formatMeasurementDate(measurement.date),
                        style: typography.titleMedium.copyWith(color: colors.textPrimary),
                      ),
                      if (measurement.fromNutritionist) ...[
                        const SizedBox(width: AppSpacing.xxs),
                        Icon(Icons.medical_services_outlined, size: 16, color: colors.textTertiary),
                      ],
                    ],
                  ),
                  if (circumferences.isNotEmpty)
                    Text(
                      circumferences
                          .map((entry) => '${entry.$1} ${formatMeasurementValue(entry.$2)}')
                          .join(' · '),
                      style: typography.caption.copyWith(color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (measurement.weightKg != null)
              Text(
                '${formatMeasurementValue(measurement.weightKg!)} kg',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
