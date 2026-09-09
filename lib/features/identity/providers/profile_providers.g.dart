// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileApi)
final profileApiProvider = ProfileApiProvider._();

final class ProfileApiProvider
    extends $FunctionalProvider<ProfileApi, ProfileApi, ProfileApi>
    with $Provider<ProfileApi> {
  ProfileApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileApiHash();

  @$internal
  @override
  $ProviderElement<ProfileApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileApi create(Ref ref) {
    return profileApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileApi>(value),
    );
  }
}

String _$profileApiHash() => r'465ae9ffbf98dea53bd831c277dfe64ac64ff4bd';

/// Profilo dell'Utente autenticato (PR-1, PR-4, PR-6). Caricato al primo
/// accesso alla schermata e aggiornato dopo ogni modifica riuscita, così
/// che l'intestazione (12.1 interfaccia.md) rifletta subito il nuovo
/// valore senza un'ulteriore lettura.

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

/// Profilo dell'Utente autenticato (PR-1, PR-4, PR-6). Caricato al primo
/// accesso alla schermata e aggiornato dopo ogni modifica riuscita, così
/// che l'intestazione (12.1 interfaccia.md) rifletta subito il nuovo
/// valore senza un'ulteriore lettura.
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, Profile> {
  /// Profilo dell'Utente autenticato (PR-1, PR-4, PR-6). Caricato al primo
  /// accesso alla schermata e aggiornato dopo ogni modifica riuscita, così
  /// che l'intestazione (12.1 interfaccia.md) rifletta subito il nuovo
  /// valore senza un'ulteriore lettura.
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'8e7ff61c185594d5001731262f360f9038292028';

/// Profilo dell'Utente autenticato (PR-1, PR-4, PR-6). Caricato al primo
/// accesso alla schermata e aggiornato dopo ogni modifica riuscita, così
/// che l'intestazione (12.1 interfaccia.md) rifletta subito il nuovo
/// valore senza un'ulteriore lettura.

abstract class _$ProfileController extends $AsyncNotifier<Profile> {
  FutureOr<Profile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Profile>, Profile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile>, Profile>,
              AsyncValue<Profile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Il profilo quando — e solo quando — una sessione è attiva.
///
/// Osservarlo non fa partire il caricamento del profilo a chi non ha
/// ancora effettuato l'accesso: `profileControllerProvider` è raggiunto
/// solo dopo la verifica della sessione. Serve all'instradamento, che
/// deve reagire agli sbarramenti di PV-8 e PV-17 senza per questo
/// interrogare il server prima dell'accesso.

@ProviderFor(currentProfileOrNull)
final currentProfileOrNullProvider = CurrentProfileOrNullProvider._();

/// Il profilo quando — e solo quando — una sessione è attiva.
///
/// Osservarlo non fa partire il caricamento del profilo a chi non ha
/// ancora effettuato l'accesso: `profileControllerProvider` è raggiunto
/// solo dopo la verifica della sessione. Serve all'instradamento, che
/// deve reagire agli sbarramenti di PV-8 e PV-17 senza per questo
/// interrogare il server prima dell'accesso.

final class CurrentProfileOrNullProvider
    extends $FunctionalProvider<Profile?, Profile?, Profile?>
    with $Provider<Profile?> {
  /// Il profilo quando — e solo quando — una sessione è attiva.
  ///
  /// Osservarlo non fa partire il caricamento del profilo a chi non ha
  /// ancora effettuato l'accesso: `profileControllerProvider` è raggiunto
  /// solo dopo la verifica della sessione. Serve all'instradamento, che
  /// deve reagire agli sbarramenti di PV-8 e PV-17 senza per questo
  /// interrogare il server prima dell'accesso.
  CurrentProfileOrNullProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileOrNullProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileOrNullHash();

  @$internal
  @override
  $ProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Profile? create(Ref ref) {
    return currentProfileOrNull(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Profile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Profile?>(value),
    );
  }
}

String _$currentProfileOrNullHash() =>
    r'cb5ef489687f51fed132571480d2098010a6e79d';

/// LO-4: il sistema di unità di misura scelto dall'Utente, che ogni
/// schermata consulta per convertire la presentazione (LO-7). Degrada al
/// metrico durante il caricamento del profilo — LO-6 lo vuole comunque
/// predefinito — invece di lasciare la schermata senza unità.

@ProviderFor(unitSystem)
final unitSystemProvider = UnitSystemProvider._();

/// LO-4: il sistema di unità di misura scelto dall'Utente, che ogni
/// schermata consulta per convertire la presentazione (LO-7). Degrada al
/// metrico durante il caricamento del profilo — LO-6 lo vuole comunque
/// predefinito — invece di lasciare la schermata senza unità.

final class UnitSystemProvider
    extends $FunctionalProvider<UnitSystem, UnitSystem, UnitSystem>
    with $Provider<UnitSystem> {
  /// LO-4: il sistema di unità di misura scelto dall'Utente, che ogni
  /// schermata consulta per convertire la presentazione (LO-7). Degrada al
  /// metrico durante il caricamento del profilo — LO-6 lo vuole comunque
  /// predefinito — invece di lasciare la schermata senza unità.
  UnitSystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitSystemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitSystemHash();

  @$internal
  @override
  $ProviderElement<UnitSystem> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UnitSystem create(Ref ref) {
    return unitSystem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnitSystem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnitSystem>(value),
    );
  }
}

String _$unitSystemHash() => r'e8704dd9307ffbde011c0a4290fc202826e2f1b3';
