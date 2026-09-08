// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(careApi)
final careApiProvider = CareApiProvider._();

final class CareApiProvider
    extends $FunctionalProvider<CareApi, CareApi, CareApi>
    with $Provider<CareApi> {
  CareApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'careApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$careApiHash();

  @$internal
  @override
  $ProviderElement<CareApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CareApi create(Ref ref) {
    return careApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CareApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CareApi>(value),
    );
  }
}

String _$careApiHash() => r'8cd4cdcd5f77dac23d3d5b35fc695993c6ddf4e7';

/// RG-4: il collegamento vigente dell'Utente in qualità di Paziente. Un
/// `RESOURCE_NOT_FOUND` (404) significa assenza di collegamento (RG-5,
/// 4.4 interfaccia.md), non un errore da segnalare — le schermate lo
/// distinguono leggendo il codice. `retry: null` per la stessa ragione
/// di `CurrentCookingGroup` (F20): l'assenza è l'esito più comune e
/// questo provider è osservato da punti pervasivi (*Piano*, gestione
/// dei piani) per le limitazioni del Paziente (UT-8).

@ProviderFor(CurrentCareLink)
final currentCareLinkProvider = CurrentCareLinkProvider._();

/// RG-4: il collegamento vigente dell'Utente in qualità di Paziente. Un
/// `RESOURCE_NOT_FOUND` (404) significa assenza di collegamento (RG-5,
/// 4.4 interfaccia.md), non un errore da segnalare — le schermate lo
/// distinguono leggendo il codice. `retry: null` per la stessa ragione
/// di `CurrentCookingGroup` (F20): l'assenza è l'esito più comune e
/// questo provider è osservato da punti pervasivi (*Piano*, gestione
/// dei piani) per le limitazioni del Paziente (UT-8).
final class CurrentCareLinkProvider
    extends $AsyncNotifierProvider<CurrentCareLink, CareLink> {
  /// RG-4: il collegamento vigente dell'Utente in qualità di Paziente. Un
  /// `RESOURCE_NOT_FOUND` (404) significa assenza di collegamento (RG-5,
  /// 4.4 interfaccia.md), non un errore da segnalare — le schermate lo
  /// distinguono leggendo il codice. `retry: null` per la stessa ragione
  /// di `CurrentCookingGroup` (F20): l'assenza è l'esito più comune e
  /// questo provider è osservato da punti pervasivi (*Piano*, gestione
  /// dei piani) per le limitazioni del Paziente (UT-8).
  CurrentCareLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'currentCareLinkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentCareLinkHash();

  @$internal
  @override
  CurrentCareLink create() => CurrentCareLink();
}

String _$currentCareLinkHash() => r'bf35a83f173749c4884af58f108940b1978e9792';

/// RG-4: il collegamento vigente dell'Utente in qualità di Paziente. Un
/// `RESOURCE_NOT_FOUND` (404) significa assenza di collegamento (RG-5,
/// 4.4 interfaccia.md), non un errore da segnalare — le schermate lo
/// distinguono leggendo il codice. `retry: null` per la stessa ragione
/// di `CurrentCookingGroup` (F20): l'assenza è l'esito più comune e
/// questo provider è osservato da punti pervasivi (*Piano*, gestione
/// dei piani) per le limitazioni del Paziente (UT-8).

