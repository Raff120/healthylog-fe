import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';
import '../../../l10n/units.dart';
import '../../identity/providers/profile_providers.dart';
import '../data/measurement_models.dart';
import 'body_circumference_presentation.dart';
import 'widgets/measurement_list_tile.dart';
import 'widgets/measurement_sheet.dart';

/// Elenco cronologico delle misurazioni (AN-4), voci separate da un
/// filo. Non scorre di suo: vive dentro il contenuto che lo ospita —
/// il segmento *Corpo* di *Statistiche* (11.3), in coda al grafico.
///
/// Risiede nella feature *measurement* e non in *statistics* perché la
/// misurazione è sua: *Statistiche* la presenta, non la possiede (FE-6).
class MeasurementList extends StatelessWidget {
  const MeasurementList({super.key, required this.items});

  final List<BodyMeasurement> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final measurement in items) ...[
          MeasurementListTile(
            measurement: measurement,
            // PR-16, PR-17: il tocco conduce alla modifica sulle proprie
            // misurazioni, alla sola consultazione su quelle del
            // professionista.
            onTap: () => showMeasurementDetail(context, measurement),
          ),
          Divider(height: 1, color: colors.dividerLight),
        ],
      ],
    );
  }
}

/// PR-17, 11.3: le misurazioni rilevate dal professionista si consultano,
/// non si modificano; per le proprie il tocco conduce alla modifica
/// (PR-16). Il foglio le presenta comunque: è il salvataggio a non
/// essere offerto.
Future<void> showMeasurementDetail(BuildContext context, BodyMeasurement measurement) {
  if (measurement.editable) {
    return showMeasurementSheet(context, existing: measurement);
  }
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _MeasurementDetailSheet(measurement: measurement),
  );
}

class _MeasurementDetailSheet extends ConsumerWidget {
  const _MeasurementDetailSheet({required this.measurement});

  final BodyMeasurement measurement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    // LO-4, LO-7: presentazione nel sistema scelto, valori conservati in
    // chilogrammi e centimetri.
    final units = ref.watch(unitSystemProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(context, measurement.date),
                style: typography.titleMedium.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                context.l10n.measurementByNutritionist,
                style: typography.caption.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.md),
              if (measurement.weightKg != null)
                Text(
                  context.l10n.measureNamedValueWithUnit(
                    context.l10n.measureWeight,
                    formatDecimal(context, weightToDisplay(measurement.weightKg!, units)),
                    weightUnit(context, units),
                  ),
                  style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                ),
              for (final entry in measurement.circumferences.entries)
                Text(
                  context.l10n.measureNamedValueWithUnit(
                    bodyCircumferenceLabel(context, entry.$1),
                    formatDecimal(context, lengthToDisplay(entry.$2, units)),
                    lengthUnit(context, units),
                  ),
                  style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                ),
              if (measurement.note != null && measurement.note!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  measurement.note!,
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
