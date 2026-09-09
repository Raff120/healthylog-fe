import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/storage/preferences_store.dart';
import 'app_locale.dart';

part 'locale_controller.g.dart';

const _localeKey = 'app_locale';

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
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Future<AppLocale> build() async {
    final stored = await ref.watch(preferencesStoreProvider).read(_localeKey);
    if (stored != null) return AppLocale.fromTag(stored);
    return AppLocale.fromTag(_deviceLanguageTag());
  }

  /// Scelta esplicita dell'Utente dalle Impostazioni (12.2). La scrittura
  /// sul server è del chiamante, che dispone dell'API del profilo:
  /// questo controller non conosce la rete.
  Future<void> select(AppLocale locale) async {
    state = AsyncValue.data(locale);
    await ref.read(preferencesStoreProvider).write(_localeKey, locale.name);
  }

  /// Allineamento alla lingua del profilo su un dispositivo che non ne
  /// abbia ancora una propria: il primo accesso da un dispositivo nuovo
  /// ritrova la lingua scelta altrove (MP-11).
  Future<void> adoptFromProfile(AppLocale locale) async {
    final stored = await ref.read(preferencesStoreProvider).read(_localeKey);
    if (stored != null) return;
    await select(locale);
  }

  /// LO-2: la lingua del dispositivo, che il sistema espone come
  /// identificatore anche regionale.
  String? _deviceLanguageTag() {
    final locales = PlatformDispatcher.instance.locales;
    if (locales.isEmpty) return null;
    return locales.first.languageCode;
  }
}

/// La lingua da passare a `MaterialApp` (LO-1). Degrada al predefinito
/// durante il breve caricamento della preferenza, mai a un errore — sul
/// modello di `ThemeModeController`.
@Riverpod(keepAlive: true)
Locale appLocale(Ref ref) =>
    (ref.watch(localeControllerProvider).value ?? AppLocale.fallback).flutterLocale;
