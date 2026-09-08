import 'plan_day.dart';
import 'plan_day_coverage.dart';

/// Giornata di un membro nella modalità affiancata (VG-12, VG-14).
/// Rispecchia `MemberPlanDayResponse` sul backend: gli slot sono privi
/// del testo di sostituzione, anche per la propria colonna (6.3
/// interfaccia.md).
class MemberPlanDay {
  const MemberPlanDay({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.date,
    required this.coverage,
    required this.planId,
    required this.planName,
    required this.planStartDate,
    required this.planEndDate,
    required this.slots,
  });

  factory MemberPlanDay.fromJson(Map<String, dynamic> json) => MemberPlanDay(
    userId: json['userId'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
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

  final String userId;
  final String firstName;
  final String lastName;
  final DateTime date;
  final PlanDayCoverage coverage;
  final String? planId;
  final String? planName;
  final DateTime? planStartDate;
  final DateTime? planEndDate;
  final List<PlanDaySlot> slots;
}

/// Rispecchia `GroupPlanDayResponse` sul backend (VG-12, VG-14):
/// l'ordine dei membri è quello del Gruppo (anzianità di appartenenza).
class GroupPlanDay {
  const GroupPlanDay({required this.date, required this.members});

  factory GroupPlanDay.fromJson(Map<String, dynamic> json) => GroupPlanDay(
    date: DateTime.parse(json['date'] as String),
    members: (json['members'] as List)
        .map((e) => MemberPlanDay.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final DateTime date;
  final List<MemberPlanDay> members;
}
