import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../data/hydration_models.dart';
import '../../providers/hydration_providers.dart';
import '../hydration_formatting.dart';

/// AQ-8: il foglio della giornata, da cui si annulla una singola
/// aggiunta. È la ragione per cui i comandi rapidi registrano senza
/// conferma: un tocco involontario si disfa qui.
///
/// AQ-10: l'ora dell'aggiunta non vi compare — l'elenco è già in ordine
/// di registrazione, e quando si è bevuto non è dato che l'applicazione
/// tratti.
Future<void> showWaterDaySheet(BuildContext context, {required DateTime date}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _WaterDaySheet(date: date),
  );
}

class _WaterDaySheet extends ConsumerWidget {
  const _WaterDaySheet({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final units = ref.watch(unitSystemProvider);
    final day = ref.watch(waterIntakeDayProvider(date)).value ?? WaterIntakeDay.empty(date);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.waterDayEntries,
                style: typography.titleMedium.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              if (day.entries.isEmpty)
                Text(
                  context.l10n.waterNoEntries,
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                )
              else
                for (final entry in day.entries)
                  _EntryRow(
                    key: ValueKey('waterEntry-${entry.entryId}'),
                    label: formatVolume(context, entry.amountMl, units),
                    onRemove: () {
                      ref
                          .read(waterIntakeControllerProvider.notifier)
                          .removeEntry(date, entry.entryId);
                      // L'ultima aggiunta annullata lascia il foglio senza
                      // oggetto: si chiude da sé anziché restare vuoto.
                      if (day.entries.length == 1) Navigator.of(context).pop();
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(Icons.water_drop_outlined, size: 20, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(label, style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            iconSize: 20,
            color: colors.textSecondary,
            tooltip: context.l10n.waterRemoveEntry,
          ),
        ],
      ),
    );
  }
}
