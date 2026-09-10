import '../../../support/l10n_test_support.dart';
import '../../../support/notification_api_stub.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_api.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/plan_screen.dart';
import 'package:healthylog/features/care/providers/care_providers.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import 'package:healthylog/features/group/data/cooking_group_api.dart';
import 'package:healthylog/features/group/providers/cooking_group_providers.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';
import 'package:healthylog/features/notification/providers/notification_providers.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';

import '../../../support/care_api_stub.dart';
import '../../../support/workout_api_stub.dart';

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

/// Risponde sia a `GET /plan-days?date=` sia a `GET
/// /plan-days?from=&to=` (6.1, 6.2 funzionale): la vista settimanale
/// (VS-1) e quella giornaliera condividono lo stesso client nello
/// stesso banco di prova.
class _DayOrRangeAdapter implements HttpClientAdapter {
  _DayOrRangeAdapter({required this.dayResponseFor, required this.rangeResponseFor});

  final Map<String, dynamic> Function(String date) dayResponseFor;
  final List<Map<String, dynamic>> Function(String from, String to) rangeResponseFor;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final params = options.queryParameters;
    final Object body = params.containsKey('from')
        ? rangeResponseFor(params['from'] as String, params['to'] as String)
        : dayResponseFor(params['date'] as String);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// VG-8: nessun Gruppo di appartenenza, la condizione di ogni prova di
/// questo file salvo quelle dedicate al selettore del membro (F20) —
/// senza questa risposta il selettore interrogherebbe un client HTTP
/// reale, non presente nel banco di prova.
class _NotFoundAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({'code': 'RESOURCE_NOT_FOUND'}),
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

CookingGroupApi _noGroupCookingGroupApi() {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _NotFoundAdapter()
    ..interceptors.add(ApiErrorInterceptor());
  return CookingGroupApi(dio);
}

/// VG-7: distingue il piano proprio da quello di un membro tramite il
/// parametro `userId` (EP-1) e conta le PATCH ricevute, per verificare
/// che la spunta non raggiunga mai il server quando si consulta il
/// piano altrui (VG-9).
class _MemberAwareAdapter implements HttpClientAdapter {
  int patchCount = 0;
  int groupRequestCount = 0;

