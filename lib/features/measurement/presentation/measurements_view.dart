import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/measurement_models.dart';
import '../providers/measurement_providers.dart';
import 'widgets/last_measurement_card.dart';
import 'widgets/measurement_list_tile.dart';
import 'widgets/measurement_sheet.dart';

/// Segmento **Misure** di *Attività* (10.3 interfaccia.md): l'ultima
/// misurazione in evidenza, l'elenco cronologico e — dalla schermata che
/// lo ospita — il pulsante mobile per la registrazione.
///
/// PR-15: il sistema non sollecita la registrazione né segnala l'assenza
/// di misurazioni recenti; lo stato vuoto è una constatazione (4.4).
class MeasurementsView extends ConsumerWidget {
  const MeasurementsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final measurements = ref.watch(measurementsProvider);

    return measurements.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          describeApiError(error.asApiException?.code ?? ''),
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ),
      data: (items) => items.isEmpty
          ? const EmptyStateView(
              icon: Icons.straighten_outlined,
              title: 'Nessuna misurazione registrata',
            )
          : _MeasurementsList(items: items),
    );
  }
}

class _MeasurementsList extends StatelessWidget {
  const _MeasurementsList({required this.items});

  final List<BodyMeasurement> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      itemCount: items.length + 1,
      separatorBuilder: (context, index) =>
          index == 0 ? const SizedBox.shrink() : Divider(height: 1, color: colors.dividerLight),
      itemBuilder: (context, index) {
        if (index == 0) return LastMeasurementCard(measurement: items.first);
        final measurement = items[index - 1];
        return MeasurementListTile(
          measurement: measurement,
          // PR-17: sulla misurazione del professionista il tocco apre la
          // sola consultazione — il foglio la presenta comunque, ed è il
          // salvataggio a non essere offerto.
          onTap: () => showMeasurementDetail(context, measurement),
        );
      },
    );
  }
}

/// PR-17, 10.3: le misurazioni rilevate dal professionista si consultano,
/// non si modificano; per le proprie il tocco conduce alla modifica
/// (PR-16).
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

class _MeasurementDetailSheet extends StatelessWidget {
  const _MeasurementDetailSheet({required this.measurement});

  final BodyMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

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
                formatMeasurementDate(measurement.date),
                style: typography.titleMedium.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Rilevata dal tuo nutrizionista.',
                style: typography.caption.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.md),
              if (measurement.weightKg != null)
                Text(
                  'Peso: ${formatMeasurementValue(measurement.weightKg!)} kg',
                  style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                ),
              for (final entry in measurement.circumferences.entries)
                Text(
                  '${entry.$1}: ${formatMeasurementValue(entry.$2)} cm',
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
