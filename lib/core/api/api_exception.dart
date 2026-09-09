import 'package:dio/dio.dart';

/// Errore restituito dal backend (4.3 specifica-tecnica.md, ER-1): uno
/// status HTTP e un codice stringa che ne identifica la causa specifica.
/// Il testo presentato all'Utente è generato dal client a partire dal
/// codice, secondo la lingua selezionata (LO-1) — non dal corpo della
/// risposta (ER-2).
class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.code, this.body});

  final int statusCode;
  final String code;

  /// Corpo grezzo della risposta (ER-1), oltre al solo `code`: alcuni
  /// errori portano dati che servono a comporre il messaggio (es.
  /// `PLAN_PERIOD_OVERLAP` indica il piano in conflitto, `VALIDATION_FAILED`
  /// l'elenco dei campi, ER-12). Un `dynamic` grezzo, non un modello
  /// dedicato: letto solo dalle poche schermate che ne hanno bisogno,
  /// per uno specifico codice già noto.
  final dynamic body;

  @override
  String toString() => 'ApiException($statusCode, $code)';
}

/// Estrae l'[ApiException] da un errore catturato da `AsyncValue.guard`.
/// dio non lancia mai [ApiException] direttamente: lancia il
/// [DioException] che [ApiErrorInterceptor] ha completato con
/// `handler.reject`, portando l'[ApiException] nel campo `error` — è
/// quel [DioException] a raggiungere il chiamante, non il suo
/// contenuto. Un controllo diretto `error is ApiException` è quindi
/// sempre falso; questa estensione è l'unico modo corretto di
/// recuperarlo.
extension ApiExceptionExtraction on Object {
  ApiException? get asApiException {
    final self = this;
    if (self is ApiException) return self;
    if (self is DioException && self.error is ApiException) {
      return self.error as ApiException;
    }
    return null;
  }
}
