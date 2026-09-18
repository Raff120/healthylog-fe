import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/workout/data/workout_activity.dart';
import 'package:healthylog/features/workout/data/workout_api.dart';
import 'package:healthylog/features/workout/presentation/widgets/workout_activity_picker.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';

import '../../../support/l10n_test_support.dart';

/// Selettore dello sport (AL-2, 10.2 interfaccia.md): gli sport già
/// impiegati in cima, gli altri in ordine alfabetico, *Altro* in fondo con
/// il nome libero. La ricerca serve alla lunghezza dell'elenco.

class _ActivitiesAdapter implements HttpClientAdapter {
  _ActivitiesAdapter({this.activities = const []});

  final List<Map<String, dynamic>> activities;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/workouts/activities') return _json(200, activities);
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

Future<WorkoutActivityChoice?> _openPicker(
  WidgetTester tester, {
  List<Map<String, dynamic>> activities = const [],
}) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _ActivitiesAdapter(activities: activities)
    ..interceptors.add(ApiErrorInterceptor());
  WorkoutActivityChoice? chosen;

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
                onPressed: () async => chosen = await showWorkoutActivityPicker(context),
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
  return chosen;
}

Map<String, dynamic> _usage(String code, {String? name, int count = 1}) =>
    {'activityCode': code, 'activityType': name, 'count': count};

void main() {
  testWidgets('porta in cima gli sport già impiegati e tiene Altro in fondo (AL-2)',
      (tester) async {
    await _openPicker(tester, activities: [
      _usage('TENNIS', name: 'Tennis', count: 7),
      _usage('OTHER', name: 'Bocce', count: 2),
    ]);

    final rows = tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).toList();
    final tennis = rows.indexOf('Tennis');
    final bocce = rows.indexOf('Bocce');
    // Il primo sport dell'ordine alfabetico, che non è stato impiegato.
    final arrampicata = rows.indexOf('Arrampicata');
    final altro = rows.lastIndexOf('Altro');

    expect(tennis, greaterThanOrEqualTo(0));
    expect(bocce, greaterThan(tennis));
    expect(arrampicata, greaterThan(bocce));
    expect(altro, greaterThan(arrampicata));
  });

  testWidgets('ordina alfabeticamente gli sport non ancora impiegati', (tester) async {
    await _openPicker(tester);

    final rows = tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).toList();
    expect(rows.indexOf('Arrampicata'), lessThan(rows.indexOf('Arti marziali')));
    expect(rows.indexOf('Arti marziali'), lessThan(rows.indexOf('Basket')));
  });

  testWidgets('la ricerca circoscrive l\'elenco, che trenta voci non si scorre',
      (tester) async {
    await _openPicker(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Cerca'), 'nuo');
    await tester.pumpAndSettle();

    expect(find.text('Nuoto'), findsOneWidget);
    expect(find.text('Tennis'), findsNothing);
  });

  testWidgets('Altro chiede il nome dell\'attività e lo restituisce (AL-2)', (tester) async {
    WorkoutActivityChoice? chosen;
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _ActivitiesAdapter()
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
                  onPressed: () async => chosen = await showWorkoutActivityPicker(context),
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

    await tester.tap(find.text('Altro'));
    await tester.pumpAndSettle();

    // Il nome è necessario: è la sola denominazione dell'attività.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Conferma'));
    await tester.pumpAndSettle();
    expect(find.text('Indica il nome dell\'attività'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Nome dell\'attività'), 'Bocce');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Conferma'));
    await tester.pumpAndSettle();

    expect(chosen?.activity, WorkoutActivity.other);
    expect(chosen?.customName, 'Bocce');
  });
}
