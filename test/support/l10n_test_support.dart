import 'package:flutter/widgets.dart';
import 'package:healthylog/l10n/generated/app_localizations.dart';

/// Delegati e lingue di traduzione (LO-1) che ogni banco di prova deve
/// fornire al proprio `MaterialApp`: senza di essi `context.l10n` non
/// trova le traduzioni e la schermata non si costruisce.
///
/// La lingua è l'italiano — prima delle due di LO-1 — così che le
/// asserzioni sui testi restino quelle già scritte.
const List<LocalizationsDelegate<dynamic>> testLocalizationsDelegates = L10n.localizationsDelegates;

const List<Locale> testSupportedLocales = L10n.supportedLocales;

/// Senza una lingua esplicita `MaterialApp` adotterebbe quella della
/// piattaforma di prova (inglese), e le asserzioni sui testi italiani
/// fallirebbero. Le prove che riguardano l'inglese la indicano invece.
const Locale testLocale = Locale('it');
