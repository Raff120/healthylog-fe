import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/features/care/providers/care_providers.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_api.dart';
import 'package:healthylog/features/dietplan/data/meal_swap_api.dart';
import 'package:healthylog/features/dietplan/data/plan_day.dart';
import 'package:healthylog/features/dietplan/data/personal_annotations.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/data/slot_item.dart';
import 'package:healthylog/features/dietplan/data/slot_status.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/data/weekday.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/diet_plan_view_screen.dart';
import 'package:healthylog/features/dietplan/presentation/personal_notes_screen.dart';
import 'package:healthylog/features/dietplan/presentation/plan_screen.dart';
import 'package:healthylog/features/dietplan/presentation/widgets/meal_card.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';
import 'package:healthylog/features/dietplan/providers/meal_swap_providers.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import 'package:healthylog/features/group/data/cooking_group_api.dart';
import 'package:healthylog/features/group/providers/cooking_group_providers.dart';
import 'package:healthylog/features/hydration/providers/hydration_providers.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';
import 'package:healthylog/features/notification/providers/notification_providers.dart';
import 'package:healthylog/features/statistics/providers/statistics_providers.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';

import '../../../support/care_api_stub.dart';
import '../../../support/hydration_api_stub.dart';
import '../../../support/l10n_test_support.dart';
import '../../../support/notification_api_stub.dart';
import '../../../support/slot_items_json.dart';
import '../../../support/statistics_api_stub.dart';
import '../../../support/workout_api_stub.dart';

/// 5.4bis funzionale, 4.1, 6.2, 7.5 e 7.6 interfaccia.md: le annotazioni
/// personali lette, presentate e scritte dal proprietario, e assenti per
/// chiunque altro (NP-2).
class _Adapter implements HttpClientAdapter {
  _Adapter(this._respond);

  final Object? Function(RequestOptions options) _respond;
  final requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final body = _respond(options);
    return ResponseBody.fromString(jsonEncode(body), body == null ? 204 : 200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }

  List<RequestOptions> get puts => requests.where((request) => request.method == 'PUT').toList();
}

Dio _dio(HttpClientAdapter adapter) => Dio(BaseOptions(baseUrl: 'http://example.test'))
  ..httpClientAdapter = adapter
  ..interceptors.add(ApiErrorInterceptor());

Map<String, dynamic> _dayJson(DateTime date, {String? dayName, String? personalNote}) => {
      'date': isoDate(date),
      'coverage': 'ACTIVE',
      'planId': 'plan-1',
      'planName': 'Dieta',
      'planStartDate': '2026-01-01',
      'planEndDate': null,
      'dayName': dayName,
      'slots': [
        {
          'slotId': 's1',
          'type': 'LUNCH',
          'label': null,
          'order': 0,
          'items': itemsJson('Pasta al pomodoro'),
          'note': null,
          'status': 'TO_CONSUME',
          'personalNote': personalNote,
        },
      ],
    };

Map<String, dynamic> _profileJson(String id) => {
      'id': id,
      'email': 'utente@example.it',
      'username': 'utente',
      'firstName': 'Mario',
      'lastName': 'Rossi',
      'birthDate': '1990-01-01',
      'birthPlace': 'Roma',
      'sex': 'MALE',
      'role': 'USER',
      'height': 178,
      'targetWeightKg': null,
      'timezone': 'Europe/Rome',
      'locale': 'IT',
      'unitSystem': 'METRIC',
      'privacyAcceptanceRequired': false,
      'deletionRequestedAt': null,
      'deletionEffectiveAt': null,
    };

