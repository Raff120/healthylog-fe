import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../identity/providers/profile_providers.dart';
import '../../providers/statistics_providers.dart';

/// AD-8quater, 11.1 interfaccia.md: la scelta delle date dell'orizzonte
/// *Intervallo*, con il selettore di date di sistema — dal selettore
/// dell'orizzonte e, scelto l'intervallo, dal tocco sul periodo nel
/// navigatore.
///
/// Si propongono i soli giorni fra la registrazione e oggi: prima non vi
/// sono dati, dopo non è ancora avvenuto nulla (AD-8bis). Restituisce
/// `false` se la scelta è annullata, e l'intervallo resta allora com'era.
Future<bool> pickStatisticsRange(BuildContext context, WidgetRef ref) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final registeredOn = ref.read(profileControllerProvider).value?.registeredOn;
  // Un profilo non ancora caricato, o un backend che non dichiari la
  // registrazione, non deve impedire la scelta.
  final first = registeredOn == null || registeredOn.isAfter(today) ? DateTime(2000) : registeredOn;
  final current = ref.read(selectedStatisticsRangeProvider);

  final picked = await showDateRangePicker(
    context: context,
    firstDate: first,
    lastDate: today,
    initialDateRange: current == null
        ? null
        : DateTimeRange(
            start: current.from.isBefore(first) ? first : current.from,
            end: current.to.isAfter(today) ? today : current.to,
          ),
  );
  if (picked == null || !context.mounted) return false;
  ref.read(selectedStatisticsRangeProvider.notifier).select(picked.start, picked.end);
  return true;
}
