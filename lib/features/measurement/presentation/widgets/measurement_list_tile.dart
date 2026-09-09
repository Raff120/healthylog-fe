import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../../l10n/units.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../data/measurement_models.dart';
import '../body_circumference_presentation.dart';
import 'measurement_sheet.dart';

/// Voce dell'elenco delle misurazioni (10.3 interfaccia.md): alta 68, in
/// ordine cronologico decrescente (AN-4), con data, peso e circonferenze
/// in forma sintetica.
///
/// AN-5, PR-17: l'icona distingue le misurazioni registrate dal
/// Nutrizionista da quelle registrate dall'Utente — le due fonti possono
/// differire per strumento e condizioni di rilevazione (NU-12).
class MeasurementListTile extends ConsumerWidget {
  const MeasurementListTile({super.key, required this.measurement, this.onTap});

  final BodyMeasurement measurement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final circumferences = measurement.circumferences.entries;
    final units = ref.watch(unitSystemProvider);

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
                          .map((entry) =>
                              '${bodyCircumferenceLabel(context, entry.$1)} '
                              '${formatMeasurementValue(lengthToDisplay(entry.$2, units))}')
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
                context.l10n.measureValueWithUnit(
                  formatMeasurementValue(weightToDisplay(measurement.weightKg!, units)),
                  weightUnit(context, units),
                ),
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
