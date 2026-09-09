import '../../../support/l10n_test_support.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_api.dart';
import 'package:healthylog/features/dietplan/data/meal_swap_api.dart';
import 'package:healthylog/features/dietplan/presentation/diet_plan_view_screen.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';
import 'package:healthylog/features/dietplan/providers/meal_swap_providers.dart';
import 'package:healthylog/features/statistics/providers/statistics_providers.dart';

import '../../../support/statistics_api_stub.dart';

/// 7.5 interfaccia.md, ST-7: dettaglio di sola lettura di un piano
/// Concluso — intestazione, periodi di svolgimento (ST-9), statistiche del
/// periodo (ST-4), schema settimanale, storico delle inversioni (ST-5) ed
/// eliminazione (CV-10, ST-14).
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._responseFor);

  final Object? Function(RequestOptions options) _responseFor;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = _responseFor(options);
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Map<String, dynamic> _planJson({List<Map<String, dynamic>> periods = const []}) => {
      'id': 'plan-1',
      'ownerId': 'user-1',
      'authorId': 'user-1',
      'authorRole': 'USER',
      'name': 'Dieta invernale',
      'status': 'COMPLETED',
      'startDate': '2026-01-01',
      'endDate': '2026-03-01',
      'periods': periods,
      'suspensions': <Map<String, dynamic>>[],
      'adherence': null,
      'weeklySchedule': [
        {
          'dayOfWeek': 'MONDAY',
          'slots': [
            {
              'slotId': 'slot-1',
              'type': 'BREAKFAST',
              'label': null,
              'order': 0,
              'content': 'Yogurt e cereali',
              'note': null,
              'recipeName': null,
              'recipeText': null,
              'adherenceWeight': 1.0,
            },
          ],
        },
        for (final day in ['TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'])
          {'dayOfWeek': day, 'slots': <dynamic>[]},
      ],
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-01T00:00:00Z',
    };

Future<void> _pumpViewScreen(
  WidgetTester tester,
  DietPlanApi api, {
  Map<String, dynamic>? adherence,
  List<Map<String, dynamic>> swaps = const [],
}) async {
  // La schermata è lunga (cinque sezioni, 7.5): un riquadro alto evita di
  // dover scorrere per raggiungere lo storico in coda.
  tester.view.physicalSize = const Size(500, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final swapDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _JsonAdapter((_) => swaps)
    ..interceptors.add(ApiErrorInterceptor());
  final router = GoRouter(
    initialLocation: '/diet-plans/plan-1',
    routes: [
      GoRoute(
        path: '/diet-plans/:id',
        builder: (context, state) => DietPlanViewScreen(planId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/profile/plans', builder: (context, state) => const Scaffold(body: Text('Gestione piano'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dietPlanApiProvider.overrideWithValue(api),
        mealSwapApiProvider.overrideWithValue(MealSwapApi(swapDio)),
        statisticsApiProvider.overrideWithValue(stubStatisticsApi(adherence: adherence)),
      ],
      child: MaterialApp.router(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra denominazione, periodo e schema di sola lettura (7.5)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpViewScreen(tester, DietPlanApi(dio));

    expect(find.text('Dieta invernale'), findsOneWidget);
    expect(find.text('01/01/2026 – 01/03/2026'), findsOneWidget);
    expect(find.text('Yogurt e cereali'), findsOneWidget);
    expect(find.text('Schema settimanale'), findsOneWidget);
    // Sola lettura: nessuna card espandibile né maniglia di riordino.
    expect(find.byType(ReorderableListView), findsNothing);
  });

  /// ST-4: aderenza complessiva e disaggregazione per tipo di slot, in
  /// forma ridotta; il tocco conduce alle statistiche complete.
  testWidgets('presenta le statistiche del periodo in forma ridotta (ST-4)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpViewScreen(tester, DietPlanApi(dio), adherence: {
      ...emptyAdherenceJson(),
      'value': 72.4,
      'bySlotType': [
        {'key': 'LUNCH', 'value': 64.0},
      ],
    });

    expect(find.text('Statistiche del periodo'), findsOneWidget);
    expect(find.text('72'), findsOneWidget);
    expect(find.text('Pranzo'), findsOneWidget);
    expect(find.text('Apri le statistiche complete'), findsOneWidget);
  });

  /// ST-9, ST-10: i periodi attraversati dal piano riattivato, ciascuno
  /// con le proprie date e la propria aderenza.
  testWidgets('elenca i periodi di svolgimento con la rispettiva aderenza (ST-9)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson(periods: [
          {'startDate': '2026-01-01', 'endDate': '2026-01-31'},
          {'startDate': '2026-02-01', 'endDate': '2026-03-01'},
        ]));
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpViewScreen(tester, DietPlanApi(dio), adherence: {
      ...emptyAdherenceJson(),
      'value': 70.0,
      'periods': [
        {'startDate': '2026-01-01', 'endDate': '2026-01-31', 'value': 60.0},
        {'startDate': '2026-02-01', 'endDate': '2026-03-01', 'value': 84.0},
      ],
    });

    expect(find.text('Periodi di svolgimento'), findsOneWidget);
    expect(find.text('Dal 01/01/2026 a 31/01/2026'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('84%'), findsOneWidget);
  });

  /// ST-5, IN-24, IN-25: lo storico delle inversioni, di sola lettura.
  testWidgets('presenta lo storico delle inversioni (ST-5)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpViewScreen(tester, DietPlanApi(dio), swaps: [
      {
        'id': 'swap-1',
        'performedBy': 'user-1',
        'performedAt': '2026-02-10T10:00:00Z',
        'first': {'date': '2026-02-10', 'slotId': 'slot-1', 'type': 'LUNCH'},
        'second': {'date': '2026-02-11', 'slotId': 'slot-2', 'type': 'DINNER'},
      },
    ]);

    expect(find.text('Storico delle inversioni'), findsOneWidget);
    expect(find.text('10/02/2026 Pranzo ↔ 11/02/2026 Cena'), findsOneWidget);
  });

  /// 4.4: senza inversioni una constatazione, mai la segnalazione di una
  /// mancanza.
  testWidgets('senza inversioni constata soltanto (ST-5)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpViewScreen(tester, DietPlanApi(dio));

    expect(find.text('Nessuna inversione su questo piano.'), findsOneWidget);
  });

  testWidgets('"Elimina" richiede conferma rafforzata e conduce alla gestione (CV-10)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    var deleteCalled = false;
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'DELETE') {
        deleteCalled = true;
        return <String, dynamic>{};
      }
      return _planJson();
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpViewScreen(tester, DietPlanApi(dio));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isFalse);
    expect(find.text('Eliminare il piano?'), findsOneWidget);
    // ST-14: tutti i periodi, e con essi lo storico delle inversioni.
    expect(find.textContaining('per tutti i periodi del piano'), findsOneWidget);
    expect(find.text('•  lo storico delle inversioni'), findsOneWidget);
    // ST-15: allenamenti e misurazioni sono dati indipendenti e restano.
    expect(find.text('Allenamenti e misurazioni dello stesso periodo restano.'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Elimina')));
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
    expect(find.text('Gestione piano'), findsOneWidget);
  });
}
