import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';
import '../data/care_models.dart';

/// VA-4: denominazione dei tre criteri di ordinamento dell'elenco dei
/// Pazienti, nella lingua selezionata (LO-1).
String patientSortLabel(BuildContext context, PatientSort sort) => switch (sort) {
      PatientSort.name => context.l10n.patientSortName,
      PatientSort.adherence => context.l10n.patientSortAdherence,
      PatientSort.activity => context.l10n.patientSortRecentActivity,
    };
