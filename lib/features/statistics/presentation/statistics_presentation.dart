import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';
import '../../../l10n/unit_system.dart';
import '../../../l10n/units.dart';
import '../data/statistics_models.dart';

/// Denominazione dell'orizzonte di calcolo (AD-8) nella lingua
/// selezionata (LO-1).
String statisticsPeriodLabel(BuildContext context, StatisticsPeriod period) => switch (period) {
      StatisticsPeriod.week => context.l10n.periodWeek,
      StatisticsPeriod.month => context.l10n.periodMonth,
      StatisticsPeriod.plan => context.l10n.periodPlan,
    };

/// Denominazione della grandezza corporea (AN-1) nella lingua selezionata.
String bodyMeasureLabel(BuildContext context, BodyMeasure measure) => switch (measure) {
      BodyMeasure.weight => context.l10n.measureWeight,
      BodyMeasure.waist => context.l10n.measureWaist,
      BodyMeasure.hips => context.l10n.measureHips,
      BodyMeasure.chest => context.l10n.measureChest,
      BodyMeasure.arm => context.l10n.measureArm,
      BodyMeasure.thigh => context.l10n.measureThigh,
    };

/// LO-4, LO-7: il valore della grandezza nell'unità di presentazione. Il
/// peso passa per la conversione dei chilogrammi, le circonferenze per
/// quella dei centimetri; i dati restano quelli conservati.
double bodyMeasureToDisplay(BodyMeasure measure, double stored, UnitSystem system) =>
    measure == BodyMeasure.weight
        ? weightToDisplay(stored, system)
        : lengthToDisplay(stored, system);

/// Simbolo dell'unità propria della grandezza nel sistema scelto (AN-10,
/// LO-4). Il valore che il server accompagna alla serie non è impiegato:
/// esprime l'unità di conservazione, che è dato interno, non quella di
/// presentazione (vedi decisioni.md).
String bodyMeasureUnit(BuildContext context, BodyMeasure measure, UnitSystem system) =>
    measure == BodyMeasure.weight ? weightUnit(context, system) : lengthUnit(context, system);
