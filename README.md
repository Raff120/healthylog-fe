# healthylog-fe

Client di HealthyLog — Flutter, Dart, Riverpod 3.

## Prerequisiti

- Flutter 3.47.2 (canale stable)
- Il backend (`healthylog-be`) in esecuzione e raggiungibile

## Struttura

```
lib/
├── app/        → configurazione, tema, punti di rottura
├── core/       → client HTTP, storage locale, sincronizzazione, sessione, widget condivisi
└── features/   → un modulo per dominio (data/domain/providers/presentation)
```

Vedi `docs/specifica-tecnica.md` FE-5, FE-6 per il dettaglio.

## Generazione di codice

I provider Riverpod (`@riverpod`) richiedono la generazione dei file `.g.dart`:

```bash
dart run build_runner build
```

Durante lo sviluppo, per rigenerare automaticamente ad ogni modifica:

```bash
dart run build_runner watch
```

## Avvio in sviluppo

L'indirizzo del backend è configurabile a compilazione (default `http://localhost:8080`):

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

## Test

```bash
flutter test
```
