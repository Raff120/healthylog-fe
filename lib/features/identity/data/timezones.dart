/// Elenco curato di fusi IANA (LO-13, 12.2 interfaccia.md), non l'intero
/// database (centinaia di voci): un sottoinsieme rappresentativo dei
/// principali fusi mondiali, proporzionato alla scala dell'applicazione
/// (TS-9). Il backend resta l'autorità sulla validità del valore
/// (`PATCH /me/timezone`): un identificativo IANA valido ma assente da
/// questo elenco resta comunque accettato se mai raggiungesse l'API per
/// altra via, semplicemente non è proponibile da qui.
///
/// L'etichetta non è conservata qui ma risolta dal livello di traduzione
/// (LO-1): "Roma" in italiano, "Rome" in inglese. Qui resta il solo
/// identificativo IANA, che è il dato — vedi `timezoneLabel`.
const List<String> kTimezoneIds = [
  'Europe/Rome',
  'Europe/London',
  'Europe/Dublin',
  'Europe/Lisbon',
  'Europe/Madrid',
  'Europe/Paris',
  'Europe/Berlin',
  'Europe/Amsterdam',
  'Europe/Zurich',
  'Europe/Vienna',
  'Europe/Athens',
  'Europe/Helsinki',
  'Europe/Moscow',
  'Africa/Cairo',
  'Africa/Johannesburg',
  'Asia/Dubai',
  'Asia/Kolkata',
  'Asia/Bangkok',
  'Asia/Shanghai',
  'Asia/Hong_Kong',
  'Asia/Tokyo',
  'Asia/Seoul',
  'Australia/Sydney',
  'Australia/Perth',
  'Pacific/Auckland',
  'America/Sao_Paulo',
  'America/Argentina/Buenos_Aires',
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'UTC',
];
