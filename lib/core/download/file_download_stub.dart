/// Piattaforma priva sia di `dart:io` sia di JavaScript: non ne esistono
/// fra quelle di MP-1, e il caso resta un errore di configurazione.
Future<void> deliverFile({
  required String fileName,
  required List<int> bytes,
  required String mimeType,
}) async {
  throw UnsupportedError('Nessuna implementazione della consegna dei file per questa piattaforma.');
}
