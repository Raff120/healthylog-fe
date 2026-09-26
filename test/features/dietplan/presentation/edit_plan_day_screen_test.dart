import '../../../support/l10n_test_support.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/edit_plan_day_screen.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import '../../../support/slot_items_json.dart';

/// CD-8bis, MD-8, MD-3: la copia del contenuto di uno slot nella modifica
/// della singola giornata, con un client dio fittizio. La giornata è
/// richiesta per conto di un Paziente ([EditPlanDayScreen.userId]), così da
/// non passare per la cache locale.
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._responseFor);

  final Object? Function(RequestOptions options) _responseFor;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(jsonEncode(_responseFor(options)), 200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
}

final _date = dateOnly(DateTime.now()).add(const Duration(days: 2));

Map<String, dynamic> _slotJson(String slotId, String type, int order, {String? content, String status = 'TO_CONSUME'}) => {
      'slotId': slotId,
      'type': type,
      'label': type == 'SNACK' ? 'Metà mattina' : null,
      'order': order,
      'items': itemsJson(content),
      'note': null,
      'status': status,
      'replacementNote': null,
    };

Map<String, dynamic> _dayJson(List<Map<String, dynamic>> slots) => {
      'date': isoDate(_date),
      'coverage': 'ACTIVE',
      'planId': 'plan-1',
      'planName': 'Dieta',
      'planStartDate': '2026-09-01',
      'planEndDate': null,
      'slots': slots,
    };

Future<void> _pumpEditDay(WidgetTester tester, PlanDayApi api) async {
  final router = GoRouter(
    initialLocation: '/edit',
    routes: [
      GoRoute(path: '/edit', builder: (context, state) => EditPlanDayScreen(date: _date, userId: 'patient-1')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [planDayApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offre i soli slot della giornata non consumati, e copia senza toccare il peso (MD-3, MD-8)',
      (tester) async {
    Map<String, dynamic>? sent;
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    final slots = [
      _slotJson('breakfast', 'BREAKFAST', 0, content: 'Caffè', status: 'CONSUMED'),
      _slotJson('snack', 'SNACK', 1, content: 'Mela'),
      _slotJson('dinner', 'DINNER', 2, content: 'Minestrone'),
    ];
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PUT') sent = options.data as Map<String, dynamic>;
      return _dayJson(slots);
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpEditDay(tester, PlanDayApi(dio));
    await tester.tap(find.text('Metà mattina'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Copia in…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copia in…'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(CheckboxListTile, 'Cena'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'Colazione'), findsNothing);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Cena'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sostituisci'));
    await tester.pumpAndSettle();

    // L'avviso dell'esito copre il pulsante di salvataggio finché non se ne va.
    expect(find.text('Contenuto copiato in 1 slot'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salva giornata'));
    await tester.pumpAndSettle();

    final sentSlots = (sent!['slots'] as List).cast<Map<String, dynamic>>();
    final dinner = sentSlots.firstWhere((slot) => slot['slotId'] == 'dinner');
    expect(dinner['type'], 'DINNER');
    expect((dinner['items'] as List).single['name'], 'Mela');
    expect((dinner['items'] as List).single['itemId'], isNull);
    // Il peso resta quello che la giornata già reca per la cena.
    expect(dinner['adherenceWeight'], 1.0);
    final breakfast = sentSlots.firstWhere((slot) => slot['slotId'] == 'breakfast');
    expect((breakfast['items'] as List).single['name'], 'Caffè');
  });
}
