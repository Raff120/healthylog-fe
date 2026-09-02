import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/presentation/daily_view_screen.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';

/// VG-3, VG-4: tutti gli slot della giornata restano sempre visibili,
/// quale sia il loro stato di consumo — nessuno nascosto né evidenziato
/// come "il prossimo".
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._body);

  final Map<String, dynamic> _body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(_body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Map<String, dynamic> _dayJson() => {
      'date': '2026-09-10',
      'coverage': 'ACTIVE',
      'planId': 'plan-1',
      'planName': 'Dieta',
      'planStartDate': '2026-09-01',
      'planEndDate': null,
      'slots': [
        {
          'slotId': 's1',
          'type': 'BREAKFAST',
          'label': null,
          'order': 0,
          'content': 'Yogurt e cereali',
          'note': null,
          'recipeName': null,
          'recipeText': null,
          'status': 'TO_CONSUME',
        },
        {
          'slotId': 's2',
          'type': 'LUNCH',
          'label': null,
          'order': 1,
          'content': 'Pasta al pomodoro',
          'note': 'Con parmigiano a parte',
          'recipeName': 'Pasta al pomodoro fresca',
          'recipeText': 'Cuocere la pasta...',
          'status': 'CONSUMED',
        },
        {
          'slotId': 's3',
          'type': 'SNACK',
          'label': 'Spuntino del pomeriggio',
          'order': 2,
          'content': 'Frutta secca',
          'note': null,
          'recipeName': null,
          'recipeText': null,
          'status': 'SKIPPED',
        },
      ],
    };

Future<void> _pumpDailyView(WidgetTester tester, Map<String, dynamic> dayJson) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _JsonAdapter(dayJson);
  dio.interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [planDayApiProvider.overrideWithValue(PlanDayApi(dio))],
      child: MaterialApp(theme: AppTheme.light, home: const DailyViewScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('presenta tutti gli slot della giornata quale sia il loro stato (VG-3, VG-4)', (tester) async {
    await _pumpDailyView(tester, _dayJson());

    expect(find.text('Yogurt e cereali'), findsOneWidget);
    expect(find.text('Pasta al pomodoro'), findsOneWidget);
    expect(find.text('Frutta secca'), findsOneWidget);
    // GG-15: la denominazione della ricetta è visibile già a card chiusa.
    expect(find.text('Pasta al pomodoro fresca'), findsOneWidget);
    // GG-10: lo spuntino usa la denominazione descrittiva del piano.
    expect(find.text('Spuntino del pomeriggio'), findsOneWidget);
    expect(find.text('Spuntino'), findsNothing);
    // La nota accessoria compare solo da aperta (4.1 interfaccia.md).
    expect(find.text('Con parmigiano a parte'), findsNothing);

    await tester.tap(find.text('Pasta al pomodoro'));
    await tester.pumpAndSettle();

    expect(find.text('Con parmigiano a parte'), findsOneWidget);
  });

  testWidgets('una giornata senza pasti previsti presenta lo stato vuoto (GG-7)', (tester) async {
    final day = _dayJson();
    day['slots'] = <dynamic>[];

    await _pumpDailyView(tester, day);

    expect(find.text('Nessun pasto previsto'), findsOneWidget);
  });
}
