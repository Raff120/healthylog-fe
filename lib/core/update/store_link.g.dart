// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_link.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// VR-18: pagina da cui installare la versione aggiornata, per piattaforma.
/// Configurazione del client: il backend non la conosce.
///
/// - Android: l'indirizzo configurato per le versioni distribuite fuori dallo
///   store (l'APK della release di GitHub), altrimenti la scheda su Google
///   Play, ricavata dal nome del pacchetto;
/// - iOS e macOS: la scheda su App Store, se ne è configurato l'identificativo;
/// - Windows: la scheda su Microsoft Store, se ne è configurato l'identificativo.
///
/// `null` dove nessuna pagina è nota — il web, che non è soggetto
/// all'aggiornamento obbligatorio (MP-17), o un identificativo non ancora
/// configurato: la schermata ne omette l'azione.

@ProviderFor(storeLink)
final storeLinkProvider = StoreLinkProvider._();

/// VR-18: pagina da cui installare la versione aggiornata, per piattaforma.
/// Configurazione del client: il backend non la conosce.
///
/// - Android: l'indirizzo configurato per le versioni distribuite fuori dallo
///   store (l'APK della release di GitHub), altrimenti la scheda su Google
///   Play, ricavata dal nome del pacchetto;
/// - iOS e macOS: la scheda su App Store, se ne è configurato l'identificativo;
/// - Windows: la scheda su Microsoft Store, se ne è configurato l'identificativo.
///
/// `null` dove nessuna pagina è nota — il web, che non è soggetto
/// all'aggiornamento obbligatorio (MP-17), o un identificativo non ancora
/// configurato: la schermata ne omette l'azione.

final class StoreLinkProvider
    extends $FunctionalProvider<AsyncValue<Uri?>, Uri?, FutureOr<Uri?>>
    with $FutureModifier<Uri?>, $FutureProvider<Uri?> {
  /// VR-18: pagina da cui installare la versione aggiornata, per piattaforma.
  /// Configurazione del client: il backend non la conosce.
  ///
  /// - Android: l'indirizzo configurato per le versioni distribuite fuori dallo
  ///   store (l'APK della release di GitHub), altrimenti la scheda su Google
  ///   Play, ricavata dal nome del pacchetto;
  /// - iOS e macOS: la scheda su App Store, se ne è configurato l'identificativo;
  /// - Windows: la scheda su Microsoft Store, se ne è configurato l'identificativo.
  ///
  /// `null` dove nessuna pagina è nota — il web, che non è soggetto
  /// all'aggiornamento obbligatorio (MP-17), o un identificativo non ancora
  /// configurato: la schermata ne omette l'azione.
  StoreLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeLinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeLinkHash();

  @$internal
  @override
  $FutureProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uri?> create(Ref ref) {
    return storeLink(ref);
  }
}

String _$storeLinkHash() => r'0231ec1aace0d74e260b11f8cea2241730f291d0';
