import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/measurement_models.dart';
import 'measurement_sheet.dart';

/// Ultima misurazione in evidenza (10.3 interfaccia.md): il peso in
/// `displayLarge` e la data in `caption`, seguiti dalle circonferenze
/// rilevate in forma tabellare.
///
/// Nessun confronto con la precedente, nessuna variazione, nessuna freccia
/// direzionale: le elaborazioni appartengono alle statistiche (11.3), e la
/// variazione è presentata lì in forma neutra (AN-11).
class LastMeasurementCard extends StatelessWidget {
  const LastMeasurementCard({super.key, required this.measurement});

  final BodyMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final circumferences = measurement.circumferences.entries;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (measurement.weightKg != null)
            Text(
              '${formatMeasurementValue(measurement.weightKg!)} kg',
              style: typography.displayLarge.copyWith(color: colors.textPrimary),
            ),
          Row(
            children: [
              Text(
                formatMeasurementDate(measurement.date),
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
              // AN-5, PR-17: la fonte è distinta anche qui.
              if (measurement.fromNutritionist) ...[
                const SizedBox(width: AppSpacing.xxs),
                Icon(Icons.medical_services_outlined, size: 16, color: colors.textTertiary),
              ],
            ],
          ),
          if (circumferences.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final entry in circumferences)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.$1,
                      style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                    Text(
                      '${formatMeasurementValue(entry.$2)} cm',
                      style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
