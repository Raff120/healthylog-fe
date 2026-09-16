// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manutenzione del servizio (MN-1, MM-7): `true` quando il servizio l'ha
/// dichiarata rispondendo `MAINTENANCE` a una chiamata qualsiasi.
///
/// Diversamente da [ClientUpdateController] lo stato **non** è ricordato sul
/// dispositivo (MM-7, MN-6): un aggiornamento obbligatorio si aggirerebbe
/// staccando la rete, e va perciò ricordato; una manutenzione cessa invece da
/// sé, e lo sbarramento vale finché è il servizio a dichiararla. Riaprendo
/// l'applicazione senza che il servizio la dichiari, non si ripresenta.
///
/// Per la stessa ragione non c'è nulla da leggere all'avvio: lo stato è un
/// booleano sincrono, non un `Future`.
///
/// `keepAlive`: aggiornato dall'intercettore HTTP con `ref.read`, come
/// [ConnectivityStatus], indipendentemente da quale schermata sia in primo
/// piano; e letto dal router.

@ProviderFor(MaintenanceController)
final maintenanceControllerProvider = MaintenanceControllerProvider._();

/// Manutenzione del servizio (MN-1, MM-7): `true` quando il servizio l'ha
/// dichiarata rispondendo `MAINTENANCE` a una chiamata qualsiasi.
///
/// Diversamente da [ClientUpdateController] lo stato **non** è ricordato sul
/// dispositivo (MM-7, MN-6): un aggiornamento obbligatorio si aggirerebbe
/// staccando la rete, e va perciò ricordato; una manutenzione cessa invece da
/// sé, e lo sbarramento vale finché è il servizio a dichiararla. Riaprendo
/// l'applicazione senza che il servizio la dichiari, non si ripresenta.
///
/// Per la stessa ragione non c'è nulla da leggere all'avvio: lo stato è un
/// booleano sincrono, non un `Future`.
///
/// `keepAlive`: aggiornato dall'intercettore HTTP con `ref.read`, come
/// [ConnectivityStatus], indipendentemente da quale schermata sia in primo
/// piano; e letto dal router.
final class MaintenanceControllerProvider
    extends $NotifierProvider<MaintenanceController, bool> {
  /// Manutenzione del servizio (MN-1, MM-7): `true` quando il servizio l'ha
  /// dichiarata rispondendo `MAINTENANCE` a una chiamata qualsiasi.
  ///
  /// Diversamente da [ClientUpdateController] lo stato **non** è ricordato sul
  /// dispositivo (MM-7, MN-6): un aggiornamento obbligatorio si aggirerebbe
  /// staccando la rete, e va perciò ricordato; una manutenzione cessa invece da
  /// sé, e lo sbarramento vale finché è il servizio a dichiararla. Riaprendo
  /// l'applicazione senza che il servizio la dichiari, non si ripresenta.
  ///
  /// Per la stessa ragione non c'è nulla da leggere all'avvio: lo stato è un
  /// booleano sincrono, non un `Future`.
  ///
  /// `keepAlive`: aggiornato dall'intercettore HTTP con `ref.read`, come
  /// [ConnectivityStatus], indipendentemente da quale schermata sia in primo
  /// piano; e letto dal router.
  MaintenanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'maintenanceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$maintenanceControllerHash();

  @$internal
  @override
  MaintenanceController create() => MaintenanceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$maintenanceControllerHash() =>
    r'60bbc0239a11a16fc4dc310abd574b2f5a9257e8';

/// Manutenzione del servizio (MN-1, MM-7): `true` quando il servizio l'ha
/// dichiarata rispondendo `MAINTENANCE` a una chiamata qualsiasi.
///
/// Diversamente da [ClientUpdateController] lo stato **non** è ricordato sul
/// dispositivo (MM-7, MN-6): un aggiornamento obbligatorio si aggirerebbe
/// staccando la rete, e va perciò ricordato; una manutenzione cessa invece da
/// sé, e lo sbarramento vale finché è il servizio a dichiararla. Riaprendo
/// l'applicazione senza che il servizio la dichiari, non si ripresenta.
///
/// Per la stessa ragione non c'è nulla da leggere all'avvio: lo stato è un
/// booleano sincrono, non un `Future`.
///
/// `keepAlive`: aggiornato dall'intercettore HTTP con `ref.read`, come
/// [ConnectivityStatus], indipendentemente da quale schermata sia in primo
/// piano; e letto dal router.

abstract class _$MaintenanceController extends $Notifier<bool> {
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