  /// CU-3, EP-2: l'ultimo `userId` inviato con una PATCH, per verificare
  /// che la spunta del Cuoco raggiunga il membro giusto.
  String? lastPatchUserId;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'PATCH') {
      patchCount++;
      lastPatchUserId = options.queryParameters['userId'] as String?;
    }
    if (options.path.contains('/plan-days/group')) {
      groupRequestCount++;
      return ResponseBody.fromString(
        jsonEncode({
          'date': isoDate(dateOnly(DateTime.now())),
          'members': [
            {
              'userId': 'user-1',
              'firstName': 'Io',
              'lastName': 'Stesso',
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
              ],
            },
            {
              'userId': 'user-2',
              'firstName': 'Maria',
              'lastName': 'Verdi',
              'date': isoDate(dateOnly(DateTime.now())),
              'coverage': 'ACTIVE',
              'planId': 'plan-2',
              'planName': 'Dieta di Maria',
              'planStartDate': '2026-09-01',
              'planEndDate': null,
              'slots': [
                {
                  'slotId': 's2',
                  'type': 'BREAKFAST',
                  'label': null,
                  'order': 0,
                  'content': 'Pasta di Maria',
                  'note': null,
                  'recipeName': null,
                  'recipeText': null,
                  'status': 'CONSUMED',
                },
              ],
            },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    final userId = options.queryParameters['userId'] as String?;
    final content = userId == 'user-2' ? 'Pasta di Maria' : 'Yogurt e cereali';
    final status = userId == 'user-2' ? 'CONSUMED' : 'TO_CONSUME';
    return ResponseBody.fromString(
      jsonEncode({
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
            'content': content,
            'note': null,
            'recipeName': null,
            'recipeText': null,
            'status': status,
            // CU-4: sul proprio piano, l'ultima spunta risulta apposta
            // da Maria — assente nella proiezione del piano altrui
            // (SC-12), che il backend non espone comunque.
            if (userId == null) 'statusChangedBy': 'user-2',
          },
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

const _weekdayLabels = ['lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica'];

/// Le sette giornate di una settimana (VS-1), ciascuna con un contenuto
/// distinto per riconoscerle nelle prove. `outOfPlan` marca gli
/// scostamenti (indice 0-6) con la copertura indicata, priva di slot
/// (VS-7).
List<Map<String, dynamic>> _weekJson(DateTime weekStart, {Map<int, String> outOfPlan = const {}}) {
  return List.generate(7, (i) {
    final date = weekStart.add(Duration(days: i));
    final coverage = outOfPlan[i];
    final day = _dayJsonFor(isoDate(date), 'Pasto di ${_weekdayLabels[i]}');
    if (coverage != null) {
      day['coverage'] = coverage;
      day['slots'] = <dynamic>[];
      if (coverage == 'NONE') {
        day['planId'] = null;
        day['planName'] = null;
        day['planStartDate'] = null;
        day['planEndDate'] = null;
      }
    }
    return day;
  });
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

Future<void> _pumpDailyView(
  WidgetTester tester,
  Map<String, dynamic> dayJson,
) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _JsonAdapter(dayJson);
  dio.interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
        planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
        cookingGroupApiProvider.overrideWithValue(_noGroupCookingGroupApi()),
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
      ],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, home: const PlanScreen()),
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
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
        planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
        cookingGroupApiProvider.overrideWithValue(_noGroupCookingGroupApi()),
        dietPlanApiProvider.overrideWithValue(ownedPlansApi),
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
      ],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, home: const PlanScreen()),
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

/// Condiviso dai gruppi "selettore del membro" e "modalità affiancata"
/// (4.2, 6.3 interfaccia.md): un Gruppo di due membri, io ("Io Stesso")
/// e "Maria Verdi".
Map<String, dynamic> _memberSelectorProfileJson() => {
      'id': 'user-1',
      'email': 'utente@esempio.test',
      'username': 'utente',
      'firstName': 'Io',
      'lastName': 'Stesso',
      'birthDate': '2000-01-01',
      'birthPlace': 'Roma',
      'sex': 'MALE',
      'role': 'USER',
      'height': null,
      'timezone': 'Europe/Rome',
    };

/// [cook]: "Io Stesso" è sempre il Proprietario (owner: true) — nel
/// dominio reale il Proprietario è sempre anche Cuoco (CU-1), quindi
/// [cook]: false rappresenta qui solo il caso di prova "membro semplice
/// non Cuoco" per UT-12/CC-23, non uno stato raggiungibile davvero da un
/// Proprietario.
/// [selfFirst]: se il proprio account preceda gli altri nell'ordine del
/// Gruppo, che è quello di anzianità di appartenenza — `CookingGroup`
/// ordina i membri per `joinedAt`, quale che sia l'ordine del JSON.
/// Falso riproduce il Gruppo altrui in cui si è entrati dopo, dove
/// l'ordine del server non coincide con quello che il selettore deve
/// presentare (4.2).
Map<String, dynamic> _memberSelectorGroupJson({bool cook = true, bool selfFirst = true}) => {
      'id': 'group-1',
      'name': 'Casa',
      'ownerId': selfFirst ? 'user-1' : 'user-2',
      'members': [
        {
          'userId': 'user-1',
          'firstName': 'Io',
          'lastName': 'Stesso',
          'owner': selfFirst,
          'cook': cook,
          'joinedAt': selfFirst ? '2026-09-01T00:00:00Z' : '2026-09-03T00:00:00Z',
        },
        {
          'userId': 'user-2',
          'firstName': 'Maria',
          'lastName': 'Verdi',
          'owner': !selfFirst,
          'cook': !selfFirst,
          'joinedAt': '2026-09-02T00:00:00Z',
        },
      ],
      'createdAt': '2026-09-01T00:00:00Z',
    };

/// `compact` (< 600, app_breakpoints.dart): riproduce il selettore a
/// menu a discesa di uno smartphone, a differenza della riga di avatar
/// usata dagli altri banchi di prova alla larghezza predefinita.
/// [cook]: se "Io Stesso" è Cuoco del Gruppo (CU-2, CU-3) — vero di
/// default, come lo è sempre il Proprietario nel dominio reale.
/// [textScale]: l'ingrandimento del carattere impostato nel sistema
/// operativo (MP-5), che l'applicazione deve rispettare senza rompersi.
Future<_MemberAwareAdapter> _pumpWithGroup(
  WidgetTester tester, {
  bool compact = false,
  bool cook = true,
  bool selfFirst = true,
  double textScale = 1.0,
}) async {
  if (compact) {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  final planDayAdapter = _MemberAwareAdapter();
  final planDayDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = planDayAdapter
    ..interceptors.add(ApiErrorInterceptor());
  final profileDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _JsonAdapter(_memberSelectorProfileJson())
    ..interceptors.add(ApiErrorInterceptor());
  final groupDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _JsonAdapter(_memberSelectorGroupJson(cook: cook, selfFirst: selfFirst))
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
        planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
        profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
        cookingGroupApiProvider.overrideWithValue(CookingGroupApi(groupDio)),
        appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
      ],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const PlanScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return planDayAdapter;
}

/// L'altezza effettiva dell'intestazione delle colonne della vista
/// affiancata: l'`IntrinsicHeight` che la avvolge è il primo che si
/// incontra risalendo da un nome di membro.
double _headerHeight(WidgetTester tester) => tester
    .getSize(find.ancestor(of: find.text('Io'), matching: find.byType(IntrinsicHeight)).first)
    .height;

void main() {
  testWidgets(
    'presenta tutti gli slot della giornata quale sia il loro stato (VG-3, VG-4)',
    (tester) async {
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
    },
  );

  testWidgets(
    'l\'azione "Sposta" nella card espansa conduce alla vista settimanale in modalità di selezione (6.5 interfaccia.md)',
    (tester) async {
      final today = dateOnly(DateTime.now());
      final weekStart = startOfWeek(today);
      final adapter = _DayOrRangeAdapter(
        dayResponseFor: (date) => _dayJson(),
        rangeResponseFor: (from, to) => _weekJson(weekStart),
      );
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ApiErrorInterceptor());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
            planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
            cookingGroupApiProvider.overrideWithValue(_noGroupCookingGroupApi()),
            appDatabaseProvider.overrideWithValue(
              AppDatabase(NativeDatabase.memory()),
            ),
          ],
          child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, home: const PlanScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // s1 (Yogurt e cereali) è "Da consumare": ammissibile come origine.
      await tester.tap(find.text('Yogurt e cereali'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sposta'));
      await tester.pumpAndSettle();

      // VS-8: la scelta della destinazione avviene sempre in settimanale.
      expect(find.text('Scegli dove spostarlo'), findsOneWidget);
    },
  );

  testWidgets(
    'una giornata senza pasti previsti presenta lo stato vuoto (GG-7)',
    (tester) async {
      final day = _dayJson();
      day['slots'] = <dynamic>[];

      await _pumpDailyView(tester, day);

      expect(find.text('Nessun pasto previsto'), findsOneWidget);
    },
  );

  testWidgets(
    'lo scorrimento orizzontale del contenuto naviga al giorno successivo e precedente (VG-16, 6.2)',
    (tester) async {
      final today = dateOnly(DateTime.now());
      final tomorrow = today.add(const Duration(days: 1));
      final adapter = _ByDateAdapter((date) {
        if (date == isoDate(tomorrow)) {
          return _dayJsonFor(date, 'Pesce al forno');
        }
        return _dayJsonFor(date, 'Pasta al pomodoro');
      });
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ApiErrorInterceptor());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
            planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
            cookingGroupApiProvider.overrideWithValue(_noGroupCookingGroupApi()),
            appDatabaseProvider.overrideWithValue(
              AppDatabase(NativeDatabase.memory()),
            ),
          ],
          child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      
            theme: AppTheme.light,
            home: const PlanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pasta al pomodoro'), findsOneWidget);
      expect(adapter.requestedDates, [isoDate(today)]);

      await tester.fling(
        find.byKey(const Key('dailyViewContentSwipe')),
        const Offset(-300, 0),
        800,
      );
      await tester.pumpAndSettle();

      expect(find.text('Pesce al forno'), findsOneWidget);
      expect(adapter.requestedDates, [isoDate(today), isoDate(tomorrow)]);

      await tester.fling(
        find.byKey(const Key('dailyViewContentSwipe')),
        const Offset(300, 0),
        800,
      );
      await tester.pumpAndSettle();

      expect(find.text('Pasta al pomodoro'), findsOneWidget);
      expect(adapter.requestedDates, [
        isoDate(today),
        isoDate(tomorrow),
        isoDate(today),
      ]);
    },
  );

  testWidgets(
    'le frecce del selettore passano alla settimana adiacente anche nella vista giornaliera (VG-16, VG-17)',
    (tester) async {
      final today = dateOnly(DateTime.now());
      final weekStart = startOfWeek(today);
      final nextWeekStart = weekStart.add(const Duration(days: 7));
      final adapter = _ByDateAdapter((date) {
        if (date == isoDate(nextWeekStart)) {
          return _dayJsonFor(date, 'Pesce al forno');
        }
        return _dayJsonFor(date, 'Pasta al pomodoro');
      });
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ApiErrorInterceptor());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
            planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
            cookingGroupApiProvider.overrideWithValue(_noGroupCookingGroupApi()),
            appDatabaseProvider.overrideWithValue(
              AppDatabase(NativeDatabase.memory()),
            ),
          ],
          child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, home: const PlanScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pasta al pomodoro'), findsOneWidget);

      await tester.tap(find.byTooltip('Settimana successiva'));
      await tester.pumpAndSettle();

      // Salta al lunedì della settimana successiva, come lo scorrimento
      // orizzontale della riga (stesso criterio, VG-16).
      expect(find.text('Pesce al forno'), findsOneWidget);
      expect(adapter.requestedDates.last, isoDate(nextWeekStart));

      await tester.tap(find.byTooltip('Settimana precedente'));
      await tester.pumpAndSettle();

      expect(find.text('Pasta al pomodoro'), findsOneWidget);
      expect(adapter.requestedDates.last, isoDate(weekStart));
    },
  );

