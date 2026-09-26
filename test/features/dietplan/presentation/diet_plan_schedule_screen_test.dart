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
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/presentation/diet_plan_schedule_screen.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';
import '../../../support/slot_items_json.dart';

/// CD-5, CD-7, CD-8, CD-10: redazione dello schema settimanale. Verifica
/// per intero, con un client dio fittizio (non solo la logica isolata),
/// sul modello già seguito da `login_screen_test.dart`.
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
    final statusCode = response is _ErrorResponse ? response.statusCode : 200;
    final body = response is _ErrorResponse ? jsonEncode(response.body) : jsonEncode(response);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _ErrorResponse {
  const _ErrorResponse(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;
}

const _slotTypesInOrder = ['BREAKFAST', 'SNACK', 'LUNCH', 'SNACK', 'DINNER'];

Map<String, dynamic> _slotJson(String type, int order, {String? content, String? recipeName, String? recipeText}) => {
      'slotId': '$type-$order',
      'type': type,
      'label': type == 'SNACK' ? 'Spuntino' : null,
      'order': order,
      'items': itemsJson(content, recipeName: recipeName, recipeText: recipeText),
      'note': null,
      'adherenceWeight': type == 'SNACK' ? 0.5 : 1.0,
    };

Map<String, dynamic> _planJson({
  String name = 'Dieta di prova',
  String status = 'DRAFT',
  List<Map<String, dynamic>>? mondaySlots,
  int weeks = 1,
  String? content,
}) {
  const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
  return {
    'id': 'plan-1',
    'ownerId': 'user-1',
    'authorId': 'user-1',
    'authorRole': 'USER',
    'name': name,
    'status': status,
    'startDate': '2026-09-07',
    'endDate': null,
    'weeklySchedule': [
      for (var week = 1; week <= weeks; week++)
        for (final day in days)
          {
            // Il primo schema dei test non recava settimana: è la forma
            // anteriore ai piani su più settimane, che si legge come prima.
            if (weeks > 1) 'week': week,
            'dayOfWeek': day,
            'slots': day == 'MONDAY' && mondaySlots != null && week == 1
                ? mondaySlots
                : [
                    for (var i = 0; i < _slotTypesInOrder.length; i++)
                      {
                        ..._slotJson(_slotTypesInOrder[i], i, content: content),
                        'slotId': '${_slotTypesInOrder[i]}-$i-$week-$day',
                      },
                  ],
          },
    ],
    'createdAt': '2026-09-01T00:00:00Z',
    'updatedAt': '2026-09-01T00:00:00Z',
  };
}

Future<void> _pumpScheduleScreen(WidgetTester tester, DietPlanApi api) async {
  final router = GoRouter(
    initialLocation: '/diet-plans/plan-1/schedule',
    routes: [
      GoRoute(
        path: '/diet-plans/:id/schedule',
        builder: (context, state) => DietPlanScheduleScreen(planId: state.pathParameters['id']!),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [dietPlanApiProvider.overrideWithValue(api)],
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
  testWidgets('mostra il piano e la composizione predefinita (GG-3)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    expect(find.text('Dieta di prova'), findsOneWidget);
    expect(find.text('Colazione'), findsOneWidget);
    expect(find.text('Pranzo'), findsOneWidget);
    // F10: "Conferma piano" in fondo (solo in Bozza, 7.3 interfaccia.md)
    // riduce lo spazio verticale dell'elenco degli slot — "Cena", ultimo
    // dello schema predefinito, va raggiunto scorrendo.
    await tester.scrollUntilVisible(find.text('Cena'), 100);
    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('Conferma piano'), findsOneWidget);
  });

  testWidgets('su schermo ampio affianca la navigazione dei giorni alla redazione (MP-6)', (tester) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(1300, 800);
    tester.view.devicePixelRatio = 1.0;

    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    // 7.3 interfaccia.md: su `expanded` la navigazione dei giorni mostra
    // il nome per intero (Lunedì...), non le sole iniziali di `compact`.
    expect(find.text('Lunedì'), findsOneWidget);
    expect(find.text('Colazione'), findsOneWidget);
  });

  testWidgets('il salvataggio riuscito azzera le modifiche pendenti (CD-10)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PUT') {
        return _planJson(mondaySlots: [
          _slotJson('BREAKFAST', 0, content: 'Yogurt e cereali'),
          for (var i = 1; i < _slotTypesInOrder.length; i++) _slotJson(_slotTypesInOrder[i], i),
        ]);
      }
      return _planJson();
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.text('Colazione'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aggiungi elemento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Denominazione').first, 'Yogurt e cereali');
    await tester.pumpAndSettle();

    expect(find.text('Modifiche non salvate'), findsOneWidget);

    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Modifiche non salvate'), findsNothing);
    expect(find.text('Piano salvato.'), findsOneWidget);
  });

  testWidgets('un errore di campo del server è riportato sull\'elemento esatto (ER-14, CC-50)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PUT') {
        return const _ErrorResponse(400, {
          'code': 'VALIDATION_FAILED',
          'fields': [
            {'field': 'days[0].slots[0].items[0].name', 'code': 'REQUIRED'},
          ],
        });
      }
      return _planJson();
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.text('Colazione'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aggiungi elemento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(find.text('La denominazione è obbligatoria'), findsOneWidget);
    expect(find.text('Controlla gli elementi segnalati'), findsOneWidget);
  });

  testWidgets('la conferma di uno schema incompleto elenca i giorni mancanti (CD-15)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    // Ogni giorno è privo di contenuto su ogni slot (default di
    // _planJson): la conferma non deve nemmeno raggiungere il server.
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));
    await tester.tap(find.text('Conferma piano'));
    await tester.pumpAndSettle();

    expect(find.text('Schema incompleto'), findsOneWidget);
    // `find.widgetWithText` invece di `find.text`: il selettore dei
    // giorni riporta la stessa etichetta abbreviata a un'iniziale
    // (`day_selector.dart`), non un rischio di ambiguità qui, ma un
    // riscontro più mirato — cerca proprio la voce del foglio.
    expect(find.widgetWithText(ListTile, 'Lunedì'), findsOneWidget);
  });

  testWidgets('conferma un piano completo e conduce alla gestione (CV-2)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    // CD-13: la conferma richiede ogni giorno completo, non il solo
    // lunedì — a differenza del test precedente, qui tutti i sette.
    final completeSlots = [
      for (var i = 0; i < _slotTypesInOrder.length; i++) _slotJson(_slotTypesInOrder[i], i, content: 'Pasto $i'),
    ];
    Map<String, dynamic> completePlan({String status = 'DRAFT'}) {
      final plan = _planJson(mondaySlots: completeSlots);
      plan['status'] = status;
      for (final day in plan['weeklySchedule'] as List) {
        (day as Map<String, dynamic>)['slots'] = completeSlots;
      }
      return plan;
    }

    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.path.endsWith('/confirm')) {
        return completePlan(status: 'SCHEDULED');
      }
      return completePlan();
    });
    dio.interceptors.add(ApiErrorInterceptor());

    final router = GoRouter(
      initialLocation: '/diet-plans/plan-1/schedule',
      routes: [
        GoRoute(
          path: '/diet-plans/:id/schedule',
          builder: (context, state) => DietPlanScheduleScreen(planId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/profile/plans', builder: (context, state) => const Scaffold(body: Text('Gestione piano'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dietPlanApiProvider.overrideWithValue(DietPlanApi(dio))],
        child: MaterialApp.router(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Conferma piano'));
    await tester.pumpAndSettle();

    expect(find.text('Gestione piano'), findsOneWidget);
  });

  testWidgets('il menu "+" dell\'intestazione aggiunge uno spuntino (7.3 interfaccia.md, GG-4)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aggiungi spuntino'));
    await tester.pumpAndSettle();

    expect(find.text('Modifiche non salvate'), findsOneWidget);
  });

  testWidgets('il menu "+" disabilita colazione, pranzo e cena già presenti (GG-5)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    for (final label in ['Aggiungi colazione', 'Aggiungi pranzo', 'Aggiungi cena']) {
      final item = tester.widget<PopupMenuItem<SlotType>>(
        find.ancestor(of: find.text(label), matching: find.byType(PopupMenuItem<SlotType>)),
      );
      expect(item.enabled, isFalse, reason: '$label dovrebbe essere disabilitato: già presente (GG-5)');
    }
    final snackItem = tester.widget<PopupMenuItem<SlotType>>(
      find.ancestor(of: find.text('Aggiungi spuntino'), matching: find.byType(PopupMenuItem<SlotType>)),
    );
    expect(snackItem.enabled, isTrue);
  });

  testWidgets('un piano Attivo mostra la striscia informativa e "Salva modifiche" al posto della conferma (MD-1, MD-2, MD-3)',
      (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson(status: 'ACTIVE'));
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    expect(find.textContaining('decorrono da oggi'), findsOneWidget);
    expect(find.text('Salva modifiche'), findsOneWidget);
    expect(find.text('Conferma piano'), findsNothing);
  });

  testWidgets('il salvataggio di un piano Sospeso con schema incompleto è impedito (MD-7)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    var putCalled = false;
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PUT') putCalled = true;
      return _planJson(status: 'SUSPENDED');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.text('Colazione'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aggiungi elemento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Denominazione').first, 'Yogurt e cereali');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(putCalled, isFalse);
    expect(find.text('Schema incompleto'), findsOneWidget);
  });

  testWidgets('il menu dell\'intestazione offre "Elimina" per il Sospeso ma non per l\'Attivo (CV-11)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson(status: 'ACTIVE'));
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));
    // `PopupMenuButton<String>` è l'unico tipo generico usato dal menu
    // dell'intestazione — il menu "+" per l'aggiunta degli slot è
    // `PopupMenuButton<SlotType>`, non ambiguo con questo.
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('Salva come template'), findsOneWidget);
    expect(find.text('Elimina'), findsNothing);
  });

  testWidgets('"Elimina" nel menu di un piano Sospeso richiede conferma rafforzata e conduce alla gestione (CV-10)',
      (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    var deleteCalled = false;
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'DELETE') {
        deleteCalled = true;
        return <String, dynamic>{};
      }
      return _planJson(status: 'SUSPENDED');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    final router = GoRouter(
      initialLocation: '/diet-plans/plan-1/schedule',
      routes: [
        GoRoute(
          path: '/diet-plans/:id/schedule',
          builder: (context, state) => DietPlanScheduleScreen(planId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/profile/plans', builder: (context, state) => const Scaffold(body: Text('Gestione piano'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dietPlanApiProvider.overrideWithValue(DietPlanApi(dio))],
        child: MaterialApp.router(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isFalse);
    expect(find.textContaining('perdute in modo definitivo'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Elimina')));
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
    expect(find.text('Gestione piano'), findsOneWidget);
  });

  testWidgets('"Modifica periodo" su un piano Attivo blocca l\'inizio e salva la fine con PATCH (PA-6, 4.4 tecnica)',
      (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    Map<String, dynamic>? patchBody;
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PATCH') {
        patchBody = Map<String, dynamic>.from(options.data as Map);
        return _planJson(status: 'ACTIVE');
      }
      return _planJson(status: 'ACTIVE')..['endDate'] = '2026-12-31';
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifica periodo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('la data di inizio non si modifica'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Salva')));
    await tester.pumpAndSettle();

    expect(patchBody, isNotNull);
    expect(patchBody!['name'], 'Dieta di prova');
    expect(patchBody!['startDate'], '2026-09-07');
    expect(patchBody!['endDate'], isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Periodo aggiornato.'), findsOneWidget);
  });

  testWidgets('un periodo sovrapposto è segnalato nel dialogo, che resta aperto (PA-8, CD-3)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PATCH') {
        return const _ErrorResponse(409, {
          'code': 'PLAN_PERIOD_OVERLAP',
          'conflictingPlanId': 'plan-2',
          'conflictingPlanName': 'Piano estate',
          'conflictingStartDate': '2026-10-01',
          'conflictingEndDate': null,
        });
      }
      return _planJson();
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifica periodo'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Salva')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Si sovrappone a «Piano estate».'), findsOneWidget);
  });

  testWidgets('una fine non successiva a oggi su un piano Sospeso è segnalata sul campo (CV-5)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PATCH') {
        return const _ErrorResponse(400, {
          'code': 'VALIDATION_FAILED',
          'fields': [
            {'field': 'endDate', 'code': 'NOT_FUTURE'},
          ],
        });
      }
      return _planJson(status: 'SUSPENDED')..['endDate'] = '2026-12-31';
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifica periodo'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Salva')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Per terminarlo oggi usa «Concludi»'), findsOneWidget);
  });

  group('settimane dello schema (PA-2bis, 7.3 interfaccia.md)', () {
    Future<void> openHeaderMenu(WidgetTester tester) async {
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
    }

    testWidgets('con una settimana sola non compare la riga delle settimane, e il menu non offre la rimozione',
        (tester) async {
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
      dio.interceptors.add(ApiErrorInterceptor());

      await _pumpScheduleScreen(tester, DietPlanApi(dio));
      expect(find.text('Settimana 1'), findsNothing);

      await openHeaderMenu(tester);
      expect(find.text('Aggiungi settimana'), findsOneWidget);
      expect(find.text('Rimuovi settimana'), findsNothing);
    });

    testWidgets('la settimana aggiunta copia quella in redazione e si salva con la propria, senza identificativi',
        (tester) async {
      Map<String, dynamic>? sent;
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _JsonAdapter((options) {
        if (options.method == 'PUT') {
          sent = options.data as Map<String, dynamic>;
          return _planJson(weeks: 2, content: 'Yogurt');
        }
        return _planJson(content: 'Yogurt');
      });
      dio.interceptors.add(ApiErrorInterceptor());

      await _pumpScheduleScreen(tester, DietPlanApi(dio));
      await openHeaderMenu(tester);
      await tester.tap(find.text('Aggiungi settimana'));
      await tester.pumpAndSettle();

      expect(find.text('Settimana 1'), findsOneWidget);
      expect(find.text('Settimana 2'), findsOneWidget);
      expect(find.text('Modifiche non salvate'), findsOneWidget);

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      final days = (sent!['days'] as List).cast<Map<String, dynamic>>();
      expect(days, hasLength(14));
      expect(days.where((day) => day['week'] == 1), hasLength(7));
      final secondWeek = days.where((day) => day['week'] == 2).toList();
      expect(secondWeek, hasLength(7));
      final copiedSlots = secondWeek.expand((day) => (day['slots'] as List).cast<Map<String, dynamic>>());
      expect(copiedSlots, hasLength(7 * _slotTypesInOrder.length));
      expect(copiedSlots.every((slot) => slot['slotId'] == null), isTrue);
      final copiedItems = copiedSlots.expand((slot) => (slot['items'] as List).cast<Map<String, dynamic>>());
      expect(copiedItems.every((item) => item['itemId'] == null && item['name'] == 'Yogurt'), isTrue);
    });

    testWidgets('la rimozione chiede conferma, fa scalare le settimane e lascia una settimana sola', (tester) async {
      Map<String, dynamic>? sent;
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _JsonAdapter((options) {
        if (options.method == 'PUT') {
          sent = options.data as Map<String, dynamic>;
          return _planJson(content: 'Yogurt');
        }
        return _planJson(weeks: 2, content: 'Yogurt');
      });
      dio.interceptors.add(ApiErrorInterceptor());

      await _pumpScheduleScreen(tester, DietPlanApi(dio));
      await tester.tap(find.text('Settimana 1'));
      await tester.pumpAndSettle();
      await openHeaderMenu(tester);
      await tester.tap(find.text('Rimuovi settimana'));
      await tester.pumpAndSettle();

      expect(find.text('Rimuovere la settimana 1?'), findsOneWidget);
      await tester.tap(find.text('Rimuovi'));
      await tester.pumpAndSettle();

      expect(find.text('Settimana 1'), findsNothing);
      expect(find.text('Settimana 2'), findsNothing);

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      final days = (sent!['days'] as List).cast<Map<String, dynamic>>();
      expect(days, hasLength(7));
      expect(days.every((day) => day['week'] == 1), isTrue);
      // La settimana rimasta è la seconda, scalata al primo posto.
      expect((days.first['slots'] as List).first['slotId'], 'BREAKFAST-0-2-MONDAY');
    });

    testWidgets('l\'elenco dei giorni incompleti nomina la settimana, e il tocco vi conduce (CD-15)', (tester) async {
      final semantics = tester.ensureSemantics();
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _JsonAdapter((_) => _planJson(weeks: 2));
      dio.interceptors.add(ApiErrorInterceptor());

      await _pumpScheduleScreen(tester, DietPlanApi(dio));
      await tester.tap(find.text('Conferma piano'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Settimana 1 · Lunedì'), findsOneWidget);
      await tester.scrollUntilVisible(find.widgetWithText(ListTile, 'Settimana 2 · Domenica'), 100,
          scrollable: find.descendant(of: find.byType(BottomSheet), matching: find.byType(Scrollable)));
      await tester.tap(find.widgetWithText(ListTile, 'Settimana 2 · Domenica'));
      await tester.pumpAndSettle();

      expect(tester.getSemantics(find.text('Settimana 2')), isSemantics(isSelected: true));
      expect(tester.getSemantics(find.text('Settimana 1')), isSemantics(isSelected: false));
      semantics.dispose();
    });
  });

  group('copia del contenuto di uno slot (CD-8bis, 7.3 interfaccia.md)', () {
    List<Map<String, dynamic>> mondaySlots() => [
          {
            ..._slotJson('BREAKFAST', 0, recipeName: 'Porridge', recipeText: "Cuocere l'avena"),
            'note': 'Senza zucchero',
            'adherenceWeight': 0.8,
          },
          _slotJson('LUNCH', 1),
        ];

    Future<void> openCopySheet(WidgetTester tester) async {
      await tester.tap(find.text('Colazione'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Copia in…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copia in…'));
      await tester.pumpAndSettle();
    }

    testWidgets('sostituisce il contenuto degli slot scelti, anche in un altro giorno, e attende il salvataggio',
        (tester) async {
      Map<String, dynamic>? sent;
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _JsonAdapter((options) {
        if (options.method == 'PUT') {
          sent = options.data as Map<String, dynamic>;
        }
        return _planJson(mondaySlots: mondaySlots(), content: 'Yogurt');
      });
      dio.interceptors.add(ApiErrorInterceptor());

      await _pumpScheduleScreen(tester, DietPlanApi(dio));
      await openCopySheet(tester);

      expect(find.text('Copia «Colazione» in…'), findsOneWidget);
      // L'origine non è fra le destinazioni: la prima colazione offerta è
      // quella del martedì.
      expect(find.text('Lunedì'), findsWidgets);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Pranzo').first);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Colazione').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copia'));
      await tester.pumpAndSettle();

      // La colazione del martedì aveva già un elemento: conferma semplice.
      expect(find.text('Sostituire il contenuto?'), findsOneWidget);
      expect(find.text('Uno degli slot scelti ha già un contenuto: sarà sostituito.'), findsOneWidget);
      await tester.tap(find.text('Sostituisci'));
      await tester.pumpAndSettle();

      expect(find.text('Contenuto copiato in 2 slot'), findsOneWidget);
      expect(find.text('Modifiche non salvate'), findsOneWidget);

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      final days = (sent!['days'] as List).cast<Map<String, dynamic>>();
      List<Map<String, dynamic>> slotsOf(String day) =>
          (days.firstWhere((d) => d['dayOfWeek'] == day)['slots'] as List).cast<Map<String, dynamic>>();

      final mondayLunch = slotsOf('MONDAY').firstWhere((slot) => slot['type'] == 'LUNCH');
      expect(mondayLunch['slotId'], 'LUNCH-1');
      expect(mondayLunch['note'], 'Senza zucchero');
      expect(mondayLunch['adherenceWeight'], 0.8);
      final copied = (mondayLunch['items'] as List).cast<Map<String, dynamic>>().single;
      expect(copied['itemId'], isNull);
      expect(copied['kind'], 'RECIPE');
      expect(copied['name'], 'Porridge');
      expect(copied['recipeText'], "Cuocere l'avena");

      final tuesdayBreakfast = slotsOf('TUESDAY').firstWhere((slot) => slot['type'] == 'BREAKFAST');
      expect(tuesdayBreakfast['slotId'], 'BREAKFAST-0-1-TUESDAY');
      expect((tuesdayBreakfast['items'] as List).single['name'], 'Porridge');

      // Gli altri slot non sono toccati.
      final wednesdayBreakfast = slotsOf('WEDNESDAY').firstWhere((slot) => slot['type'] == 'BREAKFAST');
      expect((wednesdayBreakfast['items'] as List).single['name'], 'Yogurt');
    });

    testWidgets('annullare la conferma lascia la destinazione com\'era, senza modifiche pendenti', (tester) async {
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _JsonAdapter((_) => _planJson(mondaySlots: mondaySlots(), content: 'Yogurt'));
      dio.interceptors.add(ApiErrorInterceptor());

      await _pumpScheduleScreen(tester, DietPlanApi(dio));
      await openCopySheet(tester);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Colazione').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(find.text('Modifiche non salvate'), findsNothing);
    });

    testWidgets('senza destinazioni l\'azione non compare', (tester) async {
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _JsonAdapter((_) {
        final plan = _planJson(mondaySlots: [_slotJson('BREAKFAST', 0, content: 'Yogurt')]);
        for (final day in (plan['weeklySchedule'] as List).cast<Map<String, dynamic>>()) {
          if (day['dayOfWeek'] != 'MONDAY') day['slots'] = <Map<String, dynamic>>[];
        }
        return plan;
      });
      dio.interceptors.add(ApiErrorInterceptor());

      await _pumpScheduleScreen(tester, DietPlanApi(dio));
      await tester.tap(find.text('Colazione'));
      await tester.pumpAndSettle();

      expect(find.text('Rimuovi'), findsOneWidget);
      expect(find.text('Copia in…'), findsNothing);
    });
  });
}
