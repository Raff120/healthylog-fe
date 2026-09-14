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
/// Il valore è letto una sola volta, all'avvio, da [readInstalledBuild], e
/// fornito all'applicazione in `main.dart` sovrascrivendo questo provider.
/// Leggerlo qui, a ogni richiesta, ne farebbe dipendere ogni chiamata da un
/// canale di piattaforma: nei banchi di prova, dove un canale privo di
/// simulazione non risponde mai, tutte le chiamate resterebbero sospese.
///
/// `null` se non fornito o non leggibile: la dichiarazione è omessa, e il
/// client non è soggetto al build minimo (VR-16).

@ProviderFor(clientBuild)
final clientBuildProvider = ClientBuildProvider._();

/// Numero di build installato (VR-19), letto dal pacchetto e non fornito a
/// compilazione: una build in cui la definizione fosse omessa si
/// dichiarerebbe superata da sé alla prima soglia non nulla.
///
/// Il valore è letto una sola volta, all'avvio, da [readInstalledBuild], e
/// fornito all'applicazione in `main.dart` sovrascrivendo questo provider.
/// Leggerlo qui, a ogni richiesta, ne farebbe dipendere ogni chiamata da un
/// canale di piattaforma: nei banchi di prova, dove un canale privo di
/// simulazione non risponde mai, tutte le chiamate resterebbero sospese.
///
/// `null` se non fornito o non leggibile: la dichiarazione è omessa, e il
/// client non è soggetto al build minimo (VR-16).

final class ClientBuildProvider extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// Numero di build installato (VR-19), letto dal pacchetto e non fornito a
  /// compilazione: una build in cui la definizione fosse omessa si
  /// dichiarerebbe superata da sé alla prima soglia non nulla.
  ///
  /// Il valore è letto una sola volta, all'avvio, da [readInstalledBuild], e
  /// fornito all'applicazione in `main.dart` sovrascrivendo questo provider.
  /// Leggerlo qui, a ogni richiesta, ne farebbe dipendere ogni chiamata da un
  /// canale di piattaforma: nei banchi di prova, dove un canale privo di
  /// simulazione non risponde mai, tutte le chiamate resterebbero sospese.
  ///
  /// `null` se non fornito o non leggibile: la dichiarazione è omessa, e il
  /// client non è soggetto al build minimo (VR-16).
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
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return clientBuild(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$clientBuildHash() => r'74cf24bb45732267216b029343192b6af9399143';
