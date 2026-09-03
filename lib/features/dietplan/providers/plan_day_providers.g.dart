// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_day_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(planDayApi)
final planDayApiProvider = PlanDayApiProvider._();

final class PlanDayApiProvider
    extends $FunctionalProvider<PlanDayApi, PlanDayApi, PlanDayApi>
    with $Provider<PlanDayApi> {
  PlanDayApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDayApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDayApiHash();

  @$internal
  @override
  $ProviderElement<PlanDayApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlanDayApi create(Ref ref) {
    return planDayApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanDayApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanDayApi>(value),
    );
  }
}

String _$planDayApiHash() => r'6939ecb8c3fca2f9e6ec355ff49592abad02da0a';

@ProviderFor(planDayLocalCache)
final planDayLocalCacheProvider = PlanDayLocalCacheProvider._();

final class PlanDayLocalCacheProvider
    extends
        $FunctionalProvider<
          PlanDayLocalCache,
          PlanDayLocalCache,
          PlanDayLocalCache
        >
    with $Provider<PlanDayLocalCache> {
  PlanDayLocalCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDayLocalCacheProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDayLocalCacheHash();

  @$internal
  @override
  $ProviderElement<PlanDayLocalCache> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlanDayLocalCache create(Ref ref) {
    return planDayLocalCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanDayLocalCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanDayLocalCache>(value),
    );
  }
}

String _$planDayLocalCacheHash() => r'9f40431f7944289fa9ea3ef16bec4d7971c5567b';

/// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
/// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
/// a oggi (VG-19) sono task successivi, sullo stesso stato.
///
/// VS-14: è anche il riferimento temporale condiviso con la vista
/// settimanale, che ne deriva la settimana da mostrare
/// (`startOfWeek`) — un solo stato "che giorno stiamo guardando",
/// invece di uno per vista, così passare dall'una all'altra conserva il
/// riferimento senza alcun sincronismo esplicito.

@ProviderFor(SelectedDay)
final selectedDayProvider = SelectedDayProvider._();

/// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
/// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
/// a oggi (VG-19) sono task successivi, sullo stesso stato.
///
/// VS-14: è anche il riferimento temporale condiviso con la vista
/// settimanale, che ne deriva la settimana da mostrare
/// (`startOfWeek`) — un solo stato "che giorno stiamo guardando",
/// invece di uno per vista, così passare dall'una all'altra conserva il
/// riferimento senza alcun sincronismo esplicito.
final class SelectedDayProvider
    extends $NotifierProvider<SelectedDay, DateTime> {
  /// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
  /// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
  /// a oggi (VG-19) sono task successivi, sullo stesso stato.
  ///
  /// VS-14: è anche il riferimento temporale condiviso con la vista
  /// settimanale, che ne deriva la settimana da mostrare
  /// (`startOfWeek`) — un solo stato "che giorno stiamo guardando",
  /// invece di uno per vista, così passare dall'una all'altra conserva il
  /// riferimento senza alcun sincronismo esplicito.
  SelectedDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDayHash();

  @$internal
  @override
  SelectedDay create() => SelectedDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedDayHash() => r'889586dee26fe79298721e46dfb08bc5c8691310';

/// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
/// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
/// a oggi (VG-19) sono task successivi, sullo stesso stato.
///
/// VS-14: è anche il riferimento temporale condiviso con la vista
/// settimanale, che ne deriva la settimana da mostrare
/// (`startOfWeek`) — un solo stato "che giorno stiamo guardando",
/// invece di uno per vista, così passare dall'una all'altra conserva il
/// riferimento senza alcun sincronismo esplicito.

abstract class _$SelectedDay extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedPlanView)
final selectedPlanViewProvider = SelectedPlanViewProvider._();

final class SelectedPlanViewProvider
    extends $NotifierProvider<SelectedPlanView, PlanViewMode> {
  SelectedPlanViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedPlanViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedPlanViewHash();

  @$internal
  @override
  SelectedPlanView create() => SelectedPlanView();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanViewMode>(value),
    );
  }
}

String _$selectedPlanViewHash() => r'f5c9ab1f64ecd351494a6d8277f105df00ff5d90';

