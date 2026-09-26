import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/features/care/providers/care_providers.dart';
import 'package:healthylog/features/dietplan/data/meal_swap_api.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/plan_screen.dart';
import 'package:healthylog/features/dietplan/providers/meal_swap_providers.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import 'package:healthylog/features/group/data/cooking_group_api.dart';
import 'package:healthylog/features/group/providers/cooking_group_providers.dart';
import 'package:healthylog/features/hydration/providers/hydration_providers.dart';
import 'package:healthylog/features/notification/providers/notification_providers.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';

import '../../../support/care_api_stub.dart';
import '../../../support/hydration_api_stub.dart';
import '../../../support/l10n_test_support.dart';
import '../../../support/notification_api_stub.dart';
import '../../../support/slot_items_json.dart';
import '../../../support/workout_api_stub.dart';

/// IN-20, IN-21, IN-28, 6.5 interfaccia.md: la selezione delle giornate
/// nella vista settimanale e la sua conclusione. La settimana è quella
/// successiva alla corrente, perché nessuna delle sue giornate sia
/// trascorsa quale che sia il giorno in cui la prova gira.
///
/// Durante la selezione il pannello ignora il puntatore dei propri slot: i
/// tocchi sui testi vi giungono attraverso il pannello (`warnIfMissed`).
const _labels = ['lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica'];

class _Adapter implements HttpClientAdapter {
  _Adapter(this.nextWeekStart, {this.skippedIndex});

  final DateTime nextWeekStart;
  final int? skippedIndex;
  final posts = <RequestOptions>[];

