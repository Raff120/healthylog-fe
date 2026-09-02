/// Elenco curato di fusi IANA (LO-13, 12.2 interfaccia.md), non l'intero
/// database (centinaia di voci): un sottoinsieme rappresentativo dei
/// principali fusi mondiali, proporzionato alla scala dell'applicazione
/// (TS-9). Il backend resta l'autorità sulla validità del valore
/// (`PATCH /me/timezone`): un identificativo IANA valido ma assente da
/// questo elenco resta comunque accettato se mai raggiungesse l'API per
/// altra via, semplicemente non è proponibile da qui.
class TimezoneOption {
  const TimezoneOption(this.id, this.label);

  final String id;
  final String label;
}

const List<TimezoneOption> kTimezoneOptions = [
  TimezoneOption('Europe/Rome', 'Roma'),
  TimezoneOption('Europe/London', 'Londra'),
  TimezoneOption('Europe/Dublin', 'Dublino'),
  TimezoneOption('Europe/Lisbon', 'Lisbona'),
  TimezoneOption('Europe/Madrid', 'Madrid'),
  TimezoneOption('Europe/Paris', 'Parigi'),
  TimezoneOption('Europe/Berlin', 'Berlino'),
  TimezoneOption('Europe/Amsterdam', 'Amsterdam'),
  TimezoneOption('Europe/Zurich', 'Zurigo'),
  TimezoneOption('Europe/Vienna', 'Vienna'),
  TimezoneOption('Europe/Athens', 'Atene'),
  TimezoneOption('Europe/Helsinki', 'Helsinki'),
  TimezoneOption('Europe/Moscow', 'Mosca'),
  TimezoneOption('Africa/Cairo', 'Il Cairo'),
  TimezoneOption('Africa/Johannesburg', 'Johannesburg'),
  TimezoneOption('Asia/Dubai', 'Dubai'),
  TimezoneOption('Asia/Kolkata', 'Nuova Delhi'),
  TimezoneOption('Asia/Bangkok', 'Bangkok'),
  TimezoneOption('Asia/Shanghai', 'Shanghai'),
  TimezoneOption('Asia/Hong_Kong', 'Hong Kong'),
  TimezoneOption('Asia/Tokyo', 'Tokyo'),
  TimezoneOption('Asia/Seoul', 'Seul'),
  TimezoneOption('Australia/Sydney', 'Sydney'),
  TimezoneOption('Australia/Perth', 'Perth'),
  TimezoneOption('Pacific/Auckland', 'Auckland'),
  TimezoneOption('America/Sao_Paulo', 'San Paolo'),
  TimezoneOption('America/Argentina/Buenos_Aires', 'Buenos Aires'),
  TimezoneOption('America/New_York', 'New York'),
  TimezoneOption('America/Chicago', 'Chicago'),
  TimezoneOption('America/Denver', 'Denver'),
  TimezoneOption('America/Los_Angeles', 'Los Angeles'),
  TimezoneOption('UTC', 'UTC'),
];
