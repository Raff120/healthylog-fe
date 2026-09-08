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

/// VG-7, VG-11: il membro del Gruppo di cui si consulta la giornata,
/// `null` per il proprio piano — il selettore dell'intestazione (4.2
/// interfaccia.md) è l'unico comando. Condiviso fra vista giornaliera e
/// settimanale, sullo stesso criterio di [SelectedDay].

@ProviderFor(SelectedGroupMember)
final selectedGroupMemberProvider = SelectedGroupMemberProvider._();

/// VG-7, VG-11: il membro del Gruppo di cui si consulta la giornata,
/// `null` per il proprio piano — il selettore dell'intestazione (4.2
/// interfaccia.md) è l'unico comando. Condiviso fra vista giornaliera e
/// settimanale, sullo stesso criterio di [SelectedDay].
final class SelectedGroupMemberProvider
    extends $NotifierProvider<SelectedGroupMember, String?> {
  /// VG-7, VG-11: il membro del Gruppo di cui si consulta la giornata,
  /// `null` per il proprio piano — il selettore dell'intestazione (4.2
  /// interfaccia.md) è l'unico comando. Condiviso fra vista giornaliera e
  /// settimanale, sullo stesso criterio di [SelectedDay].
  SelectedGroupMemberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedGroupMemberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedGroupMemberHash();

  @$internal
  @override
  SelectedGroupMember create() => SelectedGroupMember();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedGroupMemberHash() =>
    r'621ab76f8b193a9d60e7be111109f79c787b758a';

/// VG-7, VG-11: il membro del Gruppo di cui si consulta la giornata,
/// `null` per il proprio piano — il selettore dell'intestazione (4.2
/// interfaccia.md) è l'unico comando. Condiviso fra vista giornaliera e
/// settimanale, sullo stesso criterio di [SelectedDay].

abstract class _$SelectedGroupMember extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// VG-12: la modalità affiancata, indipendente da [SelectedGroupMember]
/// — disattivandola si torna esattamente al membro che era selezionato
/// prima (4.2 interfaccia.md: "il ritorno al membro singolo ripristina
/// l'ultimo selezionato"), senza alcuno stato aggiuntivo: la selezione
/// del singolo membro non viene mai toccata da questo notifier.

@ProviderFor(SideBySideMode)
final sideBySideModeProvider = SideBySideModeProvider._();

/// VG-12: la modalità affiancata, indipendente da [SelectedGroupMember]
/// — disattivandola si torna esattamente al membro che era selezionato
/// prima (4.2 interfaccia.md: "il ritorno al membro singolo ripristina
/// l'ultimo selezionato"), senza alcuno stato aggiuntivo: la selezione
/// del singolo membro non viene mai toccata da questo notifier.
final class SideBySideModeProvider
    extends $NotifierProvider<SideBySideMode, bool> {
  /// VG-12: la modalità affiancata, indipendente da [SelectedGroupMember]
  /// — disattivandola si torna esattamente al membro che era selezionato
  /// prima (4.2 interfaccia.md: "il ritorno al membro singolo ripristina
  /// l'ultimo selezionato"), senza alcuno stato aggiuntivo: la selezione
  /// del singolo membro non viene mai toccata da questo notifier.
  SideBySideModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sideBySideModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sideBySideModeHash();

  @$internal
  @override
  SideBySideMode create() => SideBySideMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sideBySideModeHash() => r'054a04e34c82532889afbe25b3767dca667125a4';

/// VG-12: la modalità affiancata, indipendente da [SelectedGroupMember]
/// — disattivandola si torna esattamente al membro che era selezionato
/// prima (4.2 interfaccia.md: "il ritorno al membro singolo ripristina
/// l'ultimo selezionato"), senza alcuno stato aggiuntivo: la selezione
/// del singolo membro non viene mai toccata da questo notifier.

abstract class _$SideBySideMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// CU-2, CU-3: se l'Utente autenticato è Cuoco del proprio Gruppo —
/// `false` in assenza di Gruppo o finché profilo e Gruppo non sono
/// ancora caricati, mai un errore da propagare qui.

@ProviderFor(isCook)
final isCookProvider = IsCookProvider._();

/// CU-2, CU-3: se l'Utente autenticato è Cuoco del proprio Gruppo —
/// `false` in assenza di Gruppo o finché profilo e Gruppo non sono
/// ancora caricati, mai un errore da propagare qui.

final class IsCookProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// CU-2, CU-3: se l'Utente autenticato è Cuoco del proprio Gruppo —
  /// `false` in assenza di Gruppo o finché profilo e Gruppo non sono
  /// ancora caricati, mai un errore da propagare qui.
  IsCookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isCookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isCookHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isCook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isCookHash() => r'52a1db8b379e43eb312182cd691c425a591df649';

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data e, VG-7, per membro: ogni giorno
/// visitato ha una propria cache, così tornare a un giorno già
/// consultato non richiede una nuova richiesta.
///
/// Popola la cache locale di sola lettura a ogni lettura online riuscita
/// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
/// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
/// errore applicativo, che l'Utente deve continuare a vedere come tale.
/// Un errore di rete senza copia locale per quella data si propaga
/// invariato: non c'è nulla da mostrare, offline o online.
///
/// [userId]: PL-6 riserva la cache al proprio piano — la giornata di un
/// altro membro del Gruppo (F20) non vi transita mai, né in scrittura né
/// in lettura, e un errore di rete si propaga senza alcun ripiego.

@ProviderFor(planDay)
final planDayProvider = PlanDayFamily._();

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data e, VG-7, per membro: ogni giorno
/// visitato ha una propria cache, così tornare a un giorno già
/// consultato non richiede una nuova richiesta.
///
/// Popola la cache locale di sola lettura a ogni lettura online riuscita
/// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
/// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
/// errore applicativo, che l'Utente deve continuare a vedere come tale.
/// Un errore di rete senza copia locale per quella data si propaga
/// invariato: non c'è nulla da mostrare, offline o online.
///
/// [userId]: PL-6 riserva la cache al proprio piano — la giornata di un
/// altro membro del Gruppo (F20) non vi transita mai, né in scrittura né
/// in lettura, e un errore di rete si propaga senza alcun ripiego.

final class PlanDayProvider
    extends $FunctionalProvider<AsyncValue<PlanDay>, PlanDay, FutureOr<PlanDay>>
    with $FutureModifier<PlanDay>, $FutureProvider<PlanDay> {
  /// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
  /// sola lettura). `family` per data e, VG-7, per membro: ogni giorno
  /// visitato ha una propria cache, così tornare a un giorno già
  /// consultato non richiede una nuova richiesta.
  ///
  /// Popola la cache locale di sola lettura a ogni lettura online riuscita
  /// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
  /// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
  /// errore applicativo, che l'Utente deve continuare a vedere come tale.
  /// Un errore di rete senza copia locale per quella data si propaga
  /// invariato: non c'è nulla da mostrare, offline o online.
  ///
  /// [userId]: PL-6 riserva la cache al proprio piano — la giornata di un
  /// altro membro del Gruppo (F20) non vi transita mai, né in scrittura né
  /// in lettura, e un errore di rete si propaga senza alcun ripiego.
  PlanDayProvider._({
    required PlanDayFamily super.from,
    required (DateTime, {String? userId}) super.argument,
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
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PlanDay> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PlanDay> create(Ref ref) {
    final argument = this.argument as (DateTime, {String? userId});
    return planDay(ref, argument.$1, userId: argument.userId);
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

String _$planDayHash() => r'b941cf4698b5cd803656f5bd00db1c63f6a1a967';

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data e, VG-7, per membro: ogni giorno
/// visitato ha una propria cache, così tornare a un giorno già
/// consultato non richiede una nuova richiesta.
///
/// Popola la cache locale di sola lettura a ogni lettura online riuscita
/// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
/// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
/// errore applicativo, che l'Utente deve continuare a vedere come tale.
/// Un errore di rete senza copia locale per quella data si propaga
/// invariato: non c'è nulla da mostrare, offline o online.
///
/// [userId]: PL-6 riserva la cache al proprio piano — la giornata di un
/// altro membro del Gruppo (F20) non vi transita mai, né in scrittura né
/// in lettura, e un errore di rete si propaga senza alcun ripiego.

final class PlanDayFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PlanDay>,
          (DateTime, {String? userId})
        > {
  PlanDayFamily._()
    : super(
        retry: null,
        name: r'planDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
  /// sola lettura). `family` per data e, VG-7, per membro: ogni giorno
  /// visitato ha una propria cache, così tornare a un giorno già
  /// consultato non richiede una nuova richiesta.
  ///
  /// Popola la cache locale di sola lettura a ogni lettura online riuscita
  /// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
  /// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
  /// errore applicativo, che l'Utente deve continuare a vedere come tale.
  /// Un errore di rete senza copia locale per quella data si propaga
  /// invariato: non c'è nulla da mostrare, offline o online.
  ///
  /// [userId]: PL-6 riserva la cache al proprio piano — la giornata di un
  /// altro membro del Gruppo (F20) non vi transita mai, né in scrittura né
  /// in lettura, e un errore di rete si propaga senza alcun ripiego.

  PlanDayProvider call(DateTime date, {String? userId}) =>
      PlanDayProvider._(argument: (date, userId: userId), from: this);

  @override
  String toString() => r'planDayProvider';
}

/// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
/// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
/// lettura dalla cache locale: l'offline della v1 copre la sola
/// consultazione della vista giornaliera già scaricata (4.6, 6.1
/// interfaccia.md), non quella settimanale — vedi decisioni.md.
///
/// [userId]: come in [planDay] (VG-7, VS-17).

@ProviderFor(planDayRange)
final planDayRangeProvider = PlanDayRangeFamily._();

/// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
/// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
/// lettura dalla cache locale: l'offline della v1 copre la sola
/// consultazione della vista giornaliera già scaricata (4.6, 6.1
/// interfaccia.md), non quella settimanale — vedi decisioni.md.
///
/// [userId]: come in [planDay] (VG-7, VS-17).

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
  ///
  /// [userId]: come in [planDay] (VG-7, VS-17).
  PlanDayRangeProvider._({
    required PlanDayRangeFamily super.from,
    required (DateTime, DateTime, {String? userId}) super.argument,
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
    final argument = this.argument as (DateTime, DateTime, {String? userId});
    return planDayRange(ref, argument.$1, argument.$2, userId: argument.userId);
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

String _$planDayRangeHash() => r'8b4cf8a24a53d4a2c927476a86e5d13c7284bfd5';

/// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
/// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
/// lettura dalla cache locale: l'offline della v1 copre la sola
/// consultazione della vista giornaliera già scaricata (4.6, 6.1
/// interfaccia.md), non quella settimanale — vedi decisioni.md.
///
/// [userId]: come in [planDay] (VG-7, VS-17).

final class PlanDayRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PlanDay>>,
          (DateTime, DateTime, {String? userId})
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
  ///
  /// [userId]: come in [planDay] (VG-7, VS-17).

  PlanDayRangeProvider call(DateTime from, DateTime to, {String? userId}) =>
      PlanDayRangeProvider._(argument: (from, to, userId: userId), from: this);

  @override
  String toString() => r'planDayRangeProvider';
}

/// VG-12, VG-14: la giornata affiancata di tutti i membri del Gruppo.

@ProviderFor(groupPlanDay)
final groupPlanDayProvider = GroupPlanDayFamily._();

/// VG-12, VG-14: la giornata affiancata di tutti i membri del Gruppo.

final class GroupPlanDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<GroupPlanDay>,
          GroupPlanDay,
          FutureOr<GroupPlanDay>
        >
    with $FutureModifier<GroupPlanDay>, $FutureProvider<GroupPlanDay> {
  /// VG-12, VG-14: la giornata affiancata di tutti i membri del Gruppo.
  GroupPlanDayProvider._({
    required GroupPlanDayFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'groupPlanDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupPlanDayHash();

  @override
  String toString() {
    return r'groupPlanDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GroupPlanDay> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GroupPlanDay> create(Ref ref) {
    final argument = this.argument as DateTime;
    return groupPlanDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupPlanDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupPlanDayHash() => r'e51c56599c00a77f727d04c15a6390f29c5f2b96';

/// VG-12, VG-14: la giornata affiancata di tutti i membri del Gruppo.

final class GroupPlanDayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GroupPlanDay>, DateTime> {
  GroupPlanDayFamily._()
    : super(
        retry: null,
        name: r'groupPlanDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// VG-12, VG-14: la giornata affiancata di tutti i membri del Gruppo.

  GroupPlanDayProvider call(DateTime date) =>
      GroupPlanDayProvider._(argument: date, from: this);

  @override
  String toString() => r'groupPlanDayProvider';
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
    r'11720fa8d8719aa8f47cfdf8eef518c7b7092f3e';

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
