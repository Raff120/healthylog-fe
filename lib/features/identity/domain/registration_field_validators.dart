/// Validazione dei campi del modulo di registrazione (5.1 interfaccia.md).
/// Segnalati tutti insieme all'invio (ER-12), eccetto il nome utente, la cui
/// verifica di disponibilità è immediata (FE-7: regole valutabili sul
/// client, qui senza bisogno di rete).
library;

const int passwordMinLength = 12;

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9_.-]+$');

/// `null` se valido, altrimenti il codice d'errore (FR-22: tradotto dal
/// client, mai testo qui).
String? validateRequired(String value) => value.trim().isEmpty ? 'REQUIRED' : null;

String? validateEmail(String value) {
  if (value.trim().isEmpty) return 'REQUIRED';
  if (!_emailPattern.hasMatch(value.trim())) return 'INVALID_FORMAT';
  return null;
}

String? validateUsername(String value) {
  if (value.trim().isEmpty) return 'REQUIRED';
  if (value.length > 30) return 'TOO_LONG';
  if (!_usernamePattern.hasMatch(value)) return 'INVALID_FORMAT';
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) return 'REQUIRED';
  if (value.length < passwordMinLength) return 'TOO_SHORT';
  return null;
}

String? validateName(String value) {
  if (value.trim().isEmpty) return 'REQUIRED';
  if (value.length > 100) return 'TOO_LONG';
  return null;
}
