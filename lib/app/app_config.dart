/// Configurazione dell'ambiente client, valorizzata a compilazione con
/// `--dart-define=API_BASE_URL=...`. In sviluppo punta al backend locale
/// (8.2 specifica-tecnica.md, CG-1).
///
/// VR-12: l'indirizzo non reca la versione del contratto, che il client
/// antepone da sé (`apiVersion` in `core/api/api_client.dart`). Relativo per
/// la PWA, servita sul medesimo dominio delle API (`/api`); assoluto per le
/// versioni native (`https://healthylog.it/api`).
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// VR-18: pagina dell'aggiornamento per le versioni Android distribuite
  /// fuori dallo store (l'APK della release di GitHub). Assente, vale la
  /// scheda dell'applicazione su Google Play.
  static const String androidUpdateUrl = String.fromEnvironment('ANDROID_UPDATE_URL');

  /// VR-18: identificativo dell'applicazione su App Store (iOS e macOS).
  static const String appleStoreId = String.fromEnvironment('APPLE_STORE_ID');

  /// VR-18: identificativo del prodotto su Microsoft Store (Windows).
  static const String microsoftStoreProductId = String.fromEnvironment('MICROSOFT_STORE_PRODUCT_ID');
}
