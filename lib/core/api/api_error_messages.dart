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
    'PLAN_NOT_ACTIVE' => 'Questa giornata non è coperta da un piano attivo.',
    'TIMEZONE_INVALID' => 'Fuso orario non riconosciuto.',
    // 6.4 funzionale, IN-21: ragioni di rifiuto dell'inversione, desunte
    // dalle regole — usate sia per il rifiuto del server sia, sul client,
    // per la barra a chi insiste su uno slot non compatibile (6.5
    // interfaccia.md).
    'SWAP_PAST_DAY' => 'Questo giorno è già trascorso.',
    'SLOT_ALREADY_CONSUMED' => 'Questo pasto è già stato consumato.',
    'SWAP_TYPE_NOT_ALLOWED' => 'Questi pasti non sono invertibili tra loro.',
    'SWAP_DIFFERENT_WEEKS' => 'Appartengono a settimane diverse.',
    'SWAP_DIFFERENT_DAYS' => 'Devono appartenere allo stesso giorno.',
    // 7 funzionale, F23: allenamenti.
    'WORKOUT_FUTURE_DATE' =>
      'Un allenamento si registra quando è stato svolto: per il futuro c\'è la pianificazione.',
    // 4.4 funzionale, F19: gruppo, inviti e membri.
    'ALREADY_IN_GROUP' => 'Fai già parte di un gruppo: esci prima di crearne uno nuovo.',
    'NUTRITIONIST_CANNOT_JOIN_GROUP' => 'Un Nutrizionista non può appartenere a un gruppo.',
    'INVITE_CODE_INVALID' => 'Il codice inserito non è valido.',
    'OWNER_COOK_PRIVILEGE_INSEPARABLE' =>
      'Il Proprietario non può rinunciare al privilegio di Cuoco: trasferisci prima la proprietà.',
    // 4.3 e 5.3 funzionale, F21/F22: collegamento professionale e Paziente.
    'ALREADY_LINKED' => 'La persona è già collegata a un nutrizionista: serve prima la revoca di quel collegamento.',
    'CARE_LINK_REQUEST_NOT_PENDING' => 'Questa richiesta non è più in attesa.',
    'CARE_LINK_REQUEST_ALREADY_PENDING' => 'Hai già una richiesta in attesa verso questa persona.',
    'CARE_LINK_NOT_ACTIVE' => 'Il collegamento è già stato revocato.',
    'PATIENT_PLAN_LOCKED' => 'Il piano è a cura del tuo nutrizionista: puoi spuntare e invertire, non modificarne il contenuto.',
    'PAST_DAY_NOT_EDITABLE' => 'Le giornate trascorse non si possono modificare.',
    _ => 'Qualcosa non ha funzionato. Riprova.',
  };
}
