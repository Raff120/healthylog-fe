import '../../dietplan/data/slot_type.dart';
import '../../identity/data/account_role.dart';
import '../../workout/data/workout_models.dart' show Weekday;

/// Orizzonte di calcolo delle statistiche (AD-8, SA-10, AN-13): settimana,
/// mese o intero piano. AD-10: l'intervallo personalizzato non è previsto
/// in v1.
///
/// Le denominazioni non sono qui ma in
/// `presentation/statistics_presentation.dart`: dipendono dalla lingua
/// selezionata (LO-1) e l'enumerativo non deve conoscerla.
enum StatisticsPeriod {
  week('WEEK'),
  month('MONTH'),
  plan('PLAN');

  const StatisticsPeriod(this.param);

  final String param;

  static StatisticsPeriod fromParam(String value) =>
      StatisticsPeriod.values.firstWhere((period) => period.param == value, orElse: () => StatisticsPeriod.week);
}

/// Grandezza corporea di cui è consultabile l'andamento (AN-1), come la
/// scrive il backend (`it.healthylog.model.BodyMeasure`).
///
/// Le denominazioni non sono qui ma in
/// `presentation/statistics_presentation.dart` (LO-1).
enum BodyMeasure {
  weight('WEIGHT'),
  waist('WAIST'),
  hips('HIPS'),
  chest('CHEST'),
  arm('ARM'),
  thigh('THIGH');

  const BodyMeasure(this.param);

  final String param;

  static BodyMeasure fromJson(String value) =>
      BodyMeasure.values.firstWhere((measure) => measure.param == value);

  /// AN-6, AN-7: la linea di riferimento del peso obiettivo riguarda il
  /// solo peso, non le circonferenze.
  bool get hasTarget => this == BodyMeasure.weight;
}

/// Una voce di disaggregazione dell'aderenza (AD-13): [value] assente è
/// assenza di dati (AD-4), non zero.
class AdherenceBucket {
  const AdherenceBucket({required this.key, required this.value});

  factory AdherenceBucket.fromJson(Map<String, dynamic> json) => AdherenceBucket(
        key: json['key'] as String,
        value: (json['value'] as num?)?.toDouble(),
      );

  final String key;
  final double? value;

  SlotType get slotType => SlotType.fromJson(key);

  Weekday get weekday => Weekday.fromJson(key);
}

/// Un punto dell'andamento settimanale (AD-14): il lunedì che apre la
/// settimana (LO-11) e il valore, assente se priva di dati.
class AdherenceWeek {
  const AdherenceWeek({required this.weekStart, required this.value});

  factory AdherenceWeek.fromJson(Map<String, dynamic> json) => AdherenceWeek(
        weekStart: DateTime.parse(json['weekStart'] as String),
        value: (json['value'] as num?)?.toDouble(),
      );

  final DateTime weekStart;
  final double? value;
}

/// Un periodo di svolgimento del piano con la propria aderenza (ST-9,
/// ST-10). [endDate] assente indica il periodo tuttora in corso.
class AdherencePeriod {
  const AdherencePeriod({required this.startDate, required this.endDate, required this.value});

  factory AdherencePeriod.fromJson(Map<String, dynamic> json) => AdherencePeriod(
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
        value: (json['value'] as num?)?.toDouble(),
      );

  final DateTime startDate;
  final DateTime? endDate;
  final double? value;
}

/// Rispecchia `AdherenceResponse` sul backend (8.2 funzionale).
///
/// AD-4: [value] assente è assenza di dati valutabili, non zero per cento.
/// AD-1ter: percentuale non arrotondata — l'arrotondamento all'intero più
/// prossimo avviene qui, in presentazione, e solo lì.
class AdherenceStatistics {
  const AdherenceStatistics({
    required this.period,
    required this.from,
    required this.to,
    required this.planId,
    required this.planName,
    required this.value,
    required this.suspendedDays,
    required this.uncoveredDays,
    required this.bySlotType,
    required this.byWeekday,
    required this.weekly,
    required this.periods,
  });

