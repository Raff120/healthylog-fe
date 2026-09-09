/// Corpo di `POST /diet-plan-templates` (TP-4, TP-7). `sourceTemplateId`
/// assente crea da zero, valorizzato deriva da un template proprio.
class CreateDietPlanTemplateRequest {
  const CreateDietPlanTemplateRequest({required this.name, this.description, this.sourceTemplateId});

  final String name;
  final String? description;
  final String? sourceTemplateId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'sourceTemplateId': sourceTemplateId,
      };
}

/// Corpo di `PATCH /diet-plan-templates/{id}` (TP-12).
class UpdateDietPlanTemplateRequest {
  const UpdateDietPlanTemplateRequest({required this.name, this.description});

  final String name;
  final String? description;

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
