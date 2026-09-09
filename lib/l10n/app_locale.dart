import 'dart:ui';

/// Lingua dell'interfaccia (LO-1). Rispecchia `it.healthylog.model.AppLocale`
/// sul backend, che la conserva per le comunicazioni per posta (AU-27).
///
/// LO-1: le lingue sono due e soltanto due.
enum AppLocale {
  it,
  en;

  /// LO-2: l'italiano in assenza di scelta, e per una lingua non prevista.
  static const AppLocale fallback = AppLocale.it;

  String toJson() => name.toUpperCase();

  static AppLocale fromJson(String? value) => fromTag(value);

  /// Accetta anche un identificatore regionale (`it-CH`, `en_GB`), di cui
  /// considera la sola parte di lingua: è la forma in cui la lingua del
  /// dispositivo si presenta (LO-2).
  static AppLocale fromTag(String? tag) {
    if (tag == null || tag.trim().isEmpty) return fallback;
    final language = tag.trim().replaceAll('_', '-').split('-').first.toLowerCase();
    for (final locale in values) {
      if (locale.name == language) return locale;
    }
    return fallback;
  }

  Locale get flutterLocale => Locale(name);
}

/// LO-1: le lingue offerte, nell'ordine in cui le Impostazioni le
/// presentano (12.2 interfaccia.md).
const supportedAppLocales = [AppLocale.it, AppLocale.en];

/// LO-2: una lingua non prevista ricade sull'italiano, non sulla prima
/// dell'elenco generato — che è l'inglese, in ordine alfabetico. Da
/// passare a `MaterialApp.localeResolutionCallback`.
Locale resolveAppLocale(Locale? deviceLocale, Iterable<Locale> supported) =>
    AppLocale.fromTag(deviceLocale?.languageCode).flutterLocale;
