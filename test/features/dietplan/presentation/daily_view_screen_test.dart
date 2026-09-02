import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_api.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/daily_view_screen.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';

/// VG-3, VG-4: tutti gli slot della giornata restano sempre visibili,
/// quale sia il loro stato di consumo — nessuno nascosto né evidenziato
/// come "il prossimo".
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._body);

  final Object? _body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(_body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// La data rispecchia sempre quella richiesta (EP-3): coincide qui con
/// l'apertura della vista sulla giornata corrente (VG-2), la sola
/// interrogata dagli adattatori a corpo fisso di questo file.
Map<String, dynamic> _dayJson() => {
      'date': isoDate(dateOnly(DateTime.now())),
      'coverage': 'ACTIVE',
      'planId': 'plan-1',
      'planName': 'Dieta',
      'planStartDate': '2026-09-01',
      'planEndDate': null,
      'slots': [
        {
          'slotId': 's1',
          'type': 'BREAKFAST',
          'label': null,
          'order': 0,
          'content': 'Yogurt e cereali',
          'note': null,
          'recipeName': null,
          'recipeText': null,
          'status': 'TO_CONSUME',
        },
        {
          'slotId': 's2',
          'type': 'LUNCH',
          'label': null,
          'order': 1,
          'content': 'Pasta al pomodoro',
          'note': 'Con parmigiano a parte',
          'recipeName': 'Pasta al pomodoro fresca',
          'recipeText': 'Cuocere la pasta...',
          'status': 'CONSUMED',
        },
        {
          'slotId': 's3',
          'type': 'SNACK',
          'label': 'Spuntino del pomeriggio',
          'order': 2,
          'content': 'Frutta secca',
          'note': null,
          'recipeName': null,
          'recipeText': null,
          'status': 'SKIPPED',
        },
      ],
    };

/// VG-16, VG-17: risponde con un contenuto diverso a seconda della data
/// richiesta, per verificare che la navigazione interroghi davvero il
/// giorno atteso.
class _ByDateAdapter implements HttpClientAdapter {
  _ByDateAdapter(this._responseFor);

  final Map<String, dynamic> Function(String date) _responseFor;
  final requestedDates = <String>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final date = options.queryParameters['date'] as String;
    requestedDates.add(date);
    return ResponseBody.fromString(
      jsonEncode(_responseFor(date)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// Come [_JsonAdapter], ma calcola il corpo al momento della richiesta:
/// serve dove l'esito dipende da uno stato mutabile del banco di prova
/// (es. CV-S6, la ripresa che cambia la giornata successiva).
class _FetchAdapter implements HttpClientAdapter {
  _FetchAdapter(this._responseFor);

  final Object? Function(RequestOptions options) _responseFor;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(_responseFor(options)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Map<String, dynamic> _dayJsonFor(String date, String content) => {
      'date': date,
      'coverage': 'ACTIVE',
      'planId': 'plan-1',
      'planName': 'Dieta',
      'planStartDate': '2026-01-01',
      'planEndDate': null,
      'slots': [
        {
          'slotId': 's1',
          'type': 'LUNCH',
          'label': null,
          'order': 0,
          'content': content,
          'note': null,
          'recipeName': null,
          'recipeText': null,
          'status': 'TO_CONSUME',
        },
      ],
    };

Future<void> _pumpDailyView(WidgetTester tester, Map<String, dynamic> dayJson) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _JsonAdapter(dayJson);
  dio.interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [planDayApiProvider.overrideWithValue(PlanDayApi(dio))],
      child: MaterialApp(theme: AppTheme.light, home: const DailyViewScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Come [_pumpDailyView], con l'elenco dei piani del proprietario
/// (7.1 interfaccia.md) sostituito — necessario per distinguere "nessun
/// piano mai creato" da "nessun piano per questo giorno" (PA-10).
Future<void> _pumpDailyViewWithOwnedPlans(
  WidgetTester tester,
  Map<String, dynamic> dayJson,
  DietPlanApi ownedPlansApi,
) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _JsonAdapter(dayJson);
  dio.interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
        dietPlanApiProvider.overrideWithValue(ownedPlansApi),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const DailyViewScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Elenco dei piani del proprietario (7.1 interfaccia.md), per
/// distinguere "nessun piano mai creato" da "nessun piano per questo
/// giorno" (4.4 interfaccia.md, PA-10).
DietPlanApi _ownedPlansApi(List<Map<String, dynamic>> plans) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _JsonAdapter(plans);
  dio.interceptors.add(ApiErrorInterceptor());
  return DietPlanApi(dio);
}

void main() {
  testWidgets('presenta tutti gli slot della giornata quale sia il loro stato (VG-3, VG-4)', (tester) async {
    await _pumpDailyView(tester, _dayJson());

    expect(find.text('Yogurt e cereali'), findsOneWidget);
    expect(find.text('Pasta al pomodoro'), findsOneWidget);
    expect(find.text('Frutta secca'), findsOneWidget);
    // GG-15: la denominazione della ricetta è visibile già a card chiusa.
    expect(find.text('Pasta al pomodoro fresca'), findsOneWidget);
    // GG-10: lo spuntino usa la denominazione descrittiva del piano.
    expect(find.text('Spuntino del pomeriggio'), findsOneWidget);
    expect(find.text('Spuntino'), findsNothing);
    // La nota accessoria compare solo da aperta (4.1 interfaccia.md).
    expect(find.text('Con parmigiano a parte'), findsNothing);

    await tester.tap(find.text('Pasta al pomodoro'));
    await tester.pumpAndSettle();

    expect(find.text('Con parmigiano a parte'), findsOneWidget);

    // GG-15, GG-18: "Vedi ricetta" apre il foglio con il testo integrale.
    await tester.tap(find.text('Vedi ricetta'));
    await tester.pumpAndSettle();

    expect(find.text('Pasta al pomodoro fresca'), findsWidgets);
    expect(find.text('Cuocere la pasta...'), findsOneWidget);
  });

  testWidgets('una giornata senza pasti previsti presenta lo stato vuoto (GG-7)', (tester) async {
    final day = _dayJson();
    day['slots'] = <dynamic>[];

    await _pumpDailyView(tester, day);

    expect(find.text('Nessun pasto previsto'), findsOneWidget);
  });

  testWidgets('lo scorrimento orizzontale del contenuto naviga al giorno successivo e precedente (VG-16, 6.2)',
      (tester) async {
    final today = dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final adapter = _ByDateAdapter((date) {
      if (date == isoDate(tomorrow)) return _dayJsonFor(date, 'Pesce al forno');
      return _dayJsonFor(date, 'Pasta al pomodoro');
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(ApiErrorInterceptor());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [planDayApiProvider.overrideWithValue(PlanDayApi(dio))],
        child: MaterialApp(theme: AppTheme.light, home: const DailyViewScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pasta al pomodoro'), findsOneWidget);
    expect(adapter.requestedDates, [isoDate(today)]);

    await tester.fling(find.byKey(const Key('dailyViewContentSwipe')), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();

    expect(find.text('Pesce al forno'), findsOneWidget);
    expect(adapter.requestedDates, [isoDate(today), isoDate(tomorrow)]);

    await tester.fling(find.byKey(const Key('dailyViewContentSwipe')), const Offset(300, 0), 800);
    await tester.pumpAndSettle();

    expect(find.text('Pasta al pomodoro'), findsOneWidget);
    expect(adapter.requestedDates, [isoDate(today), isoDate(tomorrow), isoDate(today)]);
  });

  testWidgets('un piano Programmato mostra la striscia informativa e comunque il contenuto (VG-18)', (tester) async {
    final day = _dayJson();
    day['coverage'] = 'SCHEDULED';
    day['planStartDate'] = '2026-10-01';

    await _pumpDailyView(tester, day);

    expect(find.text('Il piano inizia il 01/10/2026'), findsOneWidget);
    expect(find.text('Yogurt e cereali'), findsOneWidget);
  });

  testWidgets('un piano Concluso mostra la striscia informativa e comunque il contenuto (VG-18)', (tester) async {
    final day = _dayJson();
    day['coverage'] = 'COMPLETED';
    day['planEndDate'] = '2026-08-31';

    await _pumpDailyView(tester, day);

    expect(find.text('Piano concluso il 31/08/2026'), findsOneWidget);
    expect(find.text('Yogurt e cereali'), findsOneWidget);
  });

  testWidgets('una giornata sospesa non presenta alcuno slot e offre "Riprendi" (VG-18, CV-S3)', (tester) async {
    var suspended = true;
    // CV-S6: la giornata cambia esito dopo la ripresa, non un corpo fisso.
    final planDayDio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    planDayDio.httpClientAdapter = _FetchAdapter((options) {
      if (suspended) {
        return _dayJson()..['coverage'] = 'SUSPENDED';
      }
      return _dayJson();
    });
    planDayDio.interceptors.add(ApiErrorInterceptor());

    final dietPlanDio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dietPlanDio.httpClientAdapter = _FetchAdapter((options) {
      if (options.path.contains('/resume')) {
        suspended = false;
      }
      return {
        'id': 'plan-1',
        'ownerId': 'user-1',
        'authorId': 'user-1',
        'authorRole': 'USER',
        'name': 'Dieta',
        'status': 'ACTIVE',
        'startDate': '2026-09-01',
        'endDate': null,
        'weeklySchedule': [
          for (final day in ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'])
            {'dayOfWeek': day, 'slots': <dynamic>[]},
        ],
        'createdAt': '2026-09-01T00:00:00Z',
        'updatedAt': '2026-09-01T00:00:00Z',
      };
    });
    dietPlanDio.interceptors.add(ApiErrorInterceptor());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
          dietPlanApiProvider.overrideWithValue(DietPlanApi(dietPlanDio)),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const DailyViewScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Piano sospeso'), findsOneWidget);
    expect(find.text('Riprenderà quando lo deciderai'), findsOneWidget);
    expect(find.text('Yogurt e cereali'), findsNothing);

    await tester.tap(find.text('Riprendi'));
    await tester.pumpAndSettle();

    expect(find.text('Piano sospeso'), findsNothing);
    expect(find.text('Yogurt e cereali'), findsOneWidget);
  });

  testWidgets('nessun piano mai creato mostra l\'invito a crearne uno (PA-10, 4.4)', (tester) async {
    final day = _dayJson();
    day['coverage'] = 'NONE';
    day['planId'] = null;
    day['planName'] = null;
    day['planStartDate'] = null;
    day['planEndDate'] = null;
    day['slots'] = <dynamic>[];

    await _pumpDailyViewWithOwnedPlans(tester, day, _ownedPlansApi(const []));

    expect(find.text('Inizia da qui'), findsOneWidget);
    expect(find.text('Crea piano'), findsOneWidget);
  });

  testWidgets('una giornata fuori piano non offre alcuna azione quando altri piani esistono (PA-10, 4.4)',
      (tester) async {
    final day = _dayJson();
    day['coverage'] = 'NONE';
    day['planId'] = null;
    day['planName'] = null;
    day['planStartDate'] = null;
    day['planEndDate'] = null;
    day['slots'] = <dynamic>[];

    await _pumpDailyViewWithOwnedPlans(
      tester,
      day,
      _ownedPlansApi([
        {
          'id': 'plan-1',
          'ownerId': 'user-1',
          'authorId': 'user-1',
          'authorRole': 'USER',
          'name': 'Dieta',
          'status': 'COMPLETED',
          'startDate': '2026-01-01',
          'endDate': '2026-03-01',
          'weeklySchedule': [
            for (final wd in ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'])
              {'dayOfWeek': wd, 'slots': <dynamic>[]},
          ],
          'createdAt': '2026-01-01T00:00:00Z',
          'updatedAt': '2026-01-01T00:00:00Z',
        },
      ]),
    );

    expect(find.text('Nessun piano per questo giorno'), findsOneWidget);
    expect(find.text('Crea piano'), findsNothing);
  });
}
