/// Configurazione dell'ambiente client, valorizzata a compilazione con
/// `--dart-define=API_BASE_URL=...`. In sviluppo punta al backend locale
/// (8.2 specifica-tecnica.md, CG-1).
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