void main() {
  group('lettura (CO-19)', () {
    test('la giornata del proprietario reca nome e note; altrove mancano', () {
      final day = PlanDay.fromJson(_dayJson(DateTime(2026, 9, 7), dayName: 'Giorno della pizza', personalNote: 'Troppa'));
      expect(day.dayName, 'Giorno della pizza');
      expect(day.slots.single.personalNote, 'Troppa');

      final others = PlanDay.fromJson(_dayJson(DateTime(2026, 9, 7))
        ..remove('dayName')
        ..['slots'] = [
          {...(_dayJson(DateTime(2026, 9, 7))['slots'] as List).single as Map<String, dynamic>}..remove('personalNote'),
        ]);
      expect(others.dayName, isNull);
      expect(others.slots.single.personalNote, isNull);
    });
  });

  group('card del pasto (4.1)', () {
    PlanDaySlot slot({String? personalNote}) => PlanDaySlot(
          slotId: 's1',
          type: SlotType.lunch,
          label: null,
          order: 0,
          items: const [SlotItem(itemId: 'i1', kindCode: 'FOOD', name: 'Pasta al pomodoro')],
          note: null,
          status: SlotStatus.toConsume,
          replacementNote: null,
          personalNote: personalNote,
        );

    Future<_Adapter> pumpCard(WidgetTester tester, PlanDaySlot slot, {String? member}) async {
      final adapter = _Adapter((options) => options.method == 'PUT' ? null : _dayJson(DateTime(2026, 9, 10)));
      await tester.pumpWidget(ProviderScope(
        overrides: [planDayApiProvider.overrideWithValue(PlanDayApi(_dio(adapter)))],
        child: MaterialApp(
          locale: testLocale,
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          theme: AppTheme.light,
          home: Scaffold(
            body: MealCard(slot: slot, date: DateTime(2026, 9, 10), canCheck: true, planId: 'plan-1', member: member),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pasta al pomodoro'));
      await tester.pumpAndSettle();
      return adapter;
    }

    testWidgets('la nota scritta compare nella card aperta', (tester) async {
      await pumpCard(tester, slot(personalNote: 'Chiedere se si può dimezzare'));

      expect(find.text('Chiedere se si può dimezzare'), findsOneWidget);
      expect(find.text('Aggiungi una nota per te'), findsNothing);
    });

    testWidgets('senza nota si aggiunge, con un dialogo che ricorda chi la vede, e si scrive per data', (tester) async {
      final adapter = await pumpCard(tester, slot());

      await tester.tap(find.text('Aggiungi una nota per te'));
      await tester.pumpAndSettle();
      expect(find.textContaining('La vedi solo tu'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Troppo condita');
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(adapter.puts.single.path, '/plan-days/2026-09-10/slots/s1/personal-note');
      expect(adapter.puts.single.data, {'note': 'Troppo condita'});
    });

    testWidgets('la nota vuota si toglie', (tester) async {
      final adapter = await pumpCard(tester, slot(personalNote: 'Da togliere'));

      await tester.tap(find.text('Da togliere'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '');
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(adapter.puts.single.data, {'note': null});
    });

    testWidgets('sulla giornata di un altro membro la nota non si offre (NP-2)', (tester) async {
      await pumpCard(tester, slot(), member: 'member-2');

      expect(find.text('Aggiungi una nota per te'), findsNothing);
    });
  });

  group('nome della giornata (6.2)', () {
    Future<_Adapter> pumpPlanScreen(WidgetTester tester, {String? dayName}) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final adapter = _Adapter((options) {
        if (options.method == 'PUT') return null;
        if (options.queryParameters.containsKey('from')) {
          final from = DateTime.parse(options.queryParameters['from'] as String);
          return [for (var i = 0; i < 7; i++) _dayJson(from.add(Duration(days: i)), dayName: dayName)];
        }
        return _dayJson(DateTime.parse(options.queryParameters['date'] as String), dayName: dayName);
      });
      final notFound = _Adapter((_) => throw DioException(requestOptions: RequestOptions()));
      await tester.pumpWidget(ProviderScope(
        overrides: [
          careApiProvider.overrideWithValue(stubCareApi()),
          notificationApiProvider.overrideWithValue(stubNotificationApi()),
          workoutApiProvider.overrideWithValue(stubWorkoutApi()),
          hydrationApiProvider.overrideWithValue(stubHydrationApi()),
          planDayApiProvider.overrideWithValue(PlanDayApi(_dio(adapter))),
          dietPlanApiProvider.overrideWithValue(
              DietPlanApi(_dio(_Adapter((_) => {'note': 'Chiedere del pane integrale'})))),
          cookingGroupApiProvider.overrideWithValue(CookingGroupApi(_dio(notFound))),
          appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        ],
        child: MaterialApp.router(
          locale: testLocale,
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          theme: AppTheme.light,
          routerConfig: GoRouter(routes: [
            GoRoute(path: '/', builder: (context, state) => const PlanScreen()),
            GoRoute(
              path: '/diet-plans/:id/notes',
              builder: (context, state) => Scaffold(body: Text('Note ${state.pathParameters['id']}')),
            ),
          ]),
        ),
      ));
      await tester.pumpAndSettle();
      return adapter;
    }

    testWidgets('il nome compare nella giornaliera e nella settimanale', (tester) async {
      await pumpPlanScreen(tester, dayName: 'Giorno della pizza');
      expect(find.text('Giorno della pizza'), findsOneWidget);

      await tester.tap(find.text('Settimana'));
      await tester.pumpAndSettle();
      expect(find.text('Giorno della pizza'), findsNWidgets(7));
    });

    testWidgets('il menu lo dà alla giornata, e lo scrive per data', (tester) async {
      final adapter = await pumpPlanScreen(tester);

      await tester.tap(find.byTooltip('Altre azioni'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dai un nome alla giornata'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Giorno leggero');
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(adapter.puts.single.path, '/plan-days/${isoDate(dateOnly(DateTime.now()))}/name');
      expect(adapter.puts.single.data, {'name': 'Giorno leggero'});
    });

    testWidgets('il menu conduce anche alle note del piano (NP-1, 7.6)', (tester) async {
      await pumpPlanScreen(tester);

      await tester.tap(find.byTooltip('Altre azioni'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Le tue note'));
      await tester.pumpAndSettle();

      expect(find.text('Note plan-1'), findsOneWidget);
    });

    testWidgets('col nome dato, il menu lo rinomina', (tester) async {
      await pumpPlanScreen(tester, dayName: 'Giorno della pizza');

      await tester.tap(find.byTooltip('Altre azioni'));
      await tester.pumpAndSettle();
      expect(find.text('Rinomina la giornata'), findsOneWidget);
    });
  });

  group('nota del piano (7.5)', () {
    Future<void> pumpDetail(WidgetTester tester, {required String viewerId}) async {
      tester.view.physicalSize = const Size(500, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final planAdapter = _Adapter((options) {
        if (options.path.endsWith('/personal-note')) return {'note': 'Chiedere del pane integrale'};
        return {
          'id': 'plan-1',
          'ownerId': 'user-1',
          'authorId': 'nutri-1',
          'authorRole': 'NUTRITIONIST',
          'name': 'Dieta invernale',
          'status': 'ACTIVE',
          'startDate': '2026-01-01',
          'endDate': null,
          'periods': <dynamic>[],
          'suspensions': <dynamic>[],
          'adherence': null,
          'weeklySchedule': [
            for (final day in ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'])
              {'dayOfWeek': day, 'slots': <dynamic>[]},
          ],
          'createdAt': '2026-01-01T00:00:00Z',
          'updatedAt': '2026-01-01T00:00:00Z',
        };
      });
      final router = GoRouter(initialLocation: '/diet-plans/plan-1', routes: [
        GoRoute(
          path: '/diet-plans/:id/notes',
          builder: (context, state) => Scaffold(body: Text('Note ${state.pathParameters['id']}')),
        ),
        GoRoute(path: '/diet-plans/:id', builder: (context, state) => DietPlanViewScreen(planId: state.pathParameters['id']!)),
      ]);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          dietPlanApiProvider.overrideWithValue(DietPlanApi(_dio(planAdapter))),
          mealSwapApiProvider.overrideWithValue(MealSwapApi(_dio(_Adapter((_) => <dynamic>[])))),
          statisticsApiProvider.overrideWithValue(stubStatisticsApi()),
          profileApiProvider.overrideWithValue(ProfileApi(_dio(_Adapter((_) => _profileJson(viewerId))))),
        ],
        child: MaterialApp.router(
          locale: testLocale,
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ));
      await tester.pumpAndSettle();
      // La sezione compare solo quando il profilo è arrivato, e la nota si
      // chiede a quel punto: un secondo giro perché la risposta giunga.
      await tester.pump();
      await tester.pumpAndSettle();
    }

    testWidgets('il proprietario raggiunge le proprie note (7.6)', (tester) async {
      await pumpDetail(tester, viewerId: 'user-1');

      await tester.tap(find.text('Le tue note'));
      await tester.pumpAndSettle();

      expect(find.text('Note plan-1'), findsOneWidget);
    });

    testWidgets('chi legge il piano senza esserne il proprietario non vede la sezione (NP-2)', (tester) async {
      await pumpDetail(tester, viewerId: 'nutri-1');

      expect(find.text('Le tue note'), findsNothing);
      expect(find.text('Chiedere del pane integrale'), findsNothing);
    });
  });

  group('dati delle annotazioni (CO-19)', () {
    test('la lettura d\'insieme omette i giorni non riconosciuti (VR-10)', () {
      final annotations = PersonalAnnotations.fromJson({
        'planNote': null,
        'dayNames': [
          {'week': 1, 'dayOfWeek': 'MONDAY', 'name': 'Lunedì leggero'},
          {'week': 1, 'dayOfWeek': 'HOLIDAY', 'name': 'Sconosciuto'},
        ],
        'slotNotes': [
          {'slotId': 's1', 'note': 'Troppa pasta'},
        ],
      });

      expect(annotations.dayNames, hasLength(1));
      expect(annotations.dayName(1, Weekday.monday), 'Lunedì leggero');
      expect(annotations.slotNote('s1'), 'Troppa pasta');
      expect(annotations.slotNote('s2'), isNull);
      expect(annotations.isEmpty, isFalse);
      expect(const PersonalAnnotations().isEmpty, isTrue);
    });
  });

  group('pagina delle note (7.6)', () {
    Map<String, dynamic> slotJson(String slotId, String type, String content, {String? label, int order = 0}) => {
      'slotId': slotId,
      'type': type,
      'label': label,
      'order': order,
      'items': itemsJson(content),
      'note': null,
      'adherenceWeight': 1.0,
    };

    final planJson = {
      'id': 'plan-1',
      'ownerId': 'user-1',
      'authorId': 'user-1',
      'authorRole': 'USER',
      'name': 'Dieta invernale',
      'status': 'ACTIVE',
      'startDate': '2026-01-01',
      'endDate': null,
      'periods': <dynamic>[],
      'suspensions': <dynamic>[],
      'adherence': null,
      'weeklySchedule': [
        {
          'week': 1,
          'dayOfWeek': 'MONDAY',
          'slots': [slotJson('s1', 'LUNCH', 'Pasta al pomodoro'), slotJson('s2', 'DINNER', 'Minestrone', order: 1)],
        },
        {
          'week': 2,
          'dayOfWeek': 'TUESDAY',
          'slots': [slotJson('s3', 'SNACK', 'Yogurt', label: 'Merenda')],
        },
      ],
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-01T00:00:00Z',
    };

    final someAnnotations = {
      'planNote': 'Chiedere del pane integrale',
      'dayNames': [
        {'week': 2, 'dayOfWeek': 'TUESDAY', 'name': 'Giorno leggero'},
      ],
      'slotNotes': [
        {'slotId': 's1', 'note': 'Troppa pasta'},
        {'slotId': 's3', 'note': 'Meglio greco'},
      ],
    };

    var offline = false;

    Future<_Adapter> pumpNotes(WidgetTester tester, {Map<String, dynamic>? annotations}) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final adapter = _Adapter((options) {
        if (options.path.endsWith('/personal-annotations')) {
          if (offline) throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
          return annotations ?? someAnnotations;
        }
        if (options.path == '/diet-plans/plan-1/personal-note') {
          return {
            'note': options.method == 'PUT'
                ? (options.data as Map)['note']
                : (annotations ?? someAnnotations)['planNote'],
          };
        }
        if (options.method == 'PUT') return null;
        return planJson;
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [dietPlanApiProvider.overrideWithValue(DietPlanApi(_dio(adapter)))],
          child: MaterialApp(
            locale: testLocale,
            localizationsDelegates: testLocalizationsDelegates,
            supportedLocales: testSupportedLocales,
            theme: AppTheme.light,
            home: const PersonalNotesScreen(planId: 'plan-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return adapter;
    }

    String dialogText(WidgetTester tester) =>
        tester.widget<EditableText>(find.byType(EditableText).last).controller.text;

    testWidgets('presenta la nota del piano e le note degli slot col loro contenuto nello schema', (tester) async {
      await pumpNotes(tester);

      expect(find.text('Nota sul piano'), findsOneWidget);
      expect(find.text('Chiedere del pane integrale'), findsOneWidget);
      expect(find.text('Settimana 1 · Lunedì'), findsOneWidget);
      // NP-4: il nome del giorno nell'intestazione del gruppo.
      expect(find.text('Settimana 2 · Martedì · Giorno leggero'), findsOneWidget);
      expect(find.text('Pranzo'), findsOneWidget);
      expect(find.textContaining('Pasta al pomodoro'), findsOneWidget);
      expect(find.text('Troppa pasta'), findsOneWidget);
      // GG-10: lo spuntino si presenta con la propria denominazione.
      expect(find.text('Merenda'), findsOneWidget);
      expect(find.text('Meglio greco'), findsOneWidget);
      // Lo slot senza nota non compare.
      expect(find.text('Cena'), findsNothing);
      expect(find.textContaining('Minestrone'), findsNothing);
    });

    testWidgets('senza annotazioni invita a usare +', (tester) async {
      await pumpNotes(tester, annotations: {'planNote': null, 'dayNames': <dynamic>[], 'slotNotes': <dynamic>[]});

      expect(find.text('Nessuna nota'), findsOneWidget);
      expect(find.text('Usa + per aggiungerne una sul piano o su uno slot.'), findsOneWidget);
    });

    testWidgets('il tocco su una nota la modifica, per slot dello schema (EP-12)', (tester) async {
      final adapter = await pumpNotes(tester);

      await tester.tap(find.text('Troppa pasta'));
      await tester.pumpAndSettle();
      expect(dialogText(tester), 'Troppa pasta');
      await tester.enterText(find.byType(TextField).last, 'Meno pasta');
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(adapter.puts.single.path, '/diet-plans/plan-1/slots/s1/personal-note');
      expect(adapter.puts.single.data, {'note': 'Meno pasta'});
    });

    testWidgets('+ aggiunge una nota allo slot scelto', (tester) async {
      final adapter = await pumpNotes(tester);

      await tester.tap(find.byTooltip('Aggiungi una nota'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nota su uno slot'));
      await tester.pumpAndSettle();
      // Lo schema intero, slot non annotati compresi.
      expect(find.text('Scegli lo slot'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('personal-note-target-s2')));
      await tester.pumpAndSettle();
      expect(dialogText(tester), isEmpty);
      await tester.enterText(find.byType(TextField).last, 'Cenare prima');
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(adapter.puts.single.path, '/diet-plans/plan-1/slots/s2/personal-note');
      expect(adapter.puts.single.data, {'note': 'Cenare prima'});
    });

    testWidgets('+ su uno slot già annotato apre la nota esistente', (tester) async {
      await pumpNotes(tester);

      await tester.tap(find.byTooltip('Aggiungi una nota'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nota su uno slot'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('personal-note-target-s3')));
      await tester.pumpAndSettle();

      expect(dialogText(tester), 'Meglio greco');
    });

    testWidgets('+ sul piano apre la nota del piano esistente e la salva', (tester) async {
      final adapter = await pumpNotes(tester);

      await tester.tap(find.byTooltip('Aggiungi una nota'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nota sul piano').last);
      await tester.pumpAndSettle();
      expect(dialogText(tester), 'Chiedere del pane integrale');
      await tester.enterText(find.byType(TextField).last, 'Chiedere del riso');
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(adapter.puts.single.path, '/diet-plans/plan-1/personal-note');
      expect(adapter.puts.single.data, {'note': 'Chiedere del riso'});
    });

    testWidgets('senza rete la pagina si ricarica (OF-20, 4.4)', (tester) async {
      offline = true;
      addTearDown(() => offline = false);
      await pumpNotes(tester);

      expect(find.text('Riprova'), findsOneWidget);
      offline = false;
      await tester.tap(find.text('Riprova'));
      await tester.pumpAndSettle();

      expect(find.text('Troppa pasta'), findsOneWidget);
    });
  });
}
