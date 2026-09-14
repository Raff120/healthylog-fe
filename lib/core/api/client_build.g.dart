// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_build.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Numero di build installato (VR-19), letto dal pacchetto e non fornito a
/// compilazione: una build in cui la definizione fosse omessa si
/// dichiarerebbe superata da sé alla prima soglia non nulla.
///
/// `null` quando il pacchetto non è leggibile (ambiente di test, piattaforma
/// priva del canale) o il numero non è un intero: la dichiarazione è
/// omessa, e il client non è soggetto al build minimo (VR-16).

@ProviderFor(clientBuild)
final clientBuildProvider = ClientBuildProvider._();

/// Numero di build installato (VR-19), letto dal pacchetto e non fornito a
/// compilazione: una build in cui la definizione fosse omessa si
/// dichiarerebbe superata da sé alla prima soglia non nulla.
///
/// `null` quando il pacchetto non è leggibile (ambiente di test, piattaforma
/// priva del canale) o il numero non è un intero: la dichiarazione è
/// omessa, e il client non è soggetto al build minimo (VR-16).

final class ClientBuildProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// Numero di build installato (VR-19), letto dal pacchetto e non fornito a
  /// compilazione: una build in cui la definizione fosse omessa si
  /// dichiarerebbe superata da sé alla prima soglia non nulla.
  ///
  /// `null` quando il pacchetto non è leggibile (ambiente di test, piattaforma
  /// priva del canale) o il numero non è un intero: la dichiarazione è
  /// omessa, e il client non è soggetto al build minimo (VR-16).
  ClientBuildProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientBuildProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientBuildHash();

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    return clientBuild(ref);
  }
}

String _$clientBuildHash() => r'4f0fefb7fcfd6ba81585983f1debf2ed6898e726';
