/// Errore restituito dal backend (4.3 specifica-tecnica.md, ER-1): uno
/// status HTTP e un codice stringa che ne identifica la causa specifica.
/// Il testo presentato all'Utente è generato dal client a partire dal
/// codice, secondo la lingua selezionata (LO-1) — non dal corpo della
/// risposta (ER-2).
class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.code});

  final int statusCode;
  final String code;

  @override
  String toString() => 'ApiException($statusCode, $code)';
}