abstract class _$CurrentCareLink extends $AsyncNotifier<CareLink> {
  FutureOr<CareLink> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CareLink>, CareLink>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CareLink>, CareLink>,
              AsyncValue<CareLink>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// UT-8: il collegamento vigente come valore, `null` in assenza o
/// finché non è noto — mai un errore da propagare alle schermate che se
/// ne servono solo per decidere quali azioni offrire.

@ProviderFor(currentCareLinkOrNull)
final currentCareLinkOrNullProvider = CurrentCareLinkOrNullProvider._();

/// UT-8: il collegamento vigente come valore, `null` in assenza o
/// finché non è noto — mai un errore da propagare alle schermate che se
/// ne servono solo per decidere quali azioni offrire.

final class CurrentCareLinkOrNullProvider
    extends $FunctionalProvider<CareLink?, CareLink?, CareLink?>
    with $Provider<CareLink?> {
  /// UT-8: il collegamento vigente come valore, `null` in assenza o
  /// finché non è noto — mai un errore da propagare alle schermate che se
  /// ne servono solo per decidere quali azioni offrire.
  CurrentCareLinkOrNullProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentCareLinkOrNullProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentCareLinkOrNullHash();

  @$internal
  @override
  $ProviderElement<CareLink?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CareLink? create(Ref ref) {
    return currentCareLinkOrNull(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CareLink? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CareLink?>(value),
    );
  }
}

String _$currentCareLinkOrNullHash() =>
    r'de41cd6a57e424dda84bc58cbc6131311f01fd06';

/// CP-10 (Utente) e VA-9 (Nutrizionista): richieste ricevute o inviate.

@ProviderFor(CareLinkRequests)
final careLinkRequestsProvider = CareLinkRequestsProvider._();

/// CP-10 (Utente) e VA-9 (Nutrizionista): richieste ricevute o inviate.
final class CareLinkRequestsProvider
    extends $AsyncNotifierProvider<CareLinkRequests, List<CareLinkRequest>> {
  /// CP-10 (Utente) e VA-9 (Nutrizionista): richieste ricevute o inviate.
  CareLinkRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'careLinkRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$careLinkRequestsHash();

  @$internal
  @override
  CareLinkRequests create() => CareLinkRequests();
}

String _$careLinkRequestsHash() => r'75882cd18f37d28b4dd2b5a294df857b3d0606b2';

/// CP-10 (Utente) e VA-9 (Nutrizionista): richieste ricevute o inviate.

abstract class _$CareLinkRequests
    extends $AsyncNotifier<List<CareLinkRequest>> {
  FutureOr<List<CareLinkRequest>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<CareLinkRequest>>, List<CareLinkRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CareLinkRequest>>,
                List<CareLinkRequest>
              >,
              AsyncValue<List<CareLinkRequest>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// NU-1, VA-1, VA-4: l'elenco dei Pazienti nell'ordinamento scelto.

@ProviderFor(Patients)
final patientsProvider = PatientsFamily._();

/// NU-1, VA-1, VA-4: l'elenco dei Pazienti nell'ordinamento scelto.
final class PatientsProvider
    extends $AsyncNotifierProvider<Patients, List<PatientSummary>> {
  /// NU-1, VA-1, VA-4: l'elenco dei Pazienti nell'ordinamento scelto.
  PatientsProvider._({
    required PatientsFamily super.from,
    required PatientSort super.argument,
  }) : super(
         retry: null,
         name: r'patientsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$patientsHash();

  @override
  String toString() {
    return r'patientsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Patients create() => Patients();

  @override
  bool operator ==(Object other) {
    return other is PatientsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$patientsHash() => r'f37b794285763080a6c66c43d0258435b46d94f7';

/// NU-1, VA-1, VA-4: l'elenco dei Pazienti nell'ordinamento scelto.

final class PatientsFamily extends $Family
    with
        $ClassFamilyOverride<
          Patients,
          AsyncValue<List<PatientSummary>>,
          List<PatientSummary>,
          FutureOr<List<PatientSummary>>,
          PatientSort
        > {
  PatientsFamily._()
    : super(
        retry: null,
        name: r'patientsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// NU-1, VA-1, VA-4: l'elenco dei Pazienti nell'ordinamento scelto.

  PatientsProvider call(PatientSort sort) =>
      PatientsProvider._(argument: sort, from: this);

  @override
  String toString() => r'patientsProvider';
}

/// NU-1, VA-1, VA-4: l'elenco dei Pazienti nell'ordinamento scelto.

abstract class _$Patients extends $AsyncNotifier<List<PatientSummary>> {
  late final _$args = ref.$arg as PatientSort;
  PatientSort get sort => _$args;

  FutureOr<List<PatientSummary>> build(PatientSort sort);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<PatientSummary>>, List<PatientSummary>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PatientSummary>>,
                List<PatientSummary>
              >,
              AsyncValue<List<PatientSummary>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// VA-7: il dettaglio del Paziente, con i soli piani redatti dal
/// Nutrizionista (ST-16).

@ProviderFor(PatientDetailController)
final patientDetailControllerProvider = PatientDetailControllerFamily._();

/// VA-7: il dettaglio del Paziente, con i soli piani redatti dal
/// Nutrizionista (ST-16).
final class PatientDetailControllerProvider
    extends $AsyncNotifierProvider<PatientDetailController, PatientDetail> {
  /// VA-7: il dettaglio del Paziente, con i soli piani redatti dal
  /// Nutrizionista (ST-16).
  PatientDetailControllerProvider._({
    required PatientDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'patientDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$patientDetailControllerHash();

  @override
  String toString() {
    return r'patientDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PatientDetailController create() => PatientDetailController();

  @override
  bool operator ==(Object other) {
    return other is PatientDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$patientDetailControllerHash() =>
    r'79344c3f72ff3a20946b5258096b18255cd005d2';

/// VA-7: il dettaglio del Paziente, con i soli piani redatti dal
/// Nutrizionista (ST-16).

final class PatientDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PatientDetailController,
          AsyncValue<PatientDetail>,
          PatientDetail,
          FutureOr<PatientDetail>,
          String
        > {
  PatientDetailControllerFamily._()
    : super(
        retry: null,
        name: r'patientDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// VA-7: il dettaglio del Paziente, con i soli piani redatti dal
  /// Nutrizionista (ST-16).

  PatientDetailControllerProvider call(String patientId) =>
      PatientDetailControllerProvider._(argument: patientId, from: this);

  @override
  String toString() => r'patientDetailControllerProvider';
}

/// VA-7: il dettaglio del Paziente, con i soli piani redatti dal
/// Nutrizionista (ST-16).

abstract class _$PatientDetailController extends $AsyncNotifier<PatientDetail> {
  late final _$args = ref.$arg as String;
  String get patientId => _$args;

  FutureOr<PatientDetail> build(String patientId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PatientDetail>, PatientDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PatientDetail>, PatientDetail>,
              AsyncValue<PatientDetail>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// CP-1, CP-2: ricerca per nome utente esatto — `autoDispose`: non ha
/// senso conservarla oltre il foglio d'invito.

@ProviderFor(userLookup)
final userLookupProvider = UserLookupFamily._();

/// CP-1, CP-2: ricerca per nome utente esatto — `autoDispose`: non ha
/// senso conservarla oltre il foglio d'invito.

final class UserLookupProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserLookup>,
          UserLookup,
          FutureOr<UserLookup>
        >
    with $FutureModifier<UserLookup>, $FutureProvider<UserLookup> {
  /// CP-1, CP-2: ricerca per nome utente esatto — `autoDispose`: non ha
  /// senso conservarla oltre il foglio d'invito.
  UserLookupProvider._({
    required UserLookupFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userLookupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userLookupHash();

  @override
  String toString() {
    return r'userLookupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserLookup> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserLookup> create(Ref ref) {
    final argument = this.argument as String;
    return userLookup(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserLookupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userLookupHash() => r'17f7afec3c9f6fd9422d67d5ab0796b1109afaaf';

/// CP-1, CP-2: ricerca per nome utente esatto — `autoDispose`: non ha
/// senso conservarla oltre il foglio d'invito.

final class UserLookupFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserLookup>, String> {
  UserLookupFamily._()
    : super(
        retry: null,
        name: r'userLookupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// CP-1, CP-2: ricerca per nome utente esatto — `autoDispose`: non ha
  /// senso conservarla oltre il foglio d'invito.

  UserLookupProvider call(String username) =>
      UserLookupProvider._(argument: username, from: this);

  @override
  String toString() => r'userLookupProvider';
}

/// CP-1, CP-3: invio della richiesta.

@ProviderFor(SendCareLinkRequestController)
final sendCareLinkRequestControllerProvider =
    SendCareLinkRequestControllerProvider._();

/// CP-1, CP-3: invio della richiesta.
final class SendCareLinkRequestControllerProvider
    extends
        $NotifierProvider<
          SendCareLinkRequestController,
          AsyncValue<CareLinkRequest>?
        > {
  /// CP-1, CP-3: invio della richiesta.
  SendCareLinkRequestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendCareLinkRequestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendCareLinkRequestControllerHash();

  @$internal
  @override
  SendCareLinkRequestController create() => SendCareLinkRequestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CareLinkRequest>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CareLinkRequest>?>(value),
    );
  }
}

String _$sendCareLinkRequestControllerHash() =>
    r'b2523f22acc724187916e87bb0d038a6d2c52c01';

/// CP-1, CP-3: invio della richiesta.

abstract class _$SendCareLinkRequestController
    extends $Notifier<AsyncValue<CareLinkRequest>?> {
  AsyncValue<CareLinkRequest>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CareLinkRequest>?, AsyncValue<CareLinkRequest>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CareLinkRequest>?,
                AsyncValue<CareLinkRequest>?
              >,
              AsyncValue<CareLinkRequest>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// CP-4, CP-6, CP-8: accettazione, rifiuto e revoca della richiesta —
/// tutte ricaricano l'elenco; l'accettazione anche il collegamento
/// vigente (CP-11).

@ProviderFor(CareLinkRequestActionController)
final careLinkRequestActionControllerProvider =
    CareLinkRequestActionControllerProvider._();

/// CP-4, CP-6, CP-8: accettazione, rifiuto e revoca della richiesta —
/// tutte ricaricano l'elenco; l'accettazione anche il collegamento
/// vigente (CP-11).
final class CareLinkRequestActionControllerProvider
    extends
        $NotifierProvider<CareLinkRequestActionController, AsyncValue<void>?> {
  /// CP-4, CP-6, CP-8: accettazione, rifiuto e revoca della richiesta —
  /// tutte ricaricano l'elenco; l'accettazione anche il collegamento
  /// vigente (CP-11).
  CareLinkRequestActionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'careLinkRequestActionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$careLinkRequestActionControllerHash();

  @$internal
  @override
  CareLinkRequestActionController create() => CareLinkRequestActionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$careLinkRequestActionControllerHash() =>
    r'730b93b46db6d6911421ea22c0347db781ce8394';

/// CP-4, CP-6, CP-8: accettazione, rifiuto e revoca della richiesta —
/// tutte ricaricano l'elenco; l'accettazione anche il collegamento
/// vigente (CP-11).

abstract class _$CareLinkRequestActionController
    extends $Notifier<AsyncValue<void>?> {
  AsyncValue<void>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>?, AsyncValue<void>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>?, AsyncValue<void>?>,
              AsyncValue<void>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// CP-14, CP-15: revoca del collegamento, da entrambe le parti. Ricarica
/// tutto ciò che dipende dal collegamento: per il Paziente il proprio
/// (CP-19: riacquista le facoltà sul piano), per il Nutrizionista
/// l'elenco dei Pazienti.

@ProviderFor(RevokeCareLinkController)
final revokeCareLinkControllerProvider = RevokeCareLinkControllerProvider._();

/// CP-14, CP-15: revoca del collegamento, da entrambe le parti. Ricarica
/// tutto ciò che dipende dal collegamento: per il Paziente il proprio
/// (CP-19: riacquista le facoltà sul piano), per il Nutrizionista
/// l'elenco dei Pazienti.
final class RevokeCareLinkControllerProvider
    extends $NotifierProvider<RevokeCareLinkController, AsyncValue<void>?> {
  /// CP-14, CP-15: revoca del collegamento, da entrambe le parti. Ricarica
  /// tutto ciò che dipende dal collegamento: per il Paziente il proprio
  /// (CP-19: riacquista le facoltà sul piano), per il Nutrizionista
  /// l'elenco dei Pazienti.
  RevokeCareLinkControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revokeCareLinkControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$revokeCareLinkControllerHash();

  @$internal
  @override
  RevokeCareLinkController create() => RevokeCareLinkController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$revokeCareLinkControllerHash() =>
    r'6ad868f7c6903582afceaaa72275a18ba1e4a1b4';

/// CP-14, CP-15: revoca del collegamento, da entrambe le parti. Ricarica
/// tutto ciò che dipende dal collegamento: per il Paziente il proprio
/// (CP-19: riacquista le facoltà sul piano), per il Nutrizionista
/// l'elenco dei Pazienti.

abstract class _$RevokeCareLinkController extends $Notifier<AsyncValue<void>?> {
  AsyncValue<void>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>?, AsyncValue<void>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>?, AsyncValue<void>?>,
              AsyncValue<void>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
