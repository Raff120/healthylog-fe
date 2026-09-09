import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/care_api.dart';
import '../data/care_models.dart';
import '../data/care_requests.dart';

part 'care_providers.g.dart';

@riverpod
CareApi careApi(Ref ref) => CareApi(ref.watch(apiClientProvider));

Duration? _noRetry(int retryCount, Object error) => null;

/// RG-4: il collegamento vigente dell'Utente in qualità di Paziente. Un
/// `RESOURCE_NOT_FOUND` (404) significa assenza di collegamento (RG-5,
/// 4.4 interfaccia.md), non un errore da segnalare — le schermate lo
/// distinguono leggendo il codice. `retry: null` per la stessa ragione
/// di `CurrentCookingGroup` (F20): l'assenza è l'esito più comune e
/// questo provider è osservato da punti pervasivi (*Piano*, gestione
/// dei piani) per le limitazioni del Paziente (UT-8).
@Riverpod(retry: _noRetry)
class CurrentCareLink extends _$CurrentCareLink {
  @override
  Future<CareLink> build() => ref.read(careApiProvider).getCurrentLink();
}

/// UT-8: il collegamento vigente come valore, `null` in assenza o
/// finché non è noto — mai un errore da propagare alle schermate che se
/// ne servono solo per decidere quali azioni offrire.
@riverpod
CareLink? currentCareLinkOrNull(Ref ref) => ref.watch(currentCareLinkProvider).value;

/// CP-10 (Utente) e VA-9 (Nutrizionista): richieste ricevute o inviate.
@riverpod
class CareLinkRequests extends _$CareLinkRequests {
  @override
  Future<List<CareLinkRequest>> build() => ref.read(careApiProvider).listRequests();
}

/// NU-1, VA-1, VA-4: l'elenco dei Pazienti nell'ordinamento scelto.
@riverpod
class Patients extends _$Patients {
  @override
  Future<List<PatientSummary>> build(PatientSort sort) => ref.read(careApiProvider).listPatients(sort);
}

/// VA-7: il dettaglio del Paziente, con i soli piani redatti dal
/// Nutrizionista (ST-16).
@riverpod
class PatientDetailController extends _$PatientDetailController {
  @override
  Future<PatientDetail> build(String patientId) => ref.read(careApiProvider).getPatient(patientId);
}

/// CP-1, CP-2: ricerca per nome utente esatto — `autoDispose`: non ha
/// senso conservarla oltre il foglio d'invito.
@riverpod
Future<UserLookup> userLookup(Ref ref, String username) => ref.read(careApiProvider).lookup(username);

/// CP-1, CP-3: invio della richiesta.
@riverpod
class SendCareLinkRequestController extends _$SendCareLinkRequestController {
  @override
  AsyncValue<CareLinkRequest>? build() => null;

  Future<void> send(String targetUserId, String? message) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(careApiProvider).sendRequest(CreateCareLinkRequest(targetUserId: targetUserId, message: message)),
    );
    if (state?.hasError == false) ref.invalidate(careLinkRequestsProvider);
  }
}

/// CP-4, CP-6, CP-8: accettazione, rifiuto e revoca della richiesta —
/// tutte ricaricano l'elenco; l'accettazione anche il collegamento
/// vigente (CP-11).
@riverpod
class CareLinkRequestActionController extends _$CareLinkRequestActionController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(action);
    if (state?.hasError == false) ref.invalidate(careLinkRequestsProvider);
  }

  Future<void> accept(String requestId) async {
    await _run(() => ref.read(careApiProvider).accept(requestId));
    if (state?.hasError == false) ref.invalidate(currentCareLinkProvider);
  }

  Future<void> reject(String requestId) => _run(() => ref.read(careApiProvider).reject(requestId));

  Future<void> withdraw(String requestId) => _run(() => ref.read(careApiProvider).withdraw(requestId));
}

/// CP-14, CP-15: revoca del collegamento, da entrambe le parti. Ricarica
/// tutto ciò che dipende dal collegamento: per il Paziente il proprio
/// (CP-19: riacquista le facoltà sul piano), per il Nutrizionista
/// l'elenco dei Pazienti.
@riverpod
class RevokeCareLinkController extends _$RevokeCareLinkController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> revoke(String careLinkId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(careApiProvider).revoke(careLinkId));
    if (state?.hasError == false) {
      ref.invalidate(currentCareLinkProvider);
      ref.invalidate(patientsProvider);
      ref.invalidate(patientDetailControllerProvider);
    }
  }
}
