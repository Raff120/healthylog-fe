import '../../../support/l10n_test_support.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/workout/data/workout_api.dart';
import 'package:healthylog/features/workout/data/workout_models.dart';
import 'package:healthylog/features/workout/presentation/widgets/workout_sheet.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';

/// Foglio di registrazione (10.2 interfaccia.md): CB-2 (calorie sempre
/// vuote, mai suggerite), RA-9/AL-6 (conferma sul secondo allenamento del
/// giorno), RA-10 (poi nessun ostacolo), AL-13/RA-3 (foglio ridotto della
/// spunta, che eredita il tipo).

String _isoToday() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

class _WorkoutAdapter implements HttpClientAdapter {
  _WorkoutAdapter({this.existingToday = const []});

  final List<Map<String, dynamic>> existingToday;
  final posted = <Map<String, dynamic>>[];
  final deleted = <String>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'POST' && options.path == '/workouts') {
      posted.add(Map<String, dynamic>.from(options.data as Map));
      return _json(201, {
        'id': 'w-new',
        'userId': 'user-1',
        'date': _isoToday(),
        'activityType': 'Corsa',
        'caloriesBurned': null,
        'note': null,
        'plannedWorkoutId': null,
      });
    }
    if (options.method == 'DELETE') {
      deleted.add(options.path);
      return _json(204, const <String, Object>{});
    }
    if (options.path == '/workouts' && options.queryParameters.containsKey('date')) {
      return _json(200, existingToday);
    }
    if (options.path == '/workouts/activity-types') {
      return _json(200, const ['Corsa', 'Nuoto']);
    }
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

Future<_WorkoutAdapter> _pumpSheet(
  WidgetTester tester, {
  List<Map<String, dynamic>> existingToday = const [],
  PlannedWorkout? planned,
  Workout? existing,
}) async {
  final adapter = _WorkoutAdapter(existingToday: existingToday);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [workoutApiProvider.overrideWithValue(WorkoutApi(dio))],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showWorkoutSheet(context, planned: planned, existing: existing),
                child: const Text('Apri'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Apri'));
  await tester.pumpAndSettle();
  return adapter;
}

Workout _recorded({String? plannedWorkoutId}) => Workout(
      id: 'w-1',
      userId: 'user-1',
      date: DateTime.now(),
      activityType: 'Corsa',
      caloriesBurned: 300,
      note: null,
      plannedWorkoutId: plannedWorkoutId,
    );

PlannedWorkout _planned() => PlannedWorkout(
      id: 'pw-1',
      recurrence: WorkoutRecurrence.weekly,
      daysOfWeek: const [Weekday.monday],
      date: null,
      activityType: 'Palestra',
      activeFrom: DateTime.now(),
      activeTo: null,
    );

void main() {
  testWidgets('presenta le calorie sempre vuote e senza valori suggeriti (CB-1, CB-2)',
      (tester) async {
    await _pumpSheet(tester);

    final field = tester.widget<TextField>(
      find.descendant(
        of: find.ancestor(
          of: find.text('Calorie bruciate'),
          matching: find.byType(Column),
        ).first,
        matching: find.byType(TextField),
      ).first,
    );
    expect(field.controller?.text, isEmpty);
    expect(find.text('Se lo sai. Non è obbligatorio.'), findsOneWidget);
  });

  testWidgets('chiede conferma sul secondo allenamento del giorno mostrando quello registrato (AL-6, RA-9)',
      (tester) async {
    final adapter = await _pumpSheet(tester, existingToday: [
      {
        'id': 'w-1',
        'userId': 'user-1',
        'date': _isoToday(),
        'activityType': 'Corsa',
        'caloriesBurned': 300,
        'note': null,
        'plannedWorkoutId': null,
      },
    ]);

    await tester.enterText(find.widgetWithText(TextField, 'Tipo di attività'), 'Nuoto');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Registra'));
    await tester.pumpAndSettle();

    // RA-9: la conferma presenta l'allenamento già registrato, così da
    // rendere riconoscibile la duplicazione involontaria.
    expect(find.text('Hai già registrato un allenamento in questo giorno'), findsOneWidget);
    expect(find.textContaining('Corsa'), findsWidgets);
    expect(adapter.posted, isEmpty);

    // RA-10: confermata la volontà, la registrazione procede senza ostacoli.
    await tester.tap(find.text('Registra comunque'));
    await tester.pumpAndSettle();
    expect(adapter.posted, hasLength(1));
    expect(adapter.posted.single['activityType'], 'Nuoto');
  });

  testWidgets('rinunciando alla conferma non registra nulla (RA-9)', (tester) async {
    final adapter = await _pumpSheet(tester, existingToday: [
      {
        'id': 'w-1',
        'userId': 'user-1',
        'date': _isoToday(),
        'activityType': 'Corsa',
        'caloriesBurned': null,
        'note': null,
        'plannedWorkoutId': null,
      },
    ]);

    await tester.enterText(find.widgetWithText(TextField, 'Tipo di attività'), 'Nuoto');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Registra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(adapter.posted, isEmpty);
  });

  testWidgets('il foglio ridotto della spunta non chiede il tipo e lo eredita (AL-13, RA-3)',
      (tester) async {
    final adapter = await _pumpSheet(tester, planned: _planned());

    // 10.2: i soli campi facoltativi, e si può chiudere senza compilarli.
    expect(find.widgetWithText(TextField, 'Tipo di attività'), findsNothing);
    expect(find.text('Palestra'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Registra'));
    await tester.pumpAndSettle();

    expect(adapter.posted.single['plannedWorkoutId'], 'pw-1');
    // Il tipo non è inviato: lo eredita il server dalla pianificazione.
    expect(adapter.posted.single['activityType'], isNull);
  });

  testWidgets('offre l\'eliminazione sul solo allenamento già registrato, previa conferma (RA-15, RA-16)',
      (tester) async {
    final adapter = await _pumpSheet(tester, existing: _recorded());

    await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminare questo allenamento?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
    await tester.pumpAndSettle();
    expect(adapter.deleted, isEmpty);

    await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Elimina').last);
    await tester.pumpAndSettle();
    expect(adapter.deleted, ['/workouts/w-1']);
  });

  testWidgets('in registrazione l\'eliminazione non compare: non c\'è nulla da eliminare (RA-15)',
      (tester) async {
    await _pumpSheet(tester);

    expect(find.widgetWithText(TextButton, 'Elimina'), findsNothing);
  });

  testWidgets('sull\'allenamento svolto a fronte di pianificazione la conferma dichiara che la pianificazione resta (RA-17)',
      (tester) async {
    await _pumpSheet(tester, existing: _recorded(plannedWorkoutId: 'pw-1'));

    await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
    await tester.pumpAndSettle();

    expect(
      find.text('La pianificazione resta: l\'allenamento tornerà previsto e non svolto.'),
      findsOneWidget,
    );
  });

  testWidgets('la spunta di un allenamento previsto non chiede conferma di duplicato (AL-13)',
      (tester) async {
    final adapter = await _pumpSheet(
      tester,
      planned: _planned(),
      existingToday: [
        {
          'id': 'w-1',
          'userId': 'user-1',
          'date': _isoToday(),
          'activityType': 'Corsa',
          'caloriesBurned': null,
          'note': null,
          'plannedWorkoutId': null,
        },
      ],
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Registra'));
    await tester.pumpAndSettle();

    // L'Utente sta dichiarando di aver svolto proprio quello: non c'è
    // duplicazione involontaria da prevenire.
    expect(find.text('Hai già registrato un allenamento in questo giorno'), findsNothing);
    expect(adapter.posted, hasLength(1));
  });
}
