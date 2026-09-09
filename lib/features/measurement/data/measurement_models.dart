import '../../identity/data/account_role.dart';

/// Le circonferenze corporee previste da PR-12, nel loro ordine.
enum BodyCircumference { waist, hips, chest, arm, thigh }

/// Circonferenze corporee in centimetri (PR-12), tutte facoltative.
class BodyCircumferences {
  const BodyCircumferences({this.waist, this.hips, this.chest, this.arm, this.thigh});

  factory BodyCircumferences.fromJson(Map<String, dynamic>? json) => json == null
      ? const BodyCircumferences()
      : BodyCircumferences(
          waist: (json['waist'] as num?)?.toDouble(),
          hips: (json['hips'] as num?)?.toDouble(),
          chest: (json['chest'] as num?)?.toDouble(),
          arm: (json['arm'] as num?)?.toDouble(),
          thigh: (json['thigh'] as num?)?.toDouble(),
        );

  final double? waist;
  final double? hips;
  final double? chest;
  final double? arm;
  final double? thigh;

  bool get isEmpty => waist == null && hips == null && chest == null && arm == null && thigh == null;

  Map<String, dynamic> toJson() => {
        'waist': waist,
        'hips': hips,
        'chest': chest,
        'arm': arm,
        'thigh': thigh,
      };

  /// 10.3 interfaccia.md: le circonferenze rilevate in forma sintetica,
  /// nell'ordine di PR-12. La denominazione non è qui ma in
  /// `presentation/body_circumference_presentation.dart`: dipende dalla
  /// lingua selezionata (LO-1).
  List<(BodyCircumference, double)> get entries => [
        if (waist != null) (BodyCircumference.waist, waist!),
        if (hips != null) (BodyCircumference.hips, hips!),
        if (chest != null) (BodyCircumference.chest, chest!),
        if (arm != null) (BodyCircumference.arm, arm!),
        if (thigh != null) (BodyCircumference.thigh, thigh!),
      ];
}

/// Rispecchia `BodyMeasurementResponse` sul backend (PR-11, CO-13).
class BodyMeasurement {
  const BodyMeasurement({
    required this.id,
    required this.userId,
    required this.date,
    required this.weightKg,
    required this.circumferences,
    required this.note,
    required this.recordedByRole,
    required this.editable,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) => BodyMeasurement(
        id: json['id'] as String,
        userId: json['userId'] as String,
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        circumferences: BodyCircumferences.fromJson(json['circumferences'] as Map<String, dynamic>?),
        note: json['note'] as String?,
        recordedByRole: AccountRole.fromJson(json['recordedByRole'] as String),
        editable: json['editable'] as bool? ?? false,
      );

  final String id;
  final String userId;
  final DateTime date;
  final double? weightKg;
  final BodyCircumferences circumferences;
  final String? note;

  /// AN-5, PR-17: la fonte, che l'elenco distingue visivamente.
  final AccountRole recordedByRole;

  /// PR-17: falso sulle misurazioni del professionista viste dal Paziente
  /// — le consulta ma non le modifica né le elimina.
  final bool editable;

  bool get fromNutritionist => recordedByRole == AccountRole.nutritionist;
}
