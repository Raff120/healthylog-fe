import 'plan_day_coverage.dart';
import 'slot_status.dart';
import 'slot_type.dart';

/// Rispecchia `PlanDaySlotResponse` sul backend (OG-2).
class PlanDaySlot {
  const PlanDaySlot({
    required this.slotId,
    required this.type,
    required this.label,
    required this.order,
    required this.content,
    required this.note,
    required this.recipeName,
    required this.recipeText,
    required this.status,
  });

  factory PlanDaySlot.fromJson(Map<String, dynamic> json) => PlanDaySlot(
    slotId: json['slotId'] as String,
    type: SlotType.fromJson(json['type'] as String),
    label: json['label'] as String?,
    order: json['order'] as int,
    content: json['content'] as String?,
    note: json['note'] as String?,
    recipeName: json['recipeName'] as String?,
    recipeText: json['recipeText'] as String?,
    status: SlotStatus.fromJson(json['status'] as String),
  );

  final String slotId;
  final SlotType type;
  final String? label;
  final int order;
  final String? content;
  final String? note;
  final String? recipeName;
  final String? recipeText;
  final SlotStatus status;

  /// Per la cache locale di sola lettura (PL-6, F14): mai inviato al
  /// backend, che ha le proprie rappresentazioni dedicate in scrittura
  /// (`UpdatePlanDaySlotStatusRequest`).
  Map<String, dynamic> toJson() => {
    'slotId': slotId,
    'type': type.toJson(),
    'label': label,
    'order': order,
    'content': content,
    'note': note,
    'recipeName': recipeName,
    'recipeText': recipeText,
    'status': status.toJson(),
  };
}

/// Rispecchia `PlanDayResponse` sul backend (6.1 funzionale, EP-3).
/// `planId`/`planName`/`planStartDate`/`planEndDate` sono `null` quando
/// `coverage` è [PlanDayCoverage.none] (PA-10).
class PlanDay {
  const PlanDay({
    required this.date,
    required this.coverage,
    required this.planId,
    required this.planName,
    required this.planStartDate,
    required this.planEndDate,
    required this.slots,
  });

  factory PlanDay.fromJson(Map<String, dynamic> json) => PlanDay(
    date: DateTime.parse(json['date'] as String),
    coverage: PlanDayCoverage.fromJson(json['coverage'] as String),
    planId: json['planId'] as String?,
    planName: json['planName'] as String?,
    planStartDate: json['planStartDate'] == null
        ? null
        : DateTime.parse(json['planStartDate'] as String),
    planEndDate: json['planEndDate'] == null
        ? null
        : DateTime.parse(json['planEndDate'] as String),
    slots: (json['slots'] as List)
        .map((e) => PlanDaySlot.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final DateTime date;
  final PlanDayCoverage coverage;
  final String? planId;
  final String? planName;
  final DateTime? planStartDate;
  final DateTime? planEndDate;
  final List<PlanDaySlot> slots;
}
