// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dietPlanApi)
final dietPlanApiProvider = DietPlanApiProvider._();

final class DietPlanApiProvider
    extends $FunctionalProvider<DietPlanApi, DietPlanApi, DietPlanApi>
    with $Provider<DietPlanApi> {
  DietPlanApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dietPlanApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dietPlanApiHash();

  @$internal
  @override
  $ProviderElement<DietPlanApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DietPlanApi create(Ref ref) {
    return dietPlanApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DietPlanApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DietPlanApi>(value),
    );
  }
}

String _$dietPlanApiHash() => r'5d794dd85d73a22a4f52641fb7b83979d069e5cb';

/// Creazione del piano (CD-1, CD-4): nessuno stato da ricaricare al primo
/// utilizzo, a differenza di [DietPlanScheduleController] — la schermata di
/// creazione non legge alcun piano esistente.

@ProviderFor(CreateDietPlanController)
final createDietPlanControllerProvider = CreateDietPlanControllerProvider._();

/// Creazione del piano (CD-1, CD-4): nessuno stato da ricaricare al primo
/// utilizzo, a differenza di [DietPlanScheduleController] — la schermata di
/// creazione non legge alcun piano esistente.
final class CreateDietPlanControllerProvider
    extends $NotifierProvider<CreateDietPlanController, AsyncValue<DietPlan>?> {
  /// Creazione del piano (CD-1, CD-4): nessuno stato da ricaricare al primo
  /// utilizzo, a differenza di [DietPlanScheduleController] — la schermata di
  /// creazione non legge alcun piano esistente.
  CreateDietPlanControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createDietPlanControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createDietPlanControllerHash();

  @$internal
  @override
  CreateDietPlanController create() => CreateDietPlanController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<DietPlan>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<DietPlan>?>(value),
    );
  }
}

String _$createDietPlanControllerHash() =>
    r'fac07fdb3c458c802581f080db7fe8bf0d7137b1';

/// Creazione del piano (CD-1, CD-4): nessuno stato da ricaricare al primo
/// utilizzo, a differenza di [DietPlanScheduleController] — la schermata di
/// creazione non legge alcun piano esistente.

abstract class _$CreateDietPlanController
    extends $Notifier<AsyncValue<DietPlan>?> {
  AsyncValue<DietPlan>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DietPlan>?, AsyncValue<DietPlan>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DietPlan>?, AsyncValue<DietPlan>?>,
              AsyncValue<DietPlan>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Piano in redazione (CD-5, CD-7, CD-8, CD-10): caricato per `planId` al
/// primo accesso alla schermata (ST-4) e sostituito con l'esito di ogni
/// salvataggio riuscito, così che un nuovo `slotId` generato lato server
/// (per uno slot appena aggiunto) sia disponibile ai salvataggi successivi.

@ProviderFor(DietPlanScheduleController)
final dietPlanScheduleControllerProvider = DietPlanScheduleControllerFamily._();

/// Piano in redazione (CD-5, CD-7, CD-8, CD-10): caricato per `planId` al
/// primo accesso alla schermata (ST-4) e sostituito con l'esito di ogni
/// salvataggio riuscito, così che un nuovo `slotId` generato lato server
/// (per uno slot appena aggiunto) sia disponibile ai salvataggi successivi.
final class DietPlanScheduleControllerProvider
    extends $AsyncNotifierProvider<DietPlanScheduleController, DietPlan> {
  /// Piano in redazione (CD-5, CD-7, CD-8, CD-10): caricato per `planId` al
  /// primo accesso alla schermata (ST-4) e sostituito con l'esito di ogni
  /// salvataggio riuscito, così che un nuovo `slotId` generato lato server
  /// (per uno slot appena aggiunto) sia disponibile ai salvataggi successivi.
  DietPlanScheduleControllerProvider._({
    required DietPlanScheduleControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dietPlanScheduleControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dietPlanScheduleControllerHash();

  @override
  String toString() {
    return r'dietPlanScheduleControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DietPlanScheduleController create() => DietPlanScheduleController();

  @override
  bool operator ==(Object other) {
    return other is DietPlanScheduleControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dietPlanScheduleControllerHash() =>
    r'b1a50b21fd71e7c81ea4d2e672e862977b733613';

/// Piano in redazione (CD-5, CD-7, CD-8, CD-10): caricato per `planId` al
/// primo accesso alla schermata (ST-4) e sostituito con l'esito di ogni
/// salvataggio riuscito, così che un nuovo `slotId` generato lato server
/// (per uno slot appena aggiunto) sia disponibile ai salvataggi successivi.

final class DietPlanScheduleControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DietPlanScheduleController,
          AsyncValue<DietPlan>,
          DietPlan,
          FutureOr<DietPlan>,
          String
        > {
  DietPlanScheduleControllerFamily._()
    : super(
        retry: null,
        name: r'dietPlanScheduleControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Piano in redazione (CD-5, CD-7, CD-8, CD-10): caricato per `planId` al
  /// primo accesso alla schermata (ST-4) e sostituito con l'esito di ogni
  /// salvataggio riuscito, così che un nuovo `slotId` generato lato server
  /// (per uno slot appena aggiunto) sia disponibile ai salvataggi successivi.

  DietPlanScheduleControllerProvider call(String planId) =>
      DietPlanScheduleControllerProvider._(argument: planId, from: this);

  @override
  String toString() => r'dietPlanScheduleControllerProvider';
}

/// Piano in redazione (CD-5, CD-7, CD-8, CD-10): caricato per `planId` al
/// primo accesso alla schermata (ST-4) e sostituito con l'esito di ogni
/// salvataggio riuscito, così che un nuovo `slotId` generato lato server
/// (per uno slot appena aggiunto) sia disponibile ai salvataggi successivi.

abstract class _$DietPlanScheduleController extends $AsyncNotifier<DietPlan> {
  late final _$args = ref.$arg as String;
  String get planId => _$args;

  FutureOr<DietPlan> build(String planId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DietPlan>, DietPlan>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DietPlan>, DietPlan>,
              AsyncValue<DietPlan>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
