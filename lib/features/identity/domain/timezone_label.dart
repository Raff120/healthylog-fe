import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';

/// Etichetta del fuso orario nella lingua selezionata (LO-1, LO-13).
///
/// Un identificativo assente dall'elenco curato — accettato dal server
/// per altra via — è presentato tale e quale: è pur sempre leggibile, e
/// inventarne una traduzione sarebbe peggio.
String timezoneLabel(BuildContext context, String timezoneId) {
  final l10n = context.l10n;
  return switch (timezoneId) {
    'Europe/Rome' => l10n.timezoneEuropeRome,
    'Europe/London' => l10n.timezoneEuropeLondon,
    'Europe/Dublin' => l10n.timezoneEuropeDublin,
    'Europe/Lisbon' => l10n.timezoneEuropeLisbon,
    'Europe/Madrid' => l10n.timezoneEuropeMadrid,
    'Europe/Paris' => l10n.timezoneEuropeParis,
    'Europe/Berlin' => l10n.timezoneEuropeBerlin,
    'Europe/Amsterdam' => l10n.timezoneEuropeAmsterdam,
    'Europe/Zurich' => l10n.timezoneEuropeZurich,
    'Europe/Vienna' => l10n.timezoneEuropeVienna,
    'Europe/Athens' => l10n.timezoneEuropeAthens,
    'Europe/Helsinki' => l10n.timezoneEuropeHelsinki,
    'Europe/Moscow' => l10n.timezoneEuropeMoscow,
    'Africa/Cairo' => l10n.timezoneAfricaCairo,
    'Africa/Johannesburg' => l10n.timezoneAfricaJohannesburg,
    'America/New_York' => l10n.timezoneAmericaNewYork,
    'America/Chicago' => l10n.timezoneAmericaChicago,
    'America/Denver' => l10n.timezoneAmericaDenver,
    'America/Los_Angeles' => l10n.timezoneAmericaLosAngeles,
    'America/Sao_Paulo' => l10n.timezoneAmericaSaoPaulo,
    'America/Argentina/Buenos_Aires' => l10n.timezoneAmericaArgentinaBuenosAires,
    'Asia/Dubai' => l10n.timezoneAsiaDubai,
    'Asia/Kolkata' => l10n.timezoneAsiaKolkata,
    'Asia/Bangkok' => l10n.timezoneAsiaBangkok,
    'Asia/Hong_Kong' => l10n.timezoneAsiaHongKong,
    'Asia/Shanghai' => l10n.timezoneAsiaShanghai,
    'Asia/Seoul' => l10n.timezoneAsiaSeoul,
    'Asia/Tokyo' => l10n.timezoneAsiaTokyo,
    'Australia/Perth' => l10n.timezoneAustraliaPerth,
    'Australia/Sydney' => l10n.timezoneAustraliaSydney,
    'Pacific/Auckland' => l10n.timezonePacificAuckland,
    'UTC' => l10n.timezoneUtc,
    _ => timezoneId,
  };
}
