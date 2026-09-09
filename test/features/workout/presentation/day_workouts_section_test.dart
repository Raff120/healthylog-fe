import '../../../support/l10n_test_support.dart';
import '../../../support/notification_api_stub.dart';
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
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/plan_screen.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import 'package:healthylog/features/group/data/cooking_group_api.dart';
import 'package:healthylog/features/group/providers/cooking_group_providers.dart';
import 'package:healthylog/features/notification/providers/notification_providers.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';

import '../../../support/care_api_stub.dart';
import '../../../support/workout_api_stub.dart';

/// Sezione degli allenamenti nella vista giornaliera (AL-12, VG-6, 6.2
/// interfaccia.md): sopra i pasti, distinta da essi, con la sola spunta;
/// assente quando nulla è previsto né registrato; presente anche dove il
/// piano non copre la giornata (AL-8, RA-8, SA-14).

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._body, {this.status = 200});

  final Object? _body;
  final int status;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode(_body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

Map<String, dynamic> _dayJson({String coverage = 'ACTIVE'}) => {
      'date': isoDate(dateOnly(DateTime.now())),
      'coverage': coverage,
      'planId': coverage == 'NONE' ? null : 'plan-1',
      'planName': coverage == 'NONE' ? null : 'Dieta',
      'planStartDate': coverage == 'NONE' ? null : '2026-09-01',
      'planEndDate': null,
      'slots': coverage == 'ACTIVE'
          ? [
              {
                'slotId': 's1',
                'type': 'BREAKFAST',
                'label': null,
                'order': 0,
                'content': 'Yogurt',
                'note': null,
                'recipeName': null,
                'recipeText': null,
                'status': 'TO_CONSUME',
                'replacementNote': null,
                'statusChangedBy': null,
              },
            ]
          : <Map<String, dynamic>>[],
    };

Map<String, dynamic> _plannedJson() => {
      'id': 'pw-1',
      'userId': 'user-1',
      'recurrence': 'ONE_OFF',
      'daysOfWeek': const <String>[],
      'date': isoDate(dateOnly(DateTime.now())),
      'activityType': 'Palestra',
      'activeFrom': isoDate(dateOnly(DateTime.now())),
      'activeTo': isoDate(dateOnly(DateTime.now())),
    };

Map<String, dynamic> _workoutJson() => {
      'id': 'w-1',
      'userId': 'user-1',
      'date': isoDate(dateOnly(DateTime.now())),
      'activityType': 'Corsa',
      'caloriesBurned': 300,
      'note': null,
      'plannedWorkoutId': null,
    };

Future<void> _pump(
  WidgetTester tester, {
  Map<String, dynamic>? day,
  List<Map<String, dynamic>> planned = const [],
  List<Map<String, dynamic>> workouts = const [],
}) async {
  final planDayDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _JsonAdapter(day ?? _dayJson())
    ..interceptors.add(ApiErrorInterceptor());
  final groupDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _JsonAdapter({'code': 'RESOURCE_NOT_FOUND'}, status: 404)
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        careApiProvider.overrideWithValue(stubCareApi()),
        // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
        // di ogni destinazione principale (3.1).
        notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider
            .overrideWithValue(stubWorkoutApi(planned: planned, workouts: workouts)),
        planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
        cookingGroupApiProvider.overrideWithValue(CookingGroupApi(groupDio)),
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

void main() {
  testWidgets('presenta gli allenamenti previsti sopra i pasti (AL-12, VG-6)', (tester) async {
    await _pump(tester, planned: [_plannedJson()]);

    expect(find.text('ALLENAMENTO'), findsOneWidget);
    expect(find.text('Palestra'), findsOneWidget);
    // AL-13: un solo pulsante sulla card — l'allenamento è svolto o non
    // lo è, non esiste lo stato saltato.
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('Palestra'), matching: find.byType(Row)).last,
        matching: find.byType(IconButton),
      ),
      findsOneWidget,
    );

    final sectionY = tester.getTopLeft(find.text('ALLENAMENTO')).dy;
    final mealY = tester.getTopLeft(find.text('Yogurt')).dy;
    expect(sectionY, lessThan(mealY));
  });

  testWidgets('presenta già spuntati gli allenamenti registrati, con le calorie (CB-8)',
      (tester) async {
    await _pump(tester, workouts: [_workoutJson()]);

    expect(find.text('Corsa'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('300 kcal'), findsOneWidget);
  });

  testWidgets('non compare in assenza di previsti e registrati (6.2)', (tester) async {
    await _pump(tester);

    expect(find.text('ALLENAMENTO'), findsNothing);
  });

  testWidgets('resta presente dove il piano non copre la giornata (AL-8, RA-8, SA-14)',
      (tester) async {
    await _pump(tester, day: _dayJson(coverage: 'NONE'), workouts: [_workoutJson()]);

    // Lo stato vuoto della parte alimentare non sopprime gli allenamenti:
    // l'attività fisica è indipendente dal piano.
    expect(find.text('ALLENAMENTO'), findsOneWidget);
    expect(find.text('Corsa'), findsOneWidget);
  });

  testWidgets('offre il pulsante mobile di registrazione sul proprio piano (RA-1, 10.2)',
      (tester) async {
    await _pump(tester);

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
