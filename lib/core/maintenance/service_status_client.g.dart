// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_status_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Client HTTP per il solo endpoint di stato, con cui si riconosce la fine
/// della manutenzione (MM-9).
///
/// È distinto dagli altri per la base: lo stato non appartiene al contratto e
/// non reca il prefisso di versione (VR-1), che gli altri client antepongono a
/// ogni percorso. Passa comunque dal proxy, l'unico a sapere della
/// manutenzione (MM-3).
///
/// Non porta l'intercettore della manutenzione — l'esito lo interpreta
/// [MaintenanceController], che di quella verifica ha bisogno in entrambi i
/// sensi — né quello della connettività: una verifica periodica che fallisce
/// per assenza di rete non è un'osservazione dell'Utente sulla propria
/// connessione. Dichiara invece piattaforma e build, come ogni altra
/// richiesta (VR-13).
///
/// `keepAlive`: stessa ragione degli altri client HTTP.

@ProviderFor(serviceStatusClient)
final serviceStatusClientProvider = ServiceStatusClientProvider._();

/// Client HTTP per il solo endpoint di stato, con cui si riconosce la fine
/// della manutenzione (MM-9).
///
/// È distinto dagli altri per la base: lo stato non appartiene al contratto e
/// non reca il prefisso di versione (VR-1), che gli altri client antepongono a
/// ogni percorso. Passa comunque dal proxy, l'unico a sapere della
/// manutenzione (MM-3).
///
/// Non porta l'intercettore della manutenzione — l'esito lo interpreta
/// [MaintenanceController], che di quella verifica ha bisogno in entrambi i
/// sensi — né quello della connettività: una verifica periodica che fallisce
/// per assenza di rete non è un'osservazione dell'Utente sulla propria
/// connessione. Dichiara invece piattaforma e build, come ogni altra
/// richiesta (VR-13).
///
/// `keepAlive`: stessa ragione degli altri client HTTP.

final class ServiceStatusClientProvider
    extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client HTTP per il solo endpoint di stato, con cui si riconosce la fine
  /// della manutenzione (MM-9).
  ///
  /// È distinto dagli altri per la base: lo stato non appartiene al contratto e
  /// non reca il prefisso di versione (VR-1), che gli altri client antepongono a
  /// ogni percorso. Passa comunque dal proxy, l'unico a sapere della
  /// manutenzione (MM-3).
  ///
  /// Non porta l'intercettore della manutenzione — l'esito lo interpreta
  /// [MaintenanceController], che di quella verifica ha bisogno in entrambi i
  /// sensi — né quello della connettività: una verifica periodica che fallisce
  /// per assenza di rete non è un'osservazione dell'Utente sulla propria
  /// connessione. Dichiara invece piattaforma e build, come ogni altra
  /// richiesta (VR-13).
  ///
  /// `keepAlive`: stessa ragione degli altri client HTTP.
  ServiceStatusClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceStatusClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceStatusClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return serviceStatusClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$serviceStatusClientHash() =>
    r'6f3bd6821bd8a5730033a9e95ffd780c3ddfafc9';
