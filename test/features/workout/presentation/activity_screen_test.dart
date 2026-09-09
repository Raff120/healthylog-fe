import '../../../support/l10n_test_support.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/measurement/providers/measurement_providers.dart';
import 'package:healthylog/features/workout/data/workout_api.dart';
import 'package:healthylog/features/workout/presentation/activity_screen.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';

import '../../../support/measurement_api_stub.dart';

/// *Attività* (10.1 interfaccia.md): pianificazione, obiettivo, elenco e
/// filtri. RA-11, RA-13, CB-8, CB-9, OS-10, RA-18.

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Registra i parametri di ogni interrogazione, per verificare che i
/// filtri raggiungano davvero il server (RA-12) e non siano applicati
/// dopo la lettura.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.workouts = const [], this.planned = const [], this.weeklyGoal});

  final List<Map<String, dynamic>> workouts;
  final List<Map<String, dynamic>> planned;
  final int? weeklyGoal;
  final listQueries = <Map<String, dynamic>>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/workouts' && options.method == 'GET') {
      listQueries.add(Map<String, dynamic>.from(options.queryParameters));
      return _json(200, workouts);
    }
    if (options.path == '/workouts/activity-types') {
      return _json(200, workouts.map((workout) => workout['activityType']).toSet().toList());
    }
    if (options.path == '/planned-workouts') return _json(200, planned);
    if (options.path == '/me/workout-goal') return _json(200, {'value': weeklyGoal});
    return _json(200, const <Object>[]);
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

Map<String, dynamic> _workout({
  required String id,
  required DateTime date,
  required String activityType,
  int? calories,
  String? note,
  String? plannedWorkoutId,
}) =>
    {
      'id': id,
      'userId': 'user-1',
      'date': _isoDate(date),
      'activityType': activityType,
      'caloriesBurned': calories,
      'note': note,
      'plannedWorkoutId': plannedWorkoutId,
    };

Future<_RecordingAdapter> _pumpActivity(
  WidgetTester tester, {
  List<Map<String, dynamic>> workouts = const [],
  List<Map<String, dynamic>> planned = const [],
  int? weeklyGoal,
}) async {
  final adapter = _RecordingAdapter(workouts: workouts, planned: planned, weeklyGoal: weeklyGoal);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        workoutApiProvider.overrideWithValue(WorkoutApi(dio)),
        measurementApiProvider.overrideWithValue(stubMeasurementApi()),
      ],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, home: const ActivityScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

void main() {
  testWidgets('elenca gli allenamenti registrati con calorie e origine (RA-11, RA-13, CB-8)',
      (tester) async {
    final today = DateTime.now();
    await _pumpActivity(tester, workouts: [
      _workout(id: 'w-1', date: today, activityType: 'Corsa', calories: 320),
      _workout(
        id: 'w-2',
        date: today.subtract(const Duration(days: 1)),
        activityType: 'Palestra',
        plannedWorkoutId: 'pw-1',
      ),
    ]);

    expect(find.text('Corsa'), findsOneWidget);
    expect(find.text('Palestra'), findsOneWidget);
    expect(find.text('320 kcal'), findsOneWidget);
    // RA-13: l'icona distingue l'allenamento svolto a fronte di una pianificazione.
    expect(find.byIcon(Icons.event_available), findsOneWidget);
  });

  testWidgets('non presenta totali, medie né conteggi rispetto all\'obiettivo (CB-9, OS-10, RA-18)',
      (tester) async {
    final today = DateTime.now();
    await _pumpActivity(
      tester,
      weeklyGoal: 3,
      workouts: [
        _workout(id: 'w-1', date: today, activityType: 'Corsa', calories: 300),
        _workout(id: 'w-2', date: today, activityType: 'Nuoto', calories: 200),
      ],
    );

    // CB-9: nessun totale di calorie, per quanto i due valori siano lì.
    expect(find.textContaining('500'), findsNothing);
    expect(find.textContaining('Totale'), findsNothing);
    // OS-10: l'obiettivo compare, il suo avanzamento no.
    expect(find.text('3 allenamenti a settimana'), findsOneWidget);
    expect(find.textContaining('/3'), findsNothing);
    expect(find.textContaining('su 3'), findsNothing);
  });

  testWidgets('presenta lo schema ricorrente vigente nella card della pianificazione (AL-10)',
      (tester) async {
    await _pumpActivity(tester, planned: [
      {
        'id': 'pw-1',
        'userId': 'user-1',
        'recurrence': 'WEEKLY',
        'daysOfWeek': ['MONDAY', 'THURSDAY'],
        'date': null,
        'activityType': 'Palestra',
        'activeFrom': '2026-09-01',
        'activeTo': null,
      },
    ]);

    expect(find.text('PIANIFICAZIONE'), findsOneWidget);
    // Il tipo compare sotto ciascuno dei due giorni previsti.
    expect(find.text('Palestra'), findsNWidgets(2));
  });

  testWidgets('in assenza di pianificazione e obiettivo non presenta l\'assenza come una mancanza (4.4, RA-18)',
      (tester) async {
    await _pumpActivity(tester);

    expect(find.text('Nessun allenamento pianificato'), findsOneWidget);
    expect(find.text('Nessun obiettivo settimanale'), findsOneWidget);
    expect(find.text('Nessun allenamento registrato'), findsOneWidget);
    // Nessun sollecito, nessun invito a rimediare.
    expect(find.textContaining('Dovresti'), findsNothing);
    expect(find.textContaining('Ricorda'), findsNothing);
  });

  testWidgets('il filtro per tipo raggiunge il server e compare come chip rimovibile (RA-12)',
      (tester) async {
    final today = DateTime.now();
    final adapter = await _pumpActivity(tester, workouts: [
      _workout(id: 'w-1', date: today, activityType: 'Corsa'),
      _workout(id: 'w-2', date: today, activityType: 'Nuoto'),
    ]);
    expect(adapter.listQueries.last.containsKey('activityType'), isFalse);

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Corsa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Applica'));
    await tester.pumpAndSettle();

    // CS-11 vale per la circoscrizione, ma il criterio è lo stesso: il
    // filtro è un parametro dell'interrogazione, non una cernita a valle.
    expect(adapter.listQueries.last['activityType'], 'Corsa');
    expect(find.widgetWithText(InputChip, 'Corsa'), findsOneWidget);
  });
}
