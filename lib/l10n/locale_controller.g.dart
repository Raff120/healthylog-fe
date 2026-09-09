// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lingua dell'interfaccia (LO-1, LO-2).
///
/// **Perché è conservata anche in locale.** La lingua vive sul server
/// (campo `locale`), che ne ha bisogno per le comunicazioni per posta
/// (AU-27). Ma l'interfaccia deve essere nella lingua giusta anche
/// **prima** dell'accesso — registrazione, accesso, verifica
/// dell'indirizzo (5.1..5.4) — quando nessun profilo è ancora
/// disponibile, e senza attendere una richiesta di rete a ogni avvio. La
/// copia locale è quindi la fonte per la presentazione; quella sul
/// server è la fonte per la posta. Le due si allineano nei due momenti
/// in cui possono divergere: la scelta dell'Utente le scrive entrambe, e
/// un dispositivo privo di preferenza locale adotta quella del profilo
/// al primo caricamento (vedi decisioni.md).
///
/// LO-2: in assenza di entrambe vale la lingua del dispositivo, se tra
/// quelle disponibili, ovvero l'italiano.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Lingua dell'interfaccia (LO-1, LO-2).
///
/// **Perché è conservata anche in locale.** La lingua vive sul server
/// (campo `locale`), che ne ha bisogno per le comunicazioni per posta
/// (AU-27). Ma l'interfaccia deve essere nella lingua giusta anche
/// **prima** dell'accesso — registrazione, accesso, verifica
/// dell'indirizzo (5.1..5.4) — quando nessun profilo è ancora
/// disponibile, e senza attendere una richiesta di rete a ogni avvio. La
/// copia locale è quindi la fonte per la presentazione; quella sul
/// server è la fonte per la posta. Le due si allineano nei due momenti
/// in cui possono divergere: la scelta dell'Utente le scrive entrambe, e
/// un dispositivo privo di preferenza locale adotta quella del profilo
/// al primo caricamento (vedi decisioni.md).
///
/// LO-2: in assenza di entrambe vale la lingua del dispositivo, se tra
/// quelle disponibili, ovvero l'italiano.
final class LocaleControllerProvider
    extends $AsyncNotifierProvider<LocaleController, AppLocale> {
  /// Lingua dell'interfaccia (LO-1, LO-2).
  ///
  /// **Perché è conservata anche in locale.** La lingua vive sul server
  /// (campo `locale`), che ne ha bisogno per le comunicazioni per posta
  /// (AU-27). Ma l'interfaccia deve essere nella lingua giusta anche
  /// **prima** dell'accesso — registrazione, accesso, verifica
  /// dell'indirizzo (5.1..5.4) — quando nessun profilo è ancora
  /// disponibile, e senza attendere una richiesta di rete a ogni avvio. La
  /// copia locale è quindi la fonte per la presentazione; quella sul
  /// server è la fonte per la posta. Le due si allineano nei due momenti
  /// in cui possono divergere: la scelta dell'Utente le scrive entrambe, e
  /// un dispositivo privo di preferenza locale adotta quella del profilo
  /// al primo caricamento (vedi decisioni.md).
  ///
  /// LO-2: in assenza di entrambe vale la lingua del dispositivo, se tra
  /// quelle disponibili, ovvero l'italiano.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();
}

String _$localeControllerHash() => r'67a7658dba71583fd263f6ce193a30c0c717b51a';

/// Lingua dell'interfaccia (LO-1, LO-2).
///
/// **Perché è conservata anche in locale.** La lingua vive sul server
/// (campo `locale`), che ne ha bisogno per le comunicazioni per posta
/// (AU-27). Ma l'interfaccia deve essere nella lingua giusta anche
/// **prima** dell'accesso — registrazione, accesso, verifica
/// dell'indirizzo (5.1..5.4) — quando nessun profilo è ancora
/// disponibile, e senza attendere una richiesta di rete a ogni avvio. La
/// copia locale è quindi la fonte per la presentazione; quella sul
/// server è la fonte per la posta. Le due si allineano nei due momenti
/// in cui possono divergere: la scelta dell'Utente le scrive entrambe, e
/// un dispositivo privo di preferenza locale adotta quella del profilo
/// al primo caricamento (vedi decisioni.md).
///
/// LO-2: in assenza di entrambe vale la lingua del dispositivo, se tra
/// quelle disponibili, ovvero l'italiano.

abstract class _$LocaleController extends $AsyncNotifier<AppLocale> {
  FutureOr<AppLocale> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppLocale>, AppLocale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppLocale>, AppLocale>,
              AsyncValue<AppLocale>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// La lingua da passare a `MaterialApp` (LO-1). Degrada al predefinito
/// durante il breve caricamento della preferenza, mai a un errore — sul
/// modello di `ThemeModeController`.

@ProviderFor(appLocale)
final appLocaleProvider = AppLocaleProvider._();

/// La lingua da passare a `MaterialApp` (LO-1). Degrada al predefinito
/// durante il breve caricamento della preferenza, mai a un errore — sul
/// modello di `ThemeModeController`.

final class AppLocaleProvider
    extends $FunctionalProvider<Locale, Locale, Locale>
    with $Provider<Locale> {
  /// La lingua da passare a `MaterialApp` (LO-1). Degrada al predefinito
  /// durante il breve caricamento della preferenza, mai a un errore — sul
  /// modello di `ThemeModeController`.
  AppLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return appLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$appLocaleHash() => r'bc165cfcb59af7e4ff6b83148ed0cce1c47a753d';
