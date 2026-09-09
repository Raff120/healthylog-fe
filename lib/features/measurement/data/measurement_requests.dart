import 'measurement_models.dart';

String _isoDate(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

/// Corpo di `POST /body-measurements` (PR-11, NU-12). [userId] è
/// valorizzato dal solo Nutrizionista che registri per conto del proprio
/// Paziente.
class CreateBodyMeasurementRequest {
  const CreateBodyMeasurementRequest({
    required this.date,
    this.weightKg,
    this.circumferences = const BodyCircumferences(),
    this.note,
    this.userId,
  });

  final DateTime date;
  final double? weightKg;
  final BodyCircumferences circumferences;
  final String? note;
  final String? userId;

  Map<String, dynamic> toJson() => {
        'date': _isoDate(date),
        'weightKg': weightKg,
        'circumferences': circumferences.toJson(),
        'note': note,
        'userId': userId,
      };
}

/// Corpo di `PATCH /body-measurements/{id}` (PR-16): l'intero modulo — un
/// valore assente azzera quello registrato, purché almeno uno resti
/// (PR-13).
class UpdateBodyMeasurementRequest {
  const UpdateBodyMeasurementRequest({
    required this.date,
    this.weightKg,
    this.circumferences = const BodyCircumferences(),
    this.note,
  });

  final DateTime date;
  final double? weightKg;
  final BodyCircumferences circumferences;
  final String? note;

  Map<String, dynamic> toJson() => {
        'date': _isoDate(date),
        'weightKg': weightKg,
        'circumferences': circumferences.toJson(),
        'note': note,
      };
}
