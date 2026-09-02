import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/api/connectivity_status.dart';
import 'package:healthylog/features/dietplan/data/plan_day.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/data/slot_status.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/widgets/meal_card.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';

/// Registra ogni richiesta PATCH e risponde con una giornata valida
/// qualunque (il corpo non è osservato dal widget: la cache di
/// [planDayProvider] è solo invalidata, non sostituita a mano).
class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'date': '2026-09-10',
        'coverage': 'ACTIVE',
        'planId': 'plan-1',
        'planName': 'Dieta',
        'planStartDate': '2026-09-01',
        'planEndDate': null,
        'slots': <dynamic>[],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

PlanDaySlot _slot(SlotStatus status) => PlanDaySlot(
      slotId: 's1',
      type: SlotType.lunch,
      label: null,
      order: 0,
      content: 'Pasta al pomodoro',
      note: null,
      recipeName: null,
      recipeText: null,
      status: status,
    );

Future<_RecordingAdapter> _pumpCard(
  WidgetTester tester, {
  required PlanDaySlot slot,
  required DateTime date,
  required bool canCheck,
}) async {
  final adapter = _RecordingAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [planDayApiProvider.overrideWithValue(PlanDayApi(dio))],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: MealCard(slot: slot, date: date, canCheck: canCheck)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

/// Come [_pumpCard], ma restituisce anche il [ProviderContainer]: serve
/// a forzare lo stato offline dopo il pompaggio, senza un secondo giro
/// di rete (F14, OF-20, OF-21).
Future<(_RecordingAdapter, ProviderContainer)> _pumpCardWithContainer(
  WidgetTester tester, {
  required PlanDaySlot slot,
  required DateTime date,
  required bool canCheck,
}) async {
  final adapter = _RecordingAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(ApiErrorInterceptor());

  final container = ProviderContainer(
    overrides: [planDayApiProvider.overrideWithValue(PlanDayApi(dio))],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: MealCard(slot: slot, date: date, canCheck: canCheck)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (adapter, container);
}

void main() {
  final today = dateOnly(DateTime.now());

  testWidgets('il tocco su "Consumato" dispone la transizione (SP-1, SP-4)', (tester) async {
    final adapter = await _pumpCard(tester, slot: _slot(SlotStatus.toConsume), date: today, canCheck: true);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.path, '/plan-days/${isoDate(today)}/slots/s1');
    expect(adapter.requests.single.data, {'status': 'CONSUMED'});
  });

  testWidgets('il tocco ripetuto su "Consumato" torna a "Da consumare" (SP-5, SP-6)', (tester) async {
    final adapter = await _pumpCard(tester, slot: _slot(SlotStatus.consumed), date: today, canCheck: true);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(adapter.requests.single.data, {'status': 'TO_CONSUME'});
  });

  testWidgets('il tocco su "Saltato" da uno stato "Consumato" passa direttamente a Saltato (SP-5)', (tester) async {
    final adapter = await _pumpCard(tester, slot: _slot(SlotStatus.consumed), date: today, canCheck: true);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(adapter.requests.single.data, {'status': 'SKIPPED'});
  });

  testWidgets('i pulsanti disabilitati non dispongono alcuna richiesta (SP-11)', (tester) async {
    final adapter = await _pumpCard(tester, slot: _slot(SlotStatus.toConsume), date: today, canCheck: false);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(adapter.requests, isEmpty);
  });

  testWidgets('la spunta su una data futura chiede conferma (SP-10)', (tester) async {
    final tomorrow = today.add(const Duration(days: 1));
    final adapter = await _pumpCard(tester, slot: _slot(SlotStatus.toConsume), date: tomorrow, canCheck: true);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    expect(adapter.requests, isEmpty);
    expect(find.text('Registrare un pasto futuro?'), findsOneWidget);

    await tester.tap(find.text('Spunta'));
    await tester.pumpAndSettle();

    expect(adapter.requests, hasLength(1));
  });

  testWidgets('la rinuncia alla conferma sulla data futura non dispone alcuna richiesta (SP-10)', (tester) async {
    final tomorrow = today.add(const Duration(days: 1));
    final adapter = await _pumpCard(tester, slot: _slot(SlotStatus.toConsume), date: tomorrow, canCheck: true);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(adapter.requests, isEmpty);
  });

  testWidgets('la spunta su una data passata non chiede conferma (SP-8)', (tester) async {
    final yesterday = today.subtract(const Duration(days: 1));
    final adapter = await _pumpCard(tester, slot: _slot(SlotStatus.toConsume), date: yesterday, canCheck: true);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('Registrare un pasto futuro?'), findsNothing);
    expect(adapter.requests, hasLength(1));
  });

  testWidgets('offline: i pulsanti si disabilitano e non dispongono alcuna richiesta (OF-20)', (tester) async {
    final (adapter, container) = await _pumpCardWithContainer(
      tester,
      slot: _slot(SlotStatus.toConsume),
      date: today,
      canCheck: true,
    );
    addTearDown(container.dispose);
    container.read(connectivityStatusProvider.notifier).markOffline();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(adapter.requests, isEmpty);
  });

  testWidgets('offline: il tocco sul pulsante disabilitato spiega il motivo, distinto da SP-11 (OF-21)', (tester) async {
    final (adapter, container) = await _pumpCardWithContainer(
      tester,
      slot: _slot(SlotStatus.toConsume),
      date: today,
      canCheck: true,
    );
    addTearDown(container.dispose);
    container.read(connectivityStatusProvider.notifier).markOffline();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    expect(find.text('Non disponibile offline.'), findsOneWidget);
    expect(adapter.requests, isEmpty);
  });
}