  testWidgets(
    'l\'azione "Oggi" compare solo altrove e riporta alla giornata corrente in un tocco (VG-19)',
    (tester) async {
      final today = dateOnly(DateTime.now());
      final tomorrow = today.add(const Duration(days: 1));
      final adapter = _ByDateAdapter((date) {
        if (date == isoDate(tomorrow)) {
          return _dayJsonFor(date, 'Pesce al forno');
        }
        return _dayJsonFor(date, 'Pasta al pomodoro');
      });
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ApiErrorInterceptor());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
            planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
            cookingGroupApiProvider.overrideWithValue(_noGroupCookingGroupApi()),
            appDatabaseProvider.overrideWithValue(
              AppDatabase(NativeDatabase.memory()),
            ),
          ],
          child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      
            theme: AppTheme.light,
            home: const PlanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oggi'), findsNothing);

      await tester.fling(
        find.byKey(const Key('dailyViewContentSwipe')),
        const Offset(-300, 0),
        800,
      );
      await tester.pumpAndSettle();

      expect(find.text('Pesce al forno'), findsOneWidget);
      expect(find.text('Oggi'), findsOneWidget);

      await tester.tap(find.text('Oggi'));
      await tester.pumpAndSettle();

      expect(find.text('Pasta al pomodoro'), findsOneWidget);
      expect(find.text('Oggi'), findsNothing);
    },
  );

  testWidgets(
    'un piano Programmato mostra la striscia informativa e comunque il contenuto (VG-18)',
    (tester) async {
      final day = _dayJson();
      day['coverage'] = 'SCHEDULED';
      day['planStartDate'] = '2026-10-01';

      await _pumpDailyView(tester, day);

      expect(find.text('Il piano inizia il 01/10/2026'), findsOneWidget);
      expect(find.text('Yogurt e cereali'), findsOneWidget);
    },
  );

  testWidgets(
    'un piano Concluso mostra la striscia informativa e comunque il contenuto (VG-18)',
    (tester) async {
      final day = _dayJson();
      day['coverage'] = 'COMPLETED';
      day['planEndDate'] = '2026-08-31';

      await _pumpDailyView(tester, day);

      expect(find.text('Piano concluso il 31/08/2026'), findsOneWidget);
      expect(find.text('Yogurt e cereali'), findsOneWidget);
    },
  );

  testWidgets(
    'un piano Programmato o Concluso senza pasti in quel giorno mostra comunque la striscia informativa (VG-18, GG-7)',
    (tester) async {
      final scheduled = _dayJson();
      scheduled['coverage'] = 'SCHEDULED';
      scheduled['planStartDate'] = '2026-10-01';
      scheduled['slots'] = <dynamic>[];

      await _pumpDailyView(tester, scheduled);

      expect(find.text('Il piano inizia il 01/10/2026'), findsOneWidget);
      expect(find.text('Nessun pasto previsto'), findsOneWidget);
    },
  );

  testWidgets(
    'una giornata sospesa non presenta alcuno slot e offre "Riprendi" (VG-18, CV-S3)',
    (tester) async {
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
            for (final day in [
              'MONDAY',
              'TUESDAY',
              'WEDNESDAY',
              'THURSDAY',
              'FRIDAY',
              'SATURDAY',
              'SUNDAY',
            ])
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
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
            planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
            cookingGroupApiProvider.overrideWithValue(_noGroupCookingGroupApi()),
            dietPlanApiProvider.overrideWithValue(DietPlanApi(dietPlanDio)),
            appDatabaseProvider.overrideWithValue(
              AppDatabase(NativeDatabase.memory()),
            ),
          ],
          child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      
            theme: AppTheme.light,
            home: const PlanScreen(),
          ),
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
    },
  );

  testWidgets(
    'nessun piano mai creato mostra l\'invito a crearne uno (PA-10, 4.4)',
    (tester) async {
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
    },
  );

  testWidgets(
    'una giornata fuori piano non offre alcuna azione quando altri piani esistono (PA-10, 4.4)',
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
              for (final wd in [
                'MONDAY',
                'TUESDAY',
                'WEDNESDAY',
                'THURSDAY',
                'FRIDAY',
                'SATURDAY',
                'SUNDAY',
              ])
                {'dayOfWeek': wd, 'slots': <dynamic>[]},
            ],
            'createdAt': '2026-01-01T00:00:00Z',
            'updatedAt': '2026-01-01T00:00:00Z',
          },
        ]),
      );

      expect(find.text('Nessun piano per questo giorno'), findsOneWidget);
      expect(find.text('Crea piano'), findsNothing);
    },
  );

  group('vista settimanale (6.2, 6.4 interfaccia.md)', () {
    Future<void> pumpPlanScreen(WidgetTester tester, _DayOrRangeAdapter adapter) async {
      // I sette pannelli della settimana eccedono la superficie di prova
      // predefinita: qui serve vederli tutti insieme, non scorrere.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ApiErrorInterceptor());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
            planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
            cookingGroupApiProvider.overrideWithValue(_noGroupCookingGroupApi()),
            appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
          ],
          child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, home: const PlanScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'il segmented control passa dalla vista giornaliera a quella settimanale, con tutti e sette i giorni (VS-1)',
      (tester) async {
        final today = dateOnly(DateTime.now());
        final weekStart = startOfWeek(today);
        final adapter = _DayOrRangeAdapter(
          dayResponseFor: (date) => _dayJsonFor(date, 'Pasta al pomodoro'),
          rangeResponseFor: (from, to) => _weekJson(weekStart),
        );

        await pumpPlanScreen(tester, adapter);
        expect(find.text('Pasta al pomodoro'), findsOneWidget);

        await tester.tap(find.text('Settimana'));
        await tester.pumpAndSettle();

        for (final label in _weekdayLabels) {
          expect(find.text('Pasto di $label'), findsOneWidget);
        }
        expect(find.text('Pasta al pomodoro'), findsNothing);
      },
    );

    testWidgets(
      'un giorno fuori dal piano attivo mostra una constatazione al posto delle righe (VS-7)',
      (tester) async {
        final weekStart = startOfWeek(dateOnly(DateTime.now()));
        final adapter = _DayOrRangeAdapter(
          dayResponseFor: (date) => _dayJsonFor(date, 'Pasta al pomodoro'),
          rangeResponseFor: (from, to) =>
              _weekJson(weekStart, outOfPlan: {0: 'SUSPENDED', 1: 'NONE'}),
        );

        await pumpPlanScreen(tester, adapter);
        await tester.tap(find.text('Settimana'));
        await tester.pumpAndSettle();

        expect(find.text('Piano sospeso'), findsOneWidget);
        expect(find.text('Nessun piano'), findsOneWidget);
        expect(find.text('Pasto di ${_weekdayLabels[0]}'), findsNothing);
        expect(find.text('Pasto di ${_weekdayLabels[1]}'), findsNothing);
        // I restanti cinque giorni sono ordinari.
        for (var i = 2; i < 7; i++) {
          expect(find.text('Pasto di ${_weekdayLabels[i]}'), findsOneWidget);
        }
      },
    );

    testWidgets(
      'le frecce passano alla settimana adiacente e "Questa settimana" torna a quella corrente (VS-12, VS-13)',
      (tester) async {
        final today = dateOnly(DateTime.now());
        final thisWeek = startOfWeek(today);
        final nextWeek = thisWeek.add(const Duration(days: 7));
        final requestedRanges = <String>[];
        final adapter = _DayOrRangeAdapter(
          dayResponseFor: (date) => _dayJsonFor(date, 'Pasta al pomodoro'),
          rangeResponseFor: (from, to) {
            requestedRanges.add(from);
            return _weekJson(DateTime.parse(from));
          },
        );

        await pumpPlanScreen(tester, adapter);
        await tester.tap(find.text('Settimana'));
        await tester.pumpAndSettle();

        expect(find.text('Questa settimana'), findsNothing);
        expect(requestedRanges, [isoDate(thisWeek)]);

        await tester.tap(find.byTooltip('Settimana successiva'));
        await tester.pumpAndSettle();

        expect(requestedRanges, [isoDate(thisWeek), isoDate(nextWeek)]);
        expect(find.text('Questa settimana'), findsOneWidget);

        await tester.tap(find.text('Questa settimana'));
        await tester.pumpAndSettle();

        expect(requestedRanges, [isoDate(thisWeek), isoDate(nextWeek), isoDate(thisWeek)]);
        expect(find.text('Questa settimana'), findsNothing);
      },
    );

    testWidgets(
      'il tocco sull\'intestazione di un giorno passa alla vista giornaliera di quel giorno, conservando il riferimento (VS-14)',
      (tester) async {
        final weekStart = startOfWeek(dateOnly(DateTime.now()));
        final wednesday = weekStart.add(const Duration(days: 2));
        final adapter = _DayOrRangeAdapter(
          dayResponseFor: (date) => _dayJsonFor(date, 'Contenuto di $date'),
          rangeResponseFor: (from, to) => _weekJson(weekStart),
        );

        await pumpPlanScreen(tester, adapter);
        await tester.tap(find.text('Settimana'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Mercoledì'));
        await tester.pumpAndSettle();

        expect(find.text('Giorno'), findsOneWidget);
        expect(find.text('Contenuto di ${isoDate(wednesday)}'), findsOneWidget);
      },
    );

    testWidgets(
      'il tocco su una riga apre il contenuto integrale, con nota e ricetta, senza lasciare la vista (VS-4)',
      (tester) async {
        final weekStart = startOfWeek(dateOnly(DateTime.now()));
        final adapter = _DayOrRangeAdapter(
          dayResponseFor: (date) => _dayJsonFor(date, 'Pasta al pomodoro'),
          rangeResponseFor: (from, to) {
            final days = _weekJson(weekStart);
            days[0]
              ..['recipeName'] = 'Pasta al pomodoro fresca'
              ..['recipeText'] = 'Cuocere la pasta...'
              ..['note'] = 'Con parmigiano a parte';
            days[0]['slots'][0]
              ..['recipeName'] = 'Pasta al pomodoro fresca'
              ..['recipeText'] = 'Cuocere la pasta...'
              ..['note'] = 'Con parmigiano a parte';
            return days;
          },
        );

        await pumpPlanScreen(tester, adapter);
        await tester.tap(find.text('Settimana'));
        await tester.pumpAndSettle();

        expect(find.text('Con parmigiano a parte'), findsNothing);

        await tester.tap(find.text('Pasto di lunedì').first);
        await tester.pumpAndSettle();

        expect(find.text('Pasta al pomodoro fresca'), findsOneWidget);
        expect(find.text('Cuocere la pasta...'), findsOneWidget);
        expect(find.text('Con parmigiano a parte'), findsOneWidget);
        // La vista settimanale resta sotto il foglio, non sostituita (VS-4).
        expect(find.text('Settimana'), findsOneWidget);
      },
    );
  });

  group('selettore del membro (4.2 interfaccia.md; VG-7, VG-9, VG-11)', () {
    testWidgets(
      'il proprio account è il primo, nella riga di avatar come nel menu a discesa',
      (tester) async {
        // Il Gruppo elenca prima Maria: l'ordine di anzianità non è
        // quello che il selettore deve presentare.
        await _pumpWithGroup(tester, selfFirst: false);

        expect(
          tester.getTopLeft(find.byTooltip('Io Stesso')).dx,
          lessThan(tester.getTopLeft(find.byTooltip('Maria Verdi')).dx),
        );
      },
    );

    testWidgets(
      'anche il menu a discesa presenta per primo il proprio account (segnalato dall\'utente)',
      (tester) async {
        await _pumpWithGroup(tester, compact: true, selfFirst: false);

        // Il selettore, non il menu "⋮" della giornata: lo distingue il
        // `chevron-down` di 4.2.
        await tester.tap(
          find.ancestor(
            of: find.byIcon(Icons.keyboard_arrow_down),
            matching: find.byType(PopupMenuButton<String>),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.getTopLeft(find.text('Io Stesso')).dy,
          lessThan(tester.getTopLeft(find.text('Maria Verdi')).dy),
        );
      },
    );

    testWidgets(
      'il tocco su un altro membro presenta il suo piano con la riga di contesto, in sola consultazione (VG-9, VG-11)',
      (tester) async {
        await _pumpWithGroup(tester);

        expect(find.text('Yogurt e cereali'), findsOneWidget);
        expect(find.text('Stai vedendo il piano di Maria'), findsNothing);

        await tester.tap(find.byTooltip('Maria Verdi'));
        await tester.pumpAndSettle();

        expect(find.text('Pasta di Maria'), findsOneWidget);
        expect(find.text('Stai vedendo il piano di Maria'), findsOneWidget);
      },
    );

    testWidgets(
      'la spunta è disattivata sul piano di un altro membro per chi non è Cuoco, senza raggiungere il server (UT-12, CC-23)',
      (tester) async {
        final adapter = await _pumpWithGroup(tester, cook: false);

        await tester.tap(find.byTooltip('Maria Verdi'));
        await tester.pumpAndSettle();
        expect(find.text('Pasta di Maria'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        expect(adapter.patchCount, 0);
      },
    );

    testWidgets(
      'la spunta è disponibile sul piano di un membro per il Cuoco, e raggiunge il server con il suo identificativo (CU-3, EP-2, CC-22)',
      (tester) async {
        final adapter = await _pumpWithGroup(tester);

        await tester.tap(find.byTooltip('Maria Verdi'));
        await tester.pumpAndSettle();
        expect(find.text('Pasta di Maria'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        expect(adapter.patchCount, 1);
        expect(adapter.lastPatchUserId, 'user-2');
      },
    );

    testWidgets(
      'dal menu a discesa di uno schermo stretto, il ritorno al proprio piano funziona dopo aver consultato un membro (VG-7)',
      (tester) async {
        await _pumpWithGroup(tester, compact: true);
        expect(find.text('Yogurt e cereali'), findsOneWidget);

        // 4.2 interfaccia.md: su schermo stretto il selettore è un menu
        // a discesa, non la riga di avatar.
        await tester.tap(find.text('Io'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Maria Verdi'));
        await tester.pumpAndSettle();
        expect(find.text('Pasta di Maria'), findsOneWidget);

        // Il ritorno al proprio piano è la prima voce del menu, quella
        // che rappresenta l'Utente stesso.
        await tester.tap(find.text('Maria'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Io Stesso'));
        await tester.pumpAndSettle();

        expect(find.text('Yogurt e cereali'), findsOneWidget);
        expect(find.text('Pasta di Maria'), findsNothing);
        expect(find.text('Stai vedendo il piano di Maria'), findsNothing);
      },
    );

    testWidgets(
      'la card espansa mostra l\'autore dell\'ultima spunta sul proprio piano (CU-4)',
      (tester) async {
        await _pumpWithGroup(tester);

        await tester.tap(find.text('Yogurt e cereali'));
        await tester.pumpAndSettle();

        expect(find.text('Ripristinato da Maria'), findsOneWidget);
      },
    );
  });

  group('modalità affiancata (6.3 interfaccia.md; VG-12, VG-13, VG-14)', () {
    /// MP-5: l'intestazione delle colonne aveva altezza fissa a 56, pari
    /// alla somma esatta di avatar, spaziatura e riga di testo al corpo
    /// nominale. Bastava l'ingrandimento del carattere di sistema — 1,1
    /// sui Samsung di serie — perché il nome traboccasse di due pixel,
    /// con la fascia a righe di Flutter sotto ciascun avatar (segnalato
    /// dall'utente). Un solo pump a carattere ingrandito basta: il
    /// traboccamento è un'eccezione, e fa fallire la prova da sé.
    testWidgets(
      'l\'intestazione non trabocca col carattere ingrandito dal sistema (MP-5)',
      (tester) async {
        await _pumpWithGroup(tester, textScale: 1.3);

        await tester.tap(find.byTooltip('Vista affiancata'));
        await tester.pumpAndSettle();

        expect(find.text('Io'), findsOneWidget);
        expect(find.text('Maria'), findsOneWidget);
        // A cedere è l'intestazione, non il testo: cresce oltre il
        // proprio minimo anziché troncare il nome.
        expect(_headerHeight(tester), greaterThan(56));
      },
    );

    /// L'altezza resta però quella di prima al corpo nominale: la
    /// correzione non muove la griglia a chi non ingrandisce nulla.
    testWidgets(
      'al carattere nominale l\'intestazione conserva la propria altezza (6.3)',
      (tester) async {
        await _pumpWithGroup(tester);

        await tester.tap(find.byTooltip('Vista affiancata'));
        await tester.pumpAndSettle();

        expect(_headerHeight(tester), 56);
      },
    );

    testWidgets(
      'l\'icona columns mostra i pasti di tutti i membri, raggruppati per slot',
      (tester) async {
        final adapter = await _pumpWithGroup(tester);
        expect(find.text('Yogurt e cereali'), findsOneWidget);

        await tester.tap(find.byTooltip('Vista affiancata'));
        await tester.pumpAndSettle();

        expect(find.text('Yogurt e cereali'), findsOneWidget);
        expect(find.text('Pasta di Maria'), findsOneWidget);
        // VG-11: nessuna riga di contesto mentre si guardano tutti insieme.
        expect(find.text('Stai vedendo il piano di Maria'), findsNothing);
        expect(adapter.groupRequestCount, greaterThan(0));
      },
    );

    testWidgets(
      'si aggiorna automaticamente ogni 60 secondi mentre resta aperta, e si ferma alla chiusura (SY-20)',
      (tester) async {
        final adapter = await _pumpWithGroup(tester);
        await tester.tap(find.byTooltip('Vista affiancata'));
        await tester.pumpAndSettle();
        final afterOpen = adapter.groupRequestCount;

        await tester.pump(const Duration(seconds: 60));
        await tester.pump();
        expect(adapter.groupRequestCount, afterOpen + 1);

        await tester.pump(const Duration(seconds: 60));
        await tester.pump();
        expect(adapter.groupRequestCount, afterOpen + 2);

        // La chiusura della vista ferma il timer: nessuna ulteriore
        // richiesta, anche trascorso l'intervallo.
        await tester.tap(find.byTooltip('Vista singola'));
        await tester.pumpAndSettle();
        final afterClose = adapter.groupRequestCount;

        await tester.pump(const Duration(seconds: 60));
        await tester.pump();
        expect(adapter.groupRequestCount, afterClose);
      },
    );

    testWidgets(
      'il secondo tocco sull\'icona columns torna alla vista del singolo membro',
      (tester) async {
        await _pumpWithGroup(tester);

        await tester.tap(find.byTooltip('Vista affiancata'));
        await tester.pumpAndSettle();
        expect(find.text('Pasta di Maria'), findsOneWidget);

        await tester.tap(find.byTooltip('Vista singola'));
        await tester.pumpAndSettle();

        expect(find.text('Yogurt e cereali'), findsOneWidget);
        expect(find.text('Pasta di Maria'), findsNothing);
      },
    );

    testWidgets(
      'il membro non Cuoco vede la spunta solo sulla propria colonna nella griglia (UT-12, CC-23)',
      (tester) async {
        final adapter = await _pumpWithGroup(tester, cook: false);
        await tester.tap(find.byTooltip('Vista affiancata'));
        await tester.pumpAndSettle();

        // Un solo pulsante "check" in tutta la griglia: quello sulla
        // propria colonna.
        expect(find.byIcon(Icons.check), findsOneWidget);

        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        expect(adapter.patchCount, 1);
        expect(adapter.lastPatchUserId, isNull);
      },
    );

    testWidgets(
      'il Cuoco vede e usa la spunta su tutte le colonne della griglia (CU-3, EP-2, CC-22)',
      (tester) async {
        final adapter = await _pumpWithGroup(tester);
        await tester.tap(find.byTooltip('Vista affiancata'));
        await tester.pumpAndSettle();

        // Un pulsante "check" per colonna: la propria e quella di Maria.
        expect(find.byIcon(Icons.check), findsNWidgets(2));

        await tester.tap(find.byIcon(Icons.check).last);
        await tester.pumpAndSettle();

        expect(adapter.patchCount, 1);
        expect(adapter.lastPatchUserId, 'user-2');
      },
    );

    testWidgets(
      'resta utilizzabile senza sovrapposizioni sia su schermo stretto sia ampio (VG-15)',
      (tester) async {
        // `compact` (< 600, app_breakpoints.dart): due colonne visibili,
        // con scorrimento per le restanti (6.3 interfaccia.md).
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pumpWithGroup(tester);
        // 4.2: su schermo stretto la riga di avatar lascia il posto al
        // menu a discesa, e la modalità affiancata ne è la voce in coda —
        // non un'icona a sé, che sottrarrebbe larghezza all'intestazione.
        expect(find.byTooltip('Vista affiancata'), findsNothing);
        // Il selettore, non il menu "⋮" della giornata: lo distingue il
        // `chevron-down` di 4.2.
        await tester.tap(
          find.ancestor(
            of: find.byIcon(Icons.keyboard_arrow_down),
            matching: find.byType(PopupMenuButton<String>),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Vista affiancata'));
        await tester.pumpAndSettle();

        expect(find.text('Yogurt e cereali'), findsOneWidget);
        expect(find.text('Pasta di Maria'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // `expanded` e oltre: tutte le colonne visibili, larghezza
        // distribuita, senza scorrimento necessario.
        tester.view.physicalSize = const Size(1200, 800);
        await tester.pumpAndSettle();

        expect(find.text('Yogurt e cereali'), findsOneWidget);
        expect(find.text('Pasta di Maria'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
