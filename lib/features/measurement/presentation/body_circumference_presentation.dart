import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';
import '../data/measurement_models.dart';

/// Denominazione della circonferenza (PR-12) nella lingua selezionata
/// (LO-1). Le stesse voci che le statistiche impiegano per le proprie
/// grandezze: una sola traduzione per "Vita", quale che sia la schermata.
String bodyCircumferenceLabel(BuildContext context, BodyCircumference circumference) =>
    switch (circumference) {
      BodyCircumference.waist => context.l10n.measureWaist,
      BodyCircumference.hips => context.l10n.measureHips,
      BodyCircumference.chest => context.l10n.measureChest,
      BodyCircumference.arm => context.l10n.measureArm,
      BodyCircumference.thigh => context.l10n.measureThigh,
    };
