// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(measurementApi)
final measurementApiProvider = MeasurementApiProvider._();

final class MeasurementApiProvider
    extends $FunctionalProvider<MeasurementApi, MeasurementApi, MeasurementApi>
    with $Provider<MeasurementApi> {
  MeasurementApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementApiHash();

  @$internal
  @override
  $ProviderElement<MeasurementApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MeasurementApi create(Ref ref) {
    return measurementApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeasurementApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeasurementApi>(value),
    );
  }
}

String _$measurementApiHash() => r'0fcd9c30039cb111d11bdc5a4db653933e73eaec';

/// AN-4: le proprie misurazioni, in ordine cronologico decrescente.

@ProviderFor(Measurements)
final measurementsProvider = MeasurementsProvider._();

/// AN-4: le proprie misurazioni, in ordine cronologico decrescente.
final class MeasurementsProvider
    extends $AsyncNotifierProvider<Measurements, List<BodyMeasurement>> {
  /// AN-4: le proprie misurazioni, in ordine cronologico decrescente.
  MeasurementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementsHash();

  @$internal
  @override
  Measurements create() => Measurements();
}

String _$measurementsHash() => r'c3fe86ec6f1f43e88861c92ae731e60b7ea586dc';

/// AN-4: le proprie misurazioni, in ordine cronologico decrescente.

abstract class _$Measurements extends $AsyncNotifier<List<BodyMeasurement>> {
  FutureOr<List<BodyMeasurement>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<BodyMeasurement>>, List<BodyMeasurement>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<BodyMeasurement>>,
                List<BodyMeasurement>
              >,
              AsyncValue<List<BodyMeasurement>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// NU-4, CS-14: le misurazioni di un Paziente — quelle dei periodi di
/// titolarità e quelle registrate dal Nutrizionista stesso.

@ProviderFor(PatientMeasurements)
final patientMeasurementsProvider = PatientMeasurementsFamily._();

/// NU-4, CS-14: le misurazioni di un Paziente — quelle dei periodi di
/// titolarità e quelle registrate dal Nutrizionista stesso.
final class PatientMeasurementsProvider
    extends $AsyncNotifierProvider<PatientMeasurements, List<BodyMeasurement>> {
  /// NU-4, CS-14: le misurazioni di un Paziente — quelle dei periodi di
  /// titolarità e quelle registrate dal Nutrizionista stesso.
  PatientMeasurementsProvider._({
    required PatientMeasurementsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'patientMeasurementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$patientMeasurementsHash();

  @override
  String toString() {
    return r'patientMeasurementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PatientMeasurements create() => PatientMeasurements();

  @override
  bool operator ==(Object other) {
    return other is PatientMeasurementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$patientMeasurementsHash() =>
    r'33f0869a5c5d2406dce13d2b961cfc1b7fdf3207';

/// NU-4, CS-14: le misurazioni di un Paziente — quelle dei periodi di
/// titolarità e quelle registrate dal Nutrizionista stesso.

final class PatientMeasurementsFamily extends $Family
    with
        $ClassFamilyOverride<
          PatientMeasurements,
          AsyncValue<List<BodyMeasurement>>,
          List<BodyMeasurement>,
          FutureOr<List<BodyMeasurement>>,
          String
        > {
  PatientMeasurementsFamily._()
    : super(
        retry: null,
        name: r'patientMeasurementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// NU-4, CS-14: le misurazioni di un Paziente — quelle dei periodi di
  /// titolarità e quelle registrate dal Nutrizionista stesso.

  PatientMeasurementsProvider call(String patientId) =>
      PatientMeasurementsProvider._(argument: patientId, from: this);

  @override
  String toString() => r'patientMeasurementsProvider';
}

/// NU-4, CS-14: le misurazioni di un Paziente — quelle dei periodi di
/// titolarità e quelle registrate dal Nutrizionista stesso.

abstract class _$PatientMeasurements
    extends $AsyncNotifier<List<BodyMeasurement>> {
  late final _$args = ref.$arg as String;
  String get patientId => _$args;

  FutureOr<List<BodyMeasurement>> build(String patientId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<BodyMeasurement>>, List<BodyMeasurement>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<BodyMeasurement>>,
                List<BodyMeasurement>
              >,
              AsyncValue<List<BodyMeasurement>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// PR-11, PR-16, NU-12: registrazione, modifica ed eliminazione.

@ProviderFor(MeasurementController)
final measurementControllerProvider = MeasurementControllerProvider._();

/// PR-11, PR-16, NU-12: registrazione, modifica ed eliminazione.
final class MeasurementControllerProvider
    extends $NotifierProvider<MeasurementController, AsyncValue<void>?> {
  /// PR-11, PR-16, NU-12: registrazione, modifica ed eliminazione.
  MeasurementControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementControllerHash();

  @$internal
  @override
  MeasurementController create() => MeasurementController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$measurementControllerHash() =>
    r'20bd196e61a4753f66d1c0f51f1409ac8ffc8cbf';

/// PR-11, PR-16, NU-12: registrazione, modifica ed eliminazione.

abstract class _$MeasurementController extends $Notifier<AsyncValue<void>?> {
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
