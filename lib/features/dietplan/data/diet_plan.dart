import '../../identity/data/account_role.dart';
import 'plan_status.dart';
import 'slot_type.dart';
import 'weekday.dart';

/// Rispecchia `DietPlanSlotResponse` sul backend (GG-1).
class DietPlanSlot {
  const DietPlanSlot({
    required this.slotId,
    required this.type,
    required this.label,
    required this.order,
    required this.content,
    required this.note,
    required this.recipeName,
    required this.recipeText,
    required this.adherenceWeight,
  });

  factory DietPlanSlot.fromJson(Map<String, dynamic> json) => DietPlanSlot(
        slotId: json['slotId'] as String,
        type: SlotType.fromJson(json['type'] as String),
        label: json['label'] as String?,
        order: json['order'] as int,
        content: json['content'] as String?,
        note: json['note'] as String?,
        recipeName: json['recipeName'] as String?,
        recipeText: json['recipeText'] as String?,
        adherenceWeight: (json['adherenceWeight'] as num).toDouble(),
      );

  final String slotId;
  final SlotType type;
  final String? label;
  final int order;
  final String? content;
  final String? note;
  final String? recipeName;
  final String? recipeText;
  final double adherenceWeight;
}

/// Rispecchia `DietPlanWeekDayResponse` sul backend (OG-1).
class DietPlanWeekDay {
  const DietPlanWeekDay({required this.dayOfWeek, required this.slots});

  factory DietPlanWeekDay.fromJson(Map<String, dynamic> json) => DietPlanWeekDay(
        dayOfWeek: Weekday.fromJson(json['dayOfWeek'] as String),
        slots: (json['slots'] as List)
            .map((e) => DietPlanSlot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final Weekday dayOfWeek;
  final List<DietPlanSlot> slots;
}

/// Un periodo di svolgimento (CO-6) o di sospensione (CV-S3) del piano.
/// [endDate] assente indica un periodo tuttora in corso — è così che il
/// Paziente conosce, se Sospeso, la data da cui la sospensione decorre
/// (CV-15).
class DietPlanPeriod {
  const DietPlanPeriod({required this.startDate, required this.endDate});

  factory DietPlanPeriod.fromJson(Map<String, dynamic> json) => DietPlanPeriod(
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
      );

  final DateTime startDate;
  final DateTime? endDate;
}

/// Rispecchia `DietPlanResponse` sul backend (3.1 funzionale, CD-1, CD-4).
class DietPlan {
  const DietPlan({
    required this.id,
    required this.ownerId,
    required this.authorId,
    required this.authorRole,
    required this.name,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.periods,
    required this.suspensions,
    required this.weeklySchedule,
    required this.adherence,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) => DietPlan(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        authorId: json['authorId'] as String,
        authorRole: AccountRole.fromJson(json['authorRole'] as String),
        name: json['name'] as String,
        status: PlanStatus.fromJson(json['status'] as String),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
        periods: (json['periods'] as List? ?? const [])
            .map((e) => DietPlanPeriod.fromJson(e as Map<String, dynamic>))
            .toList(),
        suspensions: (json['suspensions'] as List? ?? const [])
            .map((e) => DietPlanPeriod.fromJson(e as Map<String, dynamic>))
            .toList(),
        weeklySchedule: (json['weeklySchedule'] as List)
            .map((e) => DietPlanWeekDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        adherence: (json['adherence'] as num?)?.toDouble(),
      );

  final String id;
  final String ownerId;
  final String authorId;
  final AccountRole authorRole;
  final String name;
  final PlanStatus status;
  final DateTime startDate;
  final DateTime? endDate;

  /// CO-6: i periodi di svolgimento attraversati. ST-8: il piano
  /// riattivato è voce unica dello storico, e sono questi a raccontarne la
  /// storia.
  final List<DietPlanPeriod> periods;

  /// CV-S3: i periodi di sospensione, esclusi da ogni calcolo di aderenza
  /// (AD-11).
  final List<DietPlanPeriod> suspensions;

  final List<DietPlanWeekDay> weeklySchedule;

  /// ST-2: il valore sintetico di aderenza, presente nel solo elenco e per
  /// i soli piani Conclusi. AD-1ter: percentuale non arrotondata.
  final double? adherence;

  /// ST-8, ST-9: il piano è stato riattivato e ha attraversato più periodi.
  bool get hasMultiplePeriods => periods.length > 1;
}
