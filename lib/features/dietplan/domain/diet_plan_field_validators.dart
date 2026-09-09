/// Validazione dei campi di creazione del piano (7.2 interfaccia.md, CD-1).
library;

/// `null` se valido, altrimenti il codice d'errore (FR-22: tradotto dal
/// client, mai testo qui). Stesso limite di `PA-11` sul backend (100
/// caratteri, `@Size`).
String? validatePlanName(String value) {
  if (value.trim().isEmpty) return 'REQUIRED';
  if (value.length > 100) return 'TOO_LONG';
  return null;
}