  Map<String, dynamic> _day(DateTime date) {
    final index = date.difference(startOfWeek(date)).inDays;
    return {
      'date': isoDate(date),
      'coverage': 'ACTIVE',
      'planId': 'plan-1',
      'planName': 'Dieta',
      'planStartDate': '2026-01-01',
      'planEndDate': null,
      'slots': [
        {
          'slotId': 's$index',
          'type': 'LUNCH',
          'label': null,
          'order': 0,
          'items': itemsJson('Pasto di ${_labels[index]}'),
          'note': null,
          'status': date == nextWeekStart.add(Duration(days: skippedIndex ?? -1)) ? 'SKIPPED' : 'TO_CONSUME',
        },
      ],
    };
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    Object body;
    var status = 200;
    if (options.method == 'POST') {
      posts.add(options);
      status = 201;
      body = {'id': 'log-1', 'performedBy': 'user-1', 'performedAt': '2026-09-21T10:00:00Z', 'kind': 'DAY'};
    } else if (options.queryParameters.containsKey('from')) {
      final from = DateTime.parse(options.queryParameters['from'] as String);
      body = [for (var i = 0; i < 7; i++) _day(from.add(Duration(days: i)))];
    } else {
      body = _day(DateTime.parse(options.queryParameters['date'] as String));
    }
    return ResponseBody.fromString(jsonEncode(body), status,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }
}

class _NotFoundAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(jsonEncode({'code': 'RESOURCE_NOT_FOUND'}), 404,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
}

void main() {
  final nextWeekStart = startOfWeek(dateOnly(DateTime.now())).add(const Duration(days: 7));

  Future<void> pump(WidgetTester tester, _Adapter adapter) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Dio dio(HttpClientAdapter httpAdapter) => Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = httpAdapter
      ..interceptors.add(ApiErrorInterceptor());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
        hydrationApiProvider.overrideWithValue(stubHydrationApi()),
        planDayApiProvider.overrideWithValue(PlanDayApi(dio(adapter))),
        mealSwapApiProvider.overrideWithValue(MealSwapApi(dio(adapter))),
        cookingGroupApiProvider.overrideWithValue(CookingGroupApi(dio(_NotFoundAdapter()))),
        appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
      ],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: const PlanScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> openNextWeek(WidgetTester tester) async {
    await tester.tap(find.text('Settimana'));
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(PlanScreen)))
        .read(selectedDayProvider.notifier)
        .select(nextWeekStart);
    await tester.pumpAndSettle();
  }

  /// L'opacità risultante: il pannello e la riga dello slot ne hanno
  /// ciascuno una propria, e conta il prodotto.
  double opacityOf(WidgetTester tester, String text) => find
      .ancestor(of: find.text(text), matching: find.byType(Opacity))
      .evaluate()
      .map((element) => (element.widget as Opacity).opacity)
      .fold(1.0, (product, opacity) => product * opacity);

  testWidgets('il tocco prolungato sull\'intestazione avvia la selezione, e la giornata ammessa la conclude',
      (tester) async {
    final adapter = _Adapter(nextWeekStart, skippedIndex: 3);
    await pump(tester, adapter);
    await openNextWeek(tester);

    await tester.longPress(find.text('Martedì'));
    await tester.pumpAndSettle();

    expect(find.text('Scegli con quale giornata scambiarla'), findsOneWidget);
    // IN-30: la giornata con uno slot saltato non è ammessa.
    expect(opacityOf(tester, 'Pasto di giovedì'), 0.4);
    expect(opacityOf(tester, 'Pasto di venerdì'), 1);

    await tester.tap(find.text('Pasto di venerdì'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(adapter.posts, hasLength(1));
    expect(adapter.posts.single.path, '/diet-plans/plan-1/day-swaps');
    expect(adapter.posts.single.data, {
      'firstDate': isoDate(nextWeekStart.add(const Duration(days: 1))),
      'secondDate': isoDate(nextWeekStart.add(const Duration(days: 4))),
    });
    expect(find.text('Scegli con quale giornata scambiarla'), findsNothing);
  });

  testWidgets('a chi insiste su una giornata non ammessa la selezione dice perché (IN-21)', (tester) async {
    final adapter = _Adapter(nextWeekStart, skippedIndex: 3);
    await pump(tester, adapter);
    await openNextWeek(tester);

    await tester.longPress(find.text('Martedì'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pasto di giovedì'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Una delle due giornate ha un pasto saltato.'), findsNothing);

    await tester.tap(find.text('Pasto di giovedì'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Una delle due giornate ha un pasto saltato.'), findsOneWidget);
    expect(adapter.posts, isEmpty);
    expect(find.text('Scegli con quale giornata scambiarla'), findsOneWidget);
  });

  testWidgets('la giornata con uno slot saltato non avvia la selezione, e Annulla la chiude', (tester) async {
    final adapter = _Adapter(nextWeekStart, skippedIndex: 3);
    await pump(tester, adapter);
    await openNextWeek(tester);

    // Senza inversione possibile il gesto resta quello di sempre: il
    // tocco sull'intestazione, che porta alla giornata (VS-14).
    await tester.longPress(find.text('Giovedì'));
    await tester.pumpAndSettle();
    expect(find.text('Scegli con quale giornata scambiarla'), findsNothing);

    await openNextWeek(tester);
    await tester.longPress(find.text('Lunedì'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('Scegli con quale giornata scambiarla'), findsNothing);
  });

  testWidgets('dalla giornaliera, «Scambia la giornata» porta alla settimanale in selezione (3.3)', (tester) async {
    final adapter = _Adapter(nextWeekStart);
    await pump(tester, adapter);

    await tester.tap(find.byTooltip('Altre azioni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scambia la giornata'));
    await tester.pumpAndSettle();

    expect(find.text('Scegli con quale giornata scambiarla'), findsOneWidget);
    expect(find.text('Pasto di ${_labels[dateOnly(DateTime.now()).weekday - 1]}'), findsOneWidget);
  });

  /// 6.5: avviata dalla giornaliera, la selezione vi riporta al termine,
  /// sulla giornata di partenza anche se nel frattempo si è navigato.
  group('ritorno alla giornaliera', () {
    final tuesday = nextWeekStart.add(const Duration(days: 1));

    Future<ProviderContainer> startFromDailyView(WidgetTester tester, _Adapter adapter) async {
      await pump(tester, adapter);
      final container = ProviderScope.containerOf(tester.element(find.byType(PlanScreen)));
      container.read(selectedDayProvider.notifier).select(tuesday);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Altre azioni'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scambia la giornata'));
      await tester.pumpAndSettle();
      expect(container.read(selectedPlanViewProvider), PlanViewMode.week);
      return container;
    }

    testWidgets('compiuto lo scambio, torna alla giornata di partenza', (tester) async {
      final adapter = _Adapter(nextWeekStart);
      final container = await startFromDailyView(tester, adapter);
      container.read(selectedDayProvider.notifier).select(nextWeekStart.add(const Duration(days: 4)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pasto di venerdì'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(adapter.posts, hasLength(1));
      expect(container.read(selectedPlanViewProvider), PlanViewMode.day);
      expect(container.read(selectedDayProvider), tuesday);
      expect(find.text('Pasto di martedì'), findsOneWidget);
    });

    testWidgets('Annulla riporta alla giornata di partenza', (tester) async {
      final adapter = _Adapter(nextWeekStart);
      final container = await startFromDailyView(tester, adapter);

      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(adapter.posts, isEmpty);
      expect(container.read(selectedPlanViewProvider), PlanViewMode.day);
      expect(container.read(selectedDayProvider), tuesday);
    });

    testWidgets('avviata dalla settimanale, vi resta', (tester) async {
      final adapter = _Adapter(nextWeekStart);
      await pump(tester, adapter);
      await openNextWeek(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(PlanScreen)));

      await tester.longPress(find.text('Martedì'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pasto di venerdì'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(adapter.posts, hasLength(1));
      expect(container.read(selectedPlanViewProvider), PlanViewMode.week);
    });
  });
}
