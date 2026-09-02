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
import 'package:healthylog/features/dietplan/presentation/diet_plan_view_screen.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';

/// 7.5 interfaccia.md, ST-7: dettaglio di sola lettura di un piano
/// Concluso — versione minima, ridotta a intestazione, schema e
/// eliminazione (CV-10); periodi, statistiche e storico restano a F27.
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

Map<String, dynamic> _planJson() => {
      'id': 'plan-1',
      'ownerId': 'user-1',
      'authorId': 'user-1',
      'authorRole': 'USER',
      'name': 'Dieta invernale',
      'status': 'COMPLETED',
      'startDate': '2026-01-01',
      'endDate': '2026-03-01',
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

Future<void> _pumpViewScreen(WidgetTester tester, DietPlanApi api) async {
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
      overrides: [dietPlanApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
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
    // Sola lettura: nessuna card espandibile né maniglia di riordino.
    expect(find.byType(ReorderableListView), findsNothing);
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
    expect(find.textContaining('perdute in modo definitivo'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Elimina')));
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
    expect(find.text('Gestione piano'), findsOneWidget);
  });
}
