/// Traduzione dei codici d'errore (ER-2, FR-22): il testo presentato
/// all'Utente è generato qui a partire dal codice, mai dal corpo della
/// risposta. Solo italiano finché F29 non introduce la localizzazione
/// (LO-1): da allora queste voci confluiranno nei file ARB.
String describeApiError(String code) {
  return switch (code) {
    'VALIDATION_FAILED' => 'Controlla i dati inseriti.',
    'INVALID_CREDENTIALS' => 'Indirizzo o password non corretti.',
    'ACCOUNT_NOT_VERIFIED' => 'Conferma prima il tuo indirizzo e-mail.',
    'EMAIL_ALREADY_USED' => 'Questo indirizzo e-mail è già registrato.',
    'USERNAME_ALREADY_USED' => 'Questo nome utente è già in uso.',
    'EMAIL_ALREADY_VERIFIED' => 'Questo indirizzo è già stato verificato.',
    'VERIFICATION_TOKEN_INVALID' =>
      'Il collegamento non è più valido. Richiedine uno nuovo.',
    'VERIFICATION_RESEND_RATE_LIMITED' =>
      'Hai richiesto troppi reinvii. Riprova tra qualche minuto.',
    'PASSWORD_RESET_TOKEN_INVALID' =>
      'Il collegamento non è più valido. Richiedine uno nuovo.',
    'PASSWORD_TOO_LONG' => 'La password è troppo lunga.',
    'REFRESH_TOKEN_INVALID' => 'La sessione non è più valida. Accedi di nuovo.',
    'AUTHENTICATION_REQUIRED' => 'Devi accedere per continuare.',
    'NETWORK_ERROR' => 'Connessione assente. Riprova.',
    'PLAN_INCOMPLETE' => 'Lo schema settimanale non è ancora completo.',
    'PLAN_SCHEDULE_NOT_EDITABLE' => 'Lo schema di questo piano non è più modificabile.',
    'PLAN_TRANSITION_NOT_ALLOWED' => 'Questa operazione non è più possibile per il piano.',
    'PLAN_ACTIVE_CANNOT_DELETE' => 'Un piano Attivo non può essere eliminato: sospendilo o concludilo prima.',
    'PLAN_PERIOD_OVERLAP' => 'Il periodo si sovrappone a un piano esistente.',
    _ => 'Qualcosa non ha funzionato. Riprova.',
  };
}
