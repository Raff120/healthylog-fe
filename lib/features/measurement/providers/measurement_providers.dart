import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/measurement_api.dart';
import '../data/measurement_models.dart';
import '../data/measurement_requests.dart';
import '../../statistics/providers/statistics_providers.dart';

part 'measurement_providers.g.dart';

@riverpod
MeasurementApi measurementApi(Ref ref) => MeasurementApi(ref.watch(apiClientProvider));

/// AN-4: le proprie misurazioni, in ordine cronologico decrescente.
@riverpod
class Measurements extends _$Measurements {
  @override
  Future<List<BodyMeasurement>> build() => ref.read(measurementApiProvider).list();
}

/// NU-4, CS-14: le misurazioni di un Paziente — quelle dei periodi di
/// titolarità e quelle registrate dal Nutrizionista stesso.
@riverpod
class PatientMeasurements extends _$PatientMeasurements {
  @override
  Future<List<BodyMeasurement>> build(String patientId) =>
      ref.read(measurementApiProvider).list(userId: patientId);
}

/// PR-11, PR-16, NU-12: registrazione, modifica ed eliminazione.
@riverpod
class MeasurementController extends _$MeasurementController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> create(CreateBodyMeasurementRequest request) =>
      _run(() => ref.read(measurementApiProvider).create(request), request.userId);

  Future<void> update(String id, UpdateBodyMeasurementRequest request, {String? patientId}) =>
      _run(() => ref.read(measurementApiProvider).update(id, request), patientId);

  Future<void> delete(String id, {String? patientId}) =>
      _run(() => ref.read(measurementApiProvider).delete(id), patientId);

  Future<void> _run(Future<void> Function() operation, String? patientId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(operation);
    if (state?.hasError ?? true) return;
    ref.invalidate(measurementsProvider);
    if (patientId != null) ref.invalidate(patientMeasurementsProvider(patientId));
    // 11.3: le misure si registrano ora dal segmento *Corpo*, che le
    // legge dalle statistiche e dall'elenco del periodo — non da
    // `measurements`. Senza questa invalidazione la misurazione appena
    // registrata non comparirebbe dove la si è registrata. Le due
    // famiglie sono invalidate per intero: il criterio (periodo, piano,
    // soggetto) non è noto qui, e sono poche.
    ref.invalidate(measurementStatisticsProvider);
    ref.invalidate(periodMeasurementsProvider);
  }
}
