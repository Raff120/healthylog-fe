File ARB di traduzione (LO-1).

`app_it.arb` è il **modello**: l'applicazione è scritta in italiano
(CN-1) e ogni nuova voce si aggiunge prima lì, con la sua descrizione.
`app_en.arb` ne è la traduzione; `flutter gen-l10n` segnala le voci
mancanti.

Le classi generate stanno in `generated/` e non sono versionate a mano:
si rigenerano con `flutter gen-l10n` (o con qualunque `flutter run` /
`flutter test`, che lo eseguono da sé).

LO-3: i contenuti inseriti dagli Utenti — contenuto degli slot, note,
denominazioni di piani, template e Gruppi, tipi di attività — non
compaiono qui e non vanno tradotti né alterati in alcun modo.
