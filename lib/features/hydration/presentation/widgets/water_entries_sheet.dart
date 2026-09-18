import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/formats.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../providers/hydration_providers.dart';
import '../hydration_formatting.dart';
import 'water_confirmations.dart';

/// Elenco delle aggiunte dell'orizzonte, raccolte per giornata, ciascuna
/// col proprio comando di rimozione (AQ-8, AQ-28; 11.1 interfaccia.md).
///
/// È l'**unico luogo da cui si rettifica**: la vista giornaliera offre
/// l'aggiunta e non la correzione, e il comando sta qui perché è qui che
/// ci si accorge dell'errore — guardando il giorno che non torna.
///
/// AQ-10: l'ora dell'aggiunta non compare; l'ordine è quello di
/// registrazione. AQ-28bis: il foglio è riservato all'Utente sui propri
/// dati — il chiamante non lo offre nel dettaglio del Paziente.
Future<void> showWaterEntriesSheet(
  BuildContext context, {
  required DateTime from,
  required DateTime to,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _WaterEntriesSheet(from: from, to: to),
  );
}

class _WaterEntriesSheet extends ConsumerWidget {
  const _WaterEntriesSheet({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final units = ref.watch(unitSystemProvider);
    final days = ref.watch(waterIntakeDaysProvider((from: from, to: to)));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          // Un mese di aggiunte è elenco lungo: il foglio si ferma a metà
          // schermata e scorre, anziché coprirla tutta (4.5).
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
                child: Text(
                  context.l10n.waterEntriesTitle,
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
              ),
              Flexible(
                child: days.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      context.l10n.waterNoEntries,
                      style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  data: (data) {
                    final withEntries =
                        data.where((day) => day.entries.isNotEmpty).toList().reversed.toList();
                    if (withEntries.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          context.l10n.waterNoEntries,
                          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                        ),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                      children: [
                        // Dalla giornata più recente: è là che si cerca
                        // l'errore appena commesso.
                        for (final day in withEntries) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: AppSpacing.sm, bottom: AppSpacing.xxs),
                            child: Text(
                              formatDate(context, day.date),
                              style: typography.overline.copyWith(color: colors.textTertiary),
                            ),
                          ),
                          for (final entry in day.entries)
                            _EntryRow(
                              key: ValueKey('waterEntry-${entry.entryId}'),
                              label: formatVolume(context, entry.amountMl, units),
                              // 4.5: conferma semplice. La rimozione è
                              // rifacibile — si riaggiunge la quantità —
                              // ma non si torna indietro dal tocco, ed è
                              // il livello dell'eliminazione di un
                              // allenamento o di una misurazione.
                              onRemove: () async {
                                final amount = formatVolume(context, entry.amountMl, units);
                                if (!await confirmRemoveWaterEntry(context, amount)) return;
                                await ref
                                    .read(waterIntakeControllerProvider.notifier)
                                    .removeEntry(day.date, entry.entryId);
                              },
                            ),
                        ],
                      ],
                    );
                  },
                ),
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

    return Row(
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
    );
  }
}