  factory AdherenceStatistics.fromJson(Map<String, dynamic> json) => AdherenceStatistics(
        period: StatisticsPeriod.fromParam(json['period'] as String),
        from: DateTime.parse(json['from'] as String),
        to: DateTime.parse(json['to'] as String),
        planId: json['planId'] as String?,
        planName: json['planName'] as String?,
        value: (json['value'] as num?)?.toDouble(),
        suspendedDays: (json['suspendedDays'] as num).toInt(),
        uncoveredDays: (json['uncoveredDays'] as num).toInt(),
        bySlotType: (json['bySlotType'] as List)
            .map((e) => AdherenceBucket.fromJson(e as Map<String, dynamic>))
            .toList(),
        byWeekday: (json['byWeekday'] as List)
            .map((e) => AdherenceBucket.fromJson(e as Map<String, dynamic>))
            .toList(),
        weekly: (json['weekly'] as List)
            .map((e) => AdherenceWeek.fromJson(e as Map<String, dynamic>))
            .toList(),
        periods: (json['periods'] as List)
            .map((e) => AdherencePeriod.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final StatisticsPeriod period;
  final DateTime from;
  final DateTime to;
  final String? planId;
  final String? planName;
  final double? value;

  /// AD-12: giorni dell'intervallo osservato esclusi dal calcolo perché
  /// il piano era sospeso.
  final int suspendedDays;

  /// AD-12: giorni dell'intervallo osservato privi di piano.
  final int uncoveredDays;

  final List<AdherenceBucket> bySlotType;
  final List<AdherenceBucket> byWeekday;
  final List<AdherenceWeek> weekly;
  final List<AdherencePeriod> periods;

  bool get hasData => value != null;

  bool get hasExcludedDays => suspendedDays > 0 || uncoveredDays > 0;

  /// ST-8, ST-10: il piano ha attraversato più periodi di svolgimento, e i
  /// due calcoli — complessivo e per singolo periodo — non sono omogenei.
  bool get hasMultiplePeriods => periods.length > 1;
}

/// Un tipo di attività con il numero di sessioni svolte (SA-2).
class ActivityTypeCount {
  const ActivityTypeCount({required this.activityType, required this.count});

  factory ActivityTypeCount.fromJson(Map<String, dynamic> json) => ActivityTypeCount(
        activityType: json['activityType'] as String,
        count: (json['count'] as num).toInt(),
      );

  final String activityType;
  final int count;
}

/// Un punto dell'andamento settimanale degli allenamenti (SA-11), con
/// l'obiettivo allora vigente (SA-12).
class WorkoutWeek {
  const WorkoutWeek({required this.weekStart, required this.count, required this.goal});

  factory WorkoutWeek.fromJson(Map<String, dynamic> json) => WorkoutWeek(
        weekStart: DateTime.parse(json['weekStart'] as String),
        count: (json['count'] as num).toInt(),
        goal: (json['goal'] as num?)?.toInt(),
      );

  final DateTime weekStart;
  final int count;
  final int? goal;
}

/// Rispecchia `WorkoutStatisticsResponse` sul backend (8.3 funzionale).
///
/// CB-9, SA-8: nessun campo reca le calorie bruciate. SA-6: [goal] assente
/// significa che il confronto non si presenta, e nulla segnala che manchi.
class WorkoutStatistics {
  const WorkoutStatistics({
    required this.period,
    required this.from,
    required this.to,
    required this.planId,
    required this.planName,
    required this.total,
    required this.byActivityType,
    required this.goal,
    required this.goalDone,
    required this.goalWeeks,
    required this.planned,
    required this.plannedDone,
    required this.suspendedDays,
    required this.uncoveredDays,
    required this.weekly,
  });

  factory WorkoutStatistics.fromJson(Map<String, dynamic> json) => WorkoutStatistics(
        period: StatisticsPeriod.fromParam(json['period'] as String),
        from: DateTime.parse(json['from'] as String),
        to: DateTime.parse(json['to'] as String),
        planId: json['planId'] as String?,
        planName: json['planName'] as String?,
        total: (json['total'] as num).toInt(),
        byActivityType: (json['byActivityType'] as List)
            .map((e) => ActivityTypeCount.fromJson(e as Map<String, dynamic>))
            .toList(),
        goal: (json['goal'] as num?)?.toInt(),
        goalDone: (json['goalDone'] as num?)?.toInt(),
        goalWeeks: (json['goalWeeks'] as num).toInt(),
        planned: (json['planned'] as num).toInt(),
        plannedDone: (json['plannedDone'] as num).toInt(),
        suspendedDays: (json['suspendedDays'] as num).toInt(),
        uncoveredDays: (json['uncoveredDays'] as num).toInt(),
        weekly: (json['weekly'] as List)
            .map((e) => WorkoutWeek.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final StatisticsPeriod period;
  final DateTime from;
  final DateTime to;
  final String? planId;
  final String? planName;
  final int total;
  final List<ActivityTypeCount> byActivityType;
  final int? goal;
  final int? goalDone;
  final int goalWeeks;
  final int planned;
  final int plannedDone;
  final int suspendedDays;
  final int uncoveredDays;
  final List<WorkoutWeek> weekly;

  /// SA-6, OS-3: in assenza di obiettivo la sezione non compare.
  bool get hasGoal => goal != null && goalDone != null;

  /// SA-15: sull'orizzonte del piano la divergenza rispetto all'aderenza
  /// va resa evidente.
  bool get divergesFromAdherence => period == StatisticsPeriod.plan && suspendedDays > 0;
}

/// Un valore rilevato in una data (AN-3), con la fonte che grafico ed
/// elenco distinguono visivamente (AN-5).
class MeasurePoint {
  const MeasurePoint({required this.date, required this.value, required this.source});

  factory MeasurePoint.fromJson(Map<String, dynamic> json) => MeasurePoint(
        date: DateTime.parse(json['date'] as String),
        value: (json['value'] as num).toDouble(),
        source: AccountRole.fromJson(json['source'] as String),
      );

  final DateTime date;
  final double value;
  final AccountRole source;

  bool get fromNutritionist => source == AccountRole.nutritionist;
}

/// La serie di una grandezza nel periodo (AN-1, AN-2) con la variazione
/// rispetto al primo valore (AN-10).
class MeasureSeries {
  const MeasureSeries({
    required this.measure,
    required this.points,
    required this.change,
  });

  factory MeasureSeries.fromJson(Map<String, dynamic> json) => MeasureSeries(
        measure: BodyMeasure.fromJson(json['measure'] as String),
        points: (json['points'] as List)
            .map((e) => MeasurePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        change: (json['change'] as num?)?.toDouble(),
      );

  final BodyMeasure measure;
  final List<MeasurePoint> points;

  /// AN-10: differenza rispetto al primo valore, assente con meno di due
  /// valori. AN-11: reca il proprio segno e nessuna qualificazione.
  final double? change;
}

/// Rispecchia `MeasurementStatisticsResponse` sul backend (8.4 funzionale).
class MeasurementStatistics {
  const MeasurementStatistics({
    required this.period,
    required this.from,
    required this.to,
    required this.planId,
    required this.planName,
    required this.targetWeightKg,
    required this.series,
  });

  factory MeasurementStatistics.fromJson(Map<String, dynamic> json) => MeasurementStatistics(
        period: StatisticsPeriod.fromParam(json['period'] as String),
        from: DateTime.parse(json['from'] as String),
        to: DateTime.parse(json['to'] as String),
        planId: json['planId'] as String?,
        planName: json['planName'] as String?,
        targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
        series: (json['series'] as List)
            .map((e) => MeasureSeries.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final StatisticsPeriod period;
  final DateTime from;
  final DateTime to;
  final String? planId;
  final String? planName;

  /// AN-6, AN-8: la linea di riferimento del grafico del peso; assente,
  /// semplicemente non compare.
  final double? targetWeightKg;

  final List<MeasureSeries> series;
}
