import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/preferences_store.dart';
import 'package:healthylog/core/widgets/app_segmented_control.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_api.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';
import 'package:healthylog/features/measurement/providers/measurement_providers.dart';
import 'package:healthylog/features/statistics/presentation/statistics_screen.dart';
import 'package:healthylog/features/statistics/data/statistics_api.dart';
import 'package:healthylog/features/statistics/providers/statistics_providers.dart';

import '../../../support/l10n_test_support.dart';
import '../../../support/measurement_api_stub.dart';
import '../../../support/preferences_store_stub.dart';
import '../../../support/statistics_api_stub.dart';

/// *Statistiche* (11 interfaccia.md): i tre segmenti, il selettore del
/// periodo comune, e il **tono** della sezione — AD-4, AD-15, AD-16,
/// SA-6, SA-8, AN-11.

Future<void> _pumpStatistics(
  WidgetTester tester, {
  Map<String, dynamic>? adherence,
  Map<String, dynamic>? workouts,
  Map<String, dynamic>? measurements,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        statisticsApiProvider.overrideWithValue(stubStatisticsApi(
          adherence: adherence,
          workouts: workouts,
          measurements: measurements,
        )),
        measurementApiProvider.overrideWithValue(stubMeasurementApi()),
        preferencesStoreProvider.overrideWithValue(InMemoryPreferencesStore()),
      ],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, home: const StatisticsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Map<String, dynamic> _adherence({
  double? value,
  int suspendedDays = 0,
  int uncoveredDays = 0,
  List<Map<String, dynamic>> bySlotType = const [],
  List<Map<String, dynamic>>? weekly,
  List<Map<String, dynamic>> periods = const [],
}) =>
    {
      ...emptyAdherenceJson(),
      'value': value,
      'suspendedDays': suspendedDays,
      'uncoveredDays': uncoveredDays,
      'bySlotType': bySlotType,
      if (weekly != null) 'weekly': weekly,
      'periods': periods,
    };

void main() {
  /// Il selettore del periodo divide l'intestazione con i tre segmenti:
  /// ristretti, questi rimpiccioliscono di un fattore solo, uguale per
  /// tutti. Rimpicciolendo ciascuno per conto proprio, le voci del
  /// medesimo comando finirebbero di corpo diverso.
  testWidgets('le tre voci restano dello stesso corpo accanto al selettore', (tester) async {
    await _pumpStatistics(tester, adherence: _adherence(value: 75));

    double corpo(String voce) =>
        tester.renderObject<RenderParagraph>(find.text(voce)).text.style!.fontSize!;

    expect(corpo('Allenamenti'), corpo('Aderenza'));
    expect(corpo('Corpo'), corpo('Aderenza'));
    // Quanto valga il fattore non si verifica qui: il banco di prova
    // rende ogni carattere quadrato, e le larghezze non sono quelle del
    // carattere reale. Ciò che conta è che il fattore sia uno solo.
  });

  /// L'intestazione riserva al selettore la larghezza dell'etichetta più
  /// lunga: le altre vi stanno centrate, non addossate al bordo dello
  /// schermo.
  testWidgets('l\'etichetta del periodo è centrata nello spazio riservato', (tester) async {
    await _pumpStatistics(tester, adherence: _adherence(value: 75));

    final etichetta = tester.getRect(find.text('Mese'));
    final freccia = tester.getRect(find.byIcon(Icons.keyboard_arrow_down));
    final pillole = tester.getRect(find.byType(AppSegmentedControl));

    // Margine a sinistra del testo e a destra della freccia, dentro lo
    // spazio che va dal bordo dello schermo all'inizio delle pillole.
    expect(etichetta.left, closeTo(pillole.left - freccia.right, 1));
  });

  testWidgets('presenta i tre segmenti nell\'intestazione (11.1)', (tester) async {
    await _pumpStatistics(tester);

    expect(find.text('Aderenza'), findsOneWidget);
    expect(find.text('Allenamenti'), findsOneWidget);
    expect(find.text('Corpo'), findsOneWidget);
  });

  /// Il selettore del periodo sta nell'intestazione, accanto alle pillole
  /// dei segmenti: governa la schermata e non il contenuto.
  testWidgets('il selettore del periodo apre i tre orizzonti (AD-8, AD-10)', (tester) async {
    await _pumpStatistics(tester, adherence: _adherence(value: 75));

    // L'orizzonte in uso è dichiarato nell'intestazione; gli altri due
    // non occupano una riga propria finché il menu è chiuso.
    expect(find.text('Mese'), findsOneWidget);
    expect(find.text('Settimana'), findsNothing);
    expect(find.text('Piano'), findsNothing);

    await tester.tap(find.text('Mese'));
    await tester.pumpAndSettle();

    // AD-8: settimana, mese e intero piano; AD-10: nessun intervallo
    // personalizzato.
    expect(find.text('Settimana'), findsOneWidget);
    expect(find.text('Mese'), findsWidgets);
    expect(find.text('Piano'), findsOneWidget);
  });

  /// 3.2: alla prima apertura vale il mese, non la settimana.
  testWidgets('alla prima apertura l\'orizzonte è il mese', (tester) async {
    await _pumpStatistics(tester, adherence: _adherence(value: 75));

    expect(find.text('Mese'), findsOneWidget);
  });

  /// Il difetto: nel segmento *Corpo* privo di misurazioni il contenuto è
  /// una constatazione, e il selettore del periodo — che viveva dentro il
  /// contenuto — spariva con esso. Non c'era allora modo di cambiare
  /// orizzonte se non passando a un altro segmento (segnalato
  /// dall'utente).
  testWidgets('il periodo resta cambiabile anche senza misurazioni nel periodo', (tester) async {
    await _pumpStatistics(tester);

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    expect(find.text('Nessuna misurazione nel periodo'), findsOneWidget);

    await tester.tap(find.text('Mese'));
    await tester.pumpAndSettle();
    expect(find.text('Settimana'), findsOneWidget);

    await tester.tap(find.text('Settimana'));
    await tester.pumpAndSettle();
    expect(find.text('Settimana'), findsOneWidget);
    expect(find.text('Mese'), findsNothing);
  });

  /// AD-14: una barra sola non è un andamento — sull'orizzonte
  /// *Settimana* la sezione non compare.
  testWidgets('non presenta l\'andamento settimanale su una sola settimana (AD-14)',
      (tester) async {
    await _pumpStatistics(tester, adherence: _adherence(value: 75));

    expect(find.text('Andamento settimanale'), findsNothing);
  });

  testWidgets('presenta l\'andamento su più settimane (AD-14)', (tester) async {
    await _pumpStatistics(
      tester,
      adherence: _adherence(value: 75, weekly: [
        {'weekStart': '2026-03-02', 'value': 60.0},
        {'weekStart': '2026-03-09', 'value': 90.0},
      ]),
    );

    expect(find.text('Andamento settimanale'), findsOneWidget);
  });

  testWidgets('in assenza di dati valutabili constata, non presenta zero (AD-4)', (tester) async {
    await _pumpStatistics(tester);

    expect(find.text('Non ci sono ancora dati'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('arrotonda il solo risultato percentuale all\'intero più prossimo (AD-1ter)',
      (tester) async {
    // Il server restituisce il valore non arrotondato: l'arrotondamento è
    // della presentazione, e delle sole percentuali.
    await _pumpStatistics(tester, adherence: _adherence(value: 66.66666666666667));

    expect(find.text('67'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
  });

  testWidgets('dichiara i giorni esclusi dal calcolo (AD-12, AH-16)', (tester) async {
    await _pumpStatistics(
      tester,
      adherence: _adherence(value: 80, suspendedDays: 12, uncoveredDays: 3),
    );

    expect(
      find.text('Il calcolo esclude 12 giorni di sospensione e 3 giorni senza piano.'),
      findsOneWidget,
    );
  });

  testWidgets('disaggrega per tipo di pasto e per giorno della settimana (AD-13)', (tester) async {
    await _pumpStatistics(
      tester,
      adherence: _adherence(value: 75, bySlotType: [
        {'key': 'BREAKFAST', 'value': 90.0},
        {'key': 'DINNER', 'value': 50.0},
      ]),
    );

    expect(find.text('Colazione'), findsOneWidget);
    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    // LO-11: sette giorni, dal lunedì alla domenica, anche senza dati.
    expect(find.text('Lunedì'), findsOneWidget);
    expect(find.text('Domenica'), findsOneWidget);
  });

  testWidgets('sul piano con più periodi consente di alternare complessivo e periodo (ST-10)',
      (tester) async {
    await _pumpStatistics(
      tester,
      adherence: _adherence(value: 70, periods: [
        {'startDate': '2026-01-01', 'endDate': '2026-01-31', 'value': 60.0},
        {'startDate': '2026-06-01', 'endDate': '2026-06-30', 'value': 84.0},
      ]),
    );

    expect(find.text('Complessivo'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);

    await tester.tap(find.text('2° periodo'));
    await tester.pumpAndSettle();

    expect(find.text('84'), findsOneWidget);
  });

  testWidgets('senza obiettivo non presenta il confronto né segnala la mancanza (SA-6)',
      (tester) async {
    await _pumpStatistics(tester, workouts: {
      ...emptyWorkoutStatisticsJson(),
      'total': 3,
      'byActivityType': [
        {'activityType': 'Corsa', 'count': 3},
      ],
    });

    await tester.tap(find.text('Allenamenti').last);
    await tester.pumpAndSettle();

    expect(find.text('3'), findsWidgets);
    expect(find.text('Confronto con l’obiettivo'), findsNothing);
    expect(find.textContaining('obiettivo non impostato'), findsNothing);
  });

  testWidgets('presenta i due confronti come distinti (SA-5)', (tester) async {
    await _pumpStatistics(tester, workouts: {
      ...emptyWorkoutStatisticsJson(),
      'total': 3,
      'goal': 4,
      'goalDone': 3,
      'goalWeeks': 1,
      'planned': 5,
      'plannedDone': 4,
    });

    await tester.tap(find.text('Allenamenti').last);
    await tester.pumpAndSettle();

    expect(find.text('3 su 4 previsti'), findsOneWidget);
    expect(find.text('5 pianificati, 4 svolti'), findsOneWidget);
  });

  testWidgets('non aggrega le calorie in alcuna forma (CB-9, SA-8)', (tester) async {
    await _pumpStatistics(tester, workouts: {
      ...emptyWorkoutStatisticsJson(),
      'total': 2,
      'byActivityType': [
        {'activityType': 'Corsa', 'count': 2},
      ],
    });

    await tester.tap(find.text('Allenamenti').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('kcal'), findsNothing);
    expect(find.textContaining('calorie'), findsNothing);
  });

  testWidgets('presenta la variazione col proprio segno e senza qualificazioni (AN-10, AN-11)',
      (tester) async {
    await _pumpStatistics(tester, measurements: {
      ...emptyMeasurementStatisticsJson(),
      'targetWeightKg': 72.0,
      'series': [
        {
          'measure': 'WEIGHT',
          'points': [
            {'date': '2026-03-02', 'value': 80.0, 'source': 'USER'},
            {'date': '2026-03-06', 'value': 78.5, 'source': 'NUTRITIONIST'},
          ],
          'change': -1.5,
        },
      ],
    });

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    expect(find.text('−1.5'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    // AN-11: nessuna denominazione di progresso o regresso.
    expect(find.textContaining('migliorament'), findsNothing);
    expect(find.textContaining('peggiorament'), findsNothing);
  });

  testWidgets('propone le sole misure con registrazioni nel periodo (AN-2)', (tester) async {
    await _pumpStatistics(tester, measurements: {
      ...emptyMeasurementStatisticsJson(),
      'series': [
        {
          'measure': 'WAIST',
          'points': [
            {'date': '2026-03-02', 'value': 92.0, 'source': 'USER'},
          ],
          'change': null,
        },
      ],
    });

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    expect(find.text('Vita'), findsOneWidget);
    expect(find.text('Peso'), findsNothing);
  });

  testWidgets('senza misurazioni nel periodo constata, senza grafici vuoti (AN-2)', (tester) async {
    await _pumpStatistics(tester);

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    expect(find.text('Nessuna misurazione nel periodo'), findsOneWidget);
  });

  /// PR-11: la registrazione di una misurazione appartiene ora al solo
  /// segmento *Corpo* — *Allenamenti* non ospita più le misure (vedi
  /// decisioni.md). Il pulsante non deve comparire sugli altri due
  /// segmenti, che non hanno nulla da registrare.
  testWidgets('offre la registrazione di una misurazione dal solo segmento Corpo (PR-11)',
      (tester) async {
    await _pumpStatistics(tester, adherence: _adherence(value: 75));

    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.text('Aderenza'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  /// 4.4: senza misurazioni nel periodo il contenuto è una
  /// constatazione — ed è proprio allora che la registrazione serve.
  testWidgets('la registrazione resta offerta anche senza misurazioni nel periodo', (tester) async {
    await _pumpStatistics(tester);

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Registra una misurazione'), findsOneWidget);
  });
  /// AD-8bis: i periodi trascorsi si raggiungono con le frecce. Prima
  /// erano visibili la sola settimana, il solo mese e il solo piano
  /// correnti — segnalato dall'utente.
  testWidgets('scorre ai mesi trascorsi e la data raggiunge il server (AD-8bis)',
      (tester) async {
    final adapter = await _pumpRecording(tester);
    final oggi = DateTime.now();

    // Il primo caricamento riferisce il periodo corrente.
    expect(_lastDate(adapter), _iso(oggi));
    // Non si va oltre: le statistiche non riferiscono il futuro.
    expect(_iconButton(tester, Icons.chevron_right).onPressed, isNull);
    // E finché si è sul corrente non c'è dove tornare.
    expect(find.text('Oggi'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    // Il mese precedente, riferito al suo primo giorno.
    final precedente = DateTime(oggi.year, oggi.month - 1, 1);
    expect(_lastDate(adapter), _iso(precedente));
    // Ora si può tornare avanti, e tornare al corrente.
    expect(_iconButton(tester, Icons.chevron_right).onPressed, isNotNull);

    await tester.tap(find.text('Oggi'));
    await tester.pumpAndSettle();

    expect(_lastDate(adapter), _iso(oggi));
    expect(find.text('Oggi'), findsNothing);
  });

  /// I tre segmenti guardano il medesimo periodo: il navigatore lo governa
  /// per tutti, come il selettore dell'orizzonte (11.1).
  testWidgets('il periodo scelto vale anche per gli altri segmenti', (tester) async {
    final adapter = await _pumpRecording(tester);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allenamenti'));
    await tester.pumpAndSettle();

    final oggi = DateTime.now();
    expect(adapter.queries.last.path, contains('workouts'));
    expect(_lastDate(adapter), _iso(DateTime(oggi.year, oggi.month - 1, 1)));
  });

  /// AD-8bis, ST-9: sull'orizzonte *Piano* il periodo è il piano, e le
  /// frecce scorrono quelli che sono stati in vigore, dal più recente al
  /// più antico.
  testWidgets('scorre i piani trascorsi sull\'orizzonte Piano (AD-8bis)', (tester) async {
    final adapter = await _pumpRecording(tester, plans: [
      _plan(id: 'p-2', name: 'Piano estivo', start: '2026-06-01'),
      _plan(id: 'p-1', name: 'Piano invernale', start: '2026-01-07'),
    ]);

    await tester.tap(find.text('Mese'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Piano').last);
    await tester.pumpAndSettle();

    // Senza piano indicato vale quello in corso (PA-8): il più recente.
    expect(find.text('Piano estivo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.text('Piano invernale'), findsOneWidget);
    expect(adapter.queries.last.parameters['planId'], 'p-1');
    // Non si va oltre il più antico.
    expect(_iconButton(tester, Icons.chevron_left).onPressed, isNull);
  });

}

/// Registra le interrogazioni, per verificare che il periodo scelto
/// raggiunga davvero il server e non sia una cernita a valle.
class _RecordingStatisticsAdapter implements HttpClientAdapter {
  _RecordingStatisticsAdapter({this.plans = const []});

  final List<Map<String, dynamic>> plans;
  final queries = <({String path, Map<String, dynamic> parameters})>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    queries.add((path: options.path, parameters: Map<String, dynamic>.from(options.queryParameters)));
    if (options.path == '/diet-plans') {
      return ResponseBody.fromString(
        jsonEncode(plans),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    final body = options.path.contains('workouts')
        ? emptyWorkoutStatisticsJson()
        : options.path.contains('measurements')
            ? emptyMeasurementStatisticsJson()
            : emptyAdherenceJson();
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Future<_RecordingStatisticsAdapter> _pumpRecording(
  WidgetTester tester, {
  List<Map<String, dynamic>> plans = const [],
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final adapter = _RecordingStatisticsAdapter(plans: plans);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        statisticsApiProvider.overrideWithValue(StatisticsApi(dio)),
        dietPlanApiProvider.overrideWithValue(DietPlanApi(dio)),
        measurementApiProvider.overrideWithValue(stubMeasurementApi()),
        preferencesStoreProvider.overrideWithValue(InMemoryPreferencesStore()),
      ],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: const StatisticsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

String? _lastDate(_RecordingStatisticsAdapter adapter) =>
    adapter.queries.last.parameters['date'] as String?;

String _iso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

IconButton _iconButton(WidgetTester tester, IconData icon) =>
    tester.widget<IconButton>(find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton)).first);

Map<String, dynamic> _plan({required String id, required String name, required String start}) => {
      'id': id,
      'ownerId': 'user-1',
      'authorId': 'user-1',
      'authorRole': 'USER',
      'name': name,
      'notes': null,
      'status': 'COMPLETED',
      'startDate': start,
      'endDate': start,
      'weeklySchedule': <Map<String, dynamic>>[],
      'periods': [
        {'startDate': start, 'endDate': start},
      ],
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-01T00:00:00Z',
    };
