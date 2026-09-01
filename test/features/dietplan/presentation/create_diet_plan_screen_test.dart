import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_api.dart';
import 'package:healthylog/features/dietplan/presentation/create_diet_plan_screen.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';

/// CD-1, CD-4: creazione del piano. CD-3/PA-9: il conflitto di
/// sovrapposizione è riportato con il nome del piano in conflitto, letto
/// dal corpo dell'errore (non solo dal codice — vedi
/// `core/api/api_exception_test.dart` per l'estensione che lo rende
/// possibile).
class _StatusCodeAdapter implements HttpClientAdapter {
  _StatusCodeAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

DietPlanApi _apiReturning(int statusCode, String body) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _StatusCodeAdapter(statusCode, body);
  dio.interceptors.add(ApiErrorInterceptor());
  return DietPlanApi(dio);
}

/// PA-8, PA-9: il conflitto respinge solo il primo tentativo — un
/// secondo invio con un periodo diverso (qui simulato riproponendo la
/// stessa richiesta, il conflitto risiede lato server) DEVE poter
/// riuscire, non restare bloccato dal primo rifiuto.
class _ConflictThenSuccessAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final body = calls == 1
        ? '{"code":"PLAN_PERIOD_OVERLAP","conflictingPlanId":"plan-x","conflictingPlanName":"Piano estate"}'
        : _planJson;
    return ResponseBody.fromString(
      body,
      calls == 1 ? 409 : 201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

const _planJson = '{'
    '"id":"plan-1","ownerId":"user-1","authorId":"user-1","authorRole":"USER",'
    '"name":"Dieta di prova","status":"DRAFT","startDate":"2026-09-07","endDate":null,'
    '"weeklySchedule":[],"createdAt":"2026-09-01T00:00:00Z","updatedAt":"2026-09-01T00:00:00Z"'
    '}';

Future<void> _pumpCreateScreen(WidgetTester tester, DietPlanApi api) async {
  final router = GoRouter(
    initialLocation: '/diet-plans/new',
    routes: [
      GoRoute(path: '/diet-plans/new', builder: (context, state) => const CreateDietPlanScreen()),
      GoRoute(
        path: '/diet-plans/:id/schedule',
        builder: (context, state) => Text('schermata di redazione ${state.pathParameters['id']}'),
      ),
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
  testWidgets('rifiuta la denominazione assente (CD-1)', (tester) async {
    await _pumpCreateScreen(tester, _apiReturning(201, _planJson));

    await tester.tap(find.text('Crea piano'));
    await tester.pumpAndSettle();

    expect(find.text('Campo obbligatorio'), findsOneWidget);
  });

  testWidgets('una creazione riuscita conduce alla redazione dello schema', (tester) async {
    await _pumpCreateScreen(tester, _apiReturning(201, _planJson));

    await tester.enterText(find.byType(TextField).first, 'Dieta di prova');
    await tester.tap(find.text('Crea piano'));
    await tester.pumpAndSettle();

    expect(find.text('schermata di redazione plan-1'), findsOneWidget);
  });

  testWidgets('un conflitto di periodo riporta il piano che lo genera (CD-3)', (tester) async {
    await _pumpCreateScreen(
      tester,
      _apiReturning(409, '{"code":"PLAN_PERIOD_OVERLAP","conflictingPlanId":"plan-x","conflictingPlanName":"Piano estate"}'),
    );

    await tester.enterText(find.byType(TextField).first, 'Dieta di prova');
    await tester.tap(find.text('Crea piano'));
    await tester.pumpAndSettle();

    expect(find.text('Si sovrappone a "Piano estate".'), findsOneWidget);
  });

  testWidgets('dopo un conflitto un secondo invio può ancora riuscire (PA-9)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _ConflictThenSuccessAdapter();
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpCreateScreen(tester, DietPlanApi(dio));

    await tester.enterText(find.byType(TextField).first, 'Dieta di prova');
    await tester.tap(find.text('Crea piano'));
    await tester.pumpAndSettle();

    expect(find.text('Si sovrappone a "Piano estate".'), findsOneWidget);

    await tester.tap(find.text('Crea piano'));
    await tester.pumpAndSettle();

    expect(find.text('schermata di redazione plan-1'), findsOneWidget);
  });
}