abstract class _$SelectedPlanView extends $Notifier<PlanViewMode> {
  PlanViewMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlanViewMode, PlanViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlanViewMode, PlanViewMode>,
              PlanViewMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data: ogni giorno visitato ha una propria
/// cache, così tornare a un giorno già consultato non richiede una nuova
/// richiesta.
///
/// Popola la cache locale di sola lettura a ogni lettura online riuscita
/// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
/// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
/// errore applicativo, che l'Utente deve continuare a vedere come tale.
/// Un errore di rete senza copia locale per quella data si propaga
/// invariato: non c'è nulla da mostrare, offline o online.

@ProviderFor(planDay)
final planDayProvider = PlanDayFamily._();

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data: ogni giorno visitato ha una propria
/// cache, così tornare a un giorno già consultato non richiede una nuova
/// richiesta.
///
/// Popola la cache locale di sola lettura a ogni lettura online riuscita
/// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
/// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
/// errore applicativo, che l'Utente deve continuare a vedere come tale.
/// Un errore di rete senza copia locale per quella data si propaga
/// invariato: non c'è nulla da mostrare, offline o online.

final class PlanDayProvider
    extends $FunctionalProvider<AsyncValue<PlanDay>, PlanDay, FutureOr<PlanDay>>
    with $FutureModifier<PlanDay>, $FutureProvider<PlanDay> {
  /// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
  /// sola lettura). `family` per data: ogni giorno visitato ha una propria
  /// cache, così tornare a un giorno già consultato non richiede una nuova
  /// richiesta.
  ///
  /// Popola la cache locale di sola lettura a ogni lettura online riuscita
  /// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
  /// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
  /// errore applicativo, che l'Utente deve continuare a vedere come tale.
  /// Un errore di rete senza copia locale per quella data si propaga
  /// invariato: non c'è nulla da mostrare, offline o online.
  PlanDayProvider._({
    required PlanDayFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'planDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$planDayHash();

  @override
  String toString() {
    return r'planDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlanDay> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PlanDay> create(Ref ref) {
    final argument = this.argument as DateTime;
    return planDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$planDayHash() => r'234dab9c2c2acc5721e6f6db90e1918e183d7bdd';

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data: ogni giorno visitato ha una propria
/// cache, così tornare a un giorno già consultato non richiede una nuova
/// richiesta.
///
/// Popola la cache locale di sola lettura a ogni lettura online riuscita
/// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
/// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
/// errore applicativo, che l'Utente deve continuare a vedere come tale.
/// Un errore di rete senza copia locale per quella data si propaga
/// invariato: non c'è nulla da mostrare, offline o online.

final class PlanDayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlanDay>, DateTime> {
  PlanDayFamily._()
    : super(
        retry: null,
        name: r'planDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
  /// sola lettura). `family` per data: ogni giorno visitato ha una propria
  /// cache, così tornare a un giorno già consultato non richiede una nuova
  /// richiesta.
  ///
  /// Popola la cache locale di sola lettura a ogni lettura online riuscita
  /// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
  /// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
  /// errore applicativo, che l'Utente deve continuare a vedere come tale.
  /// Un errore di rete senza copia locale per quella data si propaga
  /// invariato: non c'è nulla da mostrare, offline o online.

  PlanDayProvider call(DateTime date) =>
      PlanDayProvider._(argument: date, from: this);

  @override
  String toString() => r'planDayProvider';
}

/// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
/// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
/// lettura dalla cache locale: l'offline della v1 copre la sola
/// consultazione della vista giornaliera già scaricata (4.6, 6.1
/// interfaccia.md), non quella settimanale — vedi decisioni.md.

@ProviderFor(planDayRange)
final planDayRangeProvider = PlanDayRangeFamily._();

/// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
/// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
/// lettura dalla cache locale: l'offline della v1 copre la sola
/// consultazione della vista giornaliera già scaricata (4.6, 6.1
/// interfaccia.md), non quella settimanale — vedi decisioni.md.

final class PlanDayRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlanDay>>,
          List<PlanDay>,
          FutureOr<List<PlanDay>>
        >
    with $FutureModifier<List<PlanDay>>, $FutureProvider<List<PlanDay>> {
  /// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
  /// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
  /// lettura dalla cache locale: l'offline della v1 copre la sola
  /// consultazione della vista giornaliera già scaricata (4.6, 6.1
  /// interfaccia.md), non quella settimanale — vedi decisioni.md.
  PlanDayRangeProvider._({
    required PlanDayRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'planDayRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$planDayRangeHash();

  @override
  String toString() {
    return r'planDayRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PlanDay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlanDay>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return planDayRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanDayRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$planDayRangeHash() => r'91071bf80a0ae5ccc22b6e785e4562e1c5036d66';

/// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
/// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
/// lettura dalla cache locale: l'offline della v1 copre la sola
/// consultazione della vista giornaliera già scaricata (4.6, 6.1
/// interfaccia.md), non quella settimanale — vedi decisioni.md.

final class PlanDayRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PlanDay>>,
          (DateTime, DateTime)
        > {
  PlanDayRangeFamily._()
    : super(
        retry: null,
        name: r'planDayRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
  /// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
  /// lettura dalla cache locale: l'offline della v1 copre la sola
  /// consultazione della vista giornaliera già scaricata (4.6, 6.1
  /// interfaccia.md), non quella settimanale — vedi decisioni.md.

  PlanDayRangeProvider call(DateTime from, DateTime to) =>
      PlanDayRangeProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'planDayRangeProvider';
}

/// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
/// disposta dalla card del pasto. Nessuno stato locale da esporre: la
/// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
/// sullo stesso criterio già seguito da `DietPlanLifecycleController`
/// per l'elenco dei piani, invece di sostituirne il contenuto a mano.

@ProviderFor(PlanDaySlotStatusController)
final planDaySlotStatusControllerProvider =
    PlanDaySlotStatusControllerProvider._();

/// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
/// disposta dalla card del pasto. Nessuno stato locale da esporre: la
/// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
/// sullo stesso criterio già seguito da `DietPlanLifecycleController`
/// per l'elenco dei piani, invece di sostituirne il contenuto a mano.
final class PlanDaySlotStatusControllerProvider
    extends $NotifierProvider<PlanDaySlotStatusController, AsyncValue<void>?> {
  /// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
  /// disposta dalla card del pasto. Nessuno stato locale da esporre: la
  /// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
  /// sullo stesso criterio già seguito da `DietPlanLifecycleController`
  /// per l'elenco dei piani, invece di sostituirne il contenuto a mano.
  PlanDaySlotStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDaySlotStatusControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDaySlotStatusControllerHash();

  @$internal
  @override
  PlanDaySlotStatusController create() => PlanDaySlotStatusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$planDaySlotStatusControllerHash() =>
    r'ac8820d68aab42c31efadde1a47446d9d5381b0f';

/// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
/// disposta dalla card del pasto. Nessuno stato locale da esporre: la
/// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
/// sullo stesso criterio già seguito da `DietPlanLifecycleController`
/// per l'elenco dei piani, invece di sostituirne il contenuto a mano.

abstract class _$PlanDaySlotStatusController
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
