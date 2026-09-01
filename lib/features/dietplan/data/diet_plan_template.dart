import 'diet_plan.dart';

/// Rispecchia `DietPlanTemplateResponse` sul backend (3.3 funzionale, CO-8).
class DietPlanTemplate {
  const DietPlanTemplate({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.notes,
    required this.weeklySchedule,
    required this.updatedAt,
  });

  factory DietPlanTemplate.fromJson(Map<String, dynamic> json) => DietPlanTemplate(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        notes: json['notes'] as String?,
        weeklySchedule: (json['weeklySchedule'] as List)
            .map((e) => DietPlanWeekDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? notes;
  final List<DietPlanWeekDay> weeklySchedule;
  final DateTime updatedAt;
}

/// Rispecchia `DietPlanTemplateSummaryResponse` (CT-2): voce dell'elenco,
/// senza lo schema settimanale (CT-4, solo in anteprima).
class DietPlanTemplateSummary {
  const DietPlanTemplateSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.updatedAt,
  });

  factory DietPlanTemplateSummary.fromJson(Map<String, dynamic> json) => DietPlanTemplateSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String id;
  final String name;
  final String? description;
  final DateTime updatedAt;
}
