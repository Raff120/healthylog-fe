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
import 'package:healthylog/features/dietplan/presentation/diet_plan_schedule_screen.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';

/// CD-5, CD-7, CD-8, CD-10: redazione dello schema settimanale. Verifica
/// per intero, con un client dio fittizio (non solo la logica isolata),
/// sul modello già seguito da `login_screen_test.dart`.
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
    final statusCode = response is _ErrorResponse ? response.statusCode : 200;
    final body = response is _ErrorResponse ? jsonEncode(response.body) : jsonEncode(response);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _ErrorResponse {
  const _ErrorResponse(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;
}

const _slotTypesInOrder = ['BREAKFAST', 'SNACK', 'LUNCH', 'SNACK', 'DINNER'];

Map<String, dynamic> _slotJson(String type, int order, {String? content, String? recipeName, String? recipeText}) => {
      'slotId': '$type-$order',
      'type': type,
      'label': type == 'SNACK' ? 'Spuntino' : null,
      'order': order,
      'content': content,
      'note': null,
      'recipeName': recipeName,
      'recipeText': recipeText,
      'adherenceWeight': type == 'SNACK' ? 0.5 : 1.0,
    };

Map<String, dynamic> _planJson({String name = 'Dieta di prova', List<Map<String, dynamic>>? mondaySlots}) {
  const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
  return {
    'id': 'plan-1',
    'ownerId': 'user-1',
    'authorId': 'user-1',
    'authorRole': 'USER',
    'name': name,
    'status': 'DRAFT',
    'startDate': '2026-09-07',
    'endDate': null,
    'weeklySchedule': days.map((day) {
      final slots = day == 'MONDAY' && mondaySlots != null
          ? mondaySlots
          : [for (var i = 0; i < _slotTypesInOrder.length; i++) _slotJson(_slotTypesInOrder[i], i)];
      return {'dayOfWeek': day, 'slots': slots};
    }).toList(),
    'createdAt': '2026-09-01T00:00:00Z',
    'updatedAt': '2026-09-01T00:00:00Z',
  };
}

Future<void> _pumpScheduleScreen(WidgetTester tester, DietPlanApi api) async {
  final router = GoRouter(
    initialLocation: '/diet-plans/plan-1/schedule',
    routes: [
      GoRoute(
        path: '/diet-plans/:id/schedule',
        builder: (context, state) => DietPlanScheduleScreen(planId: state.pathParameters['id']!),
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
  testWidgets('mostra il piano e la composizione predefinita (GG-3)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    expect(find.text('Dieta di prova'), findsOneWidget);
    expect(find.text('Colazione'), findsOneWidget);
    expect(find.text('Pranzo'), findsOneWidget);
    expect(find.text('Cena'), findsOneWidget);
  });

  testWidgets('su schermo ampio affianca la navigazione dei giorni alla redazione (MP-6)', (tester) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(1300, 800);
    tester.view.devicePixelRatio = 1.0;

    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => _planJson());
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    // 7.3 interfaccia.md: su `expanded` la navigazione dei giorni mostra
    // il nome per intero (Lunedì...), non le sole iniziali di `compact`.
    expect(find.text('Lunedì'), findsOneWidget);
    expect(find.text('Colazione'), findsOneWidget);
  });

  testWidgets('il salvataggio riuscito azzera le modifiche pendenti (CD-10)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PUT') {
        return _planJson(mondaySlots: [
          _slotJson('BREAKFAST', 0, content: 'Yogurt e cereali'),
          for (var i = 1; i < _slotTypesInOrder.length; i++) _slotJson(_slotTypesInOrder[i], i),
        ]);
      }
      return _planJson();
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.text('Colazione'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Contenuto'), 'Yogurt e cereali');
    await tester.pumpAndSettle();

    expect(find.text('Modifiche non salvate'), findsOneWidget);

    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Modifiche non salvate'), findsNothing);
    expect(find.text('Piano salvato.'), findsOneWidget);
  });

  testWidgets('un testo di ricetta senza denominazione è segnalato sul campo (GG-15)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'PUT') {
        return const _ErrorResponse(400, {
          'code': 'VALIDATION_FAILED',
          'fields': [
            {'field': 'days[0].slots[0].recipeName', 'code': 'REQUIRED'},
          ],
        });
      }
      return _planJson();
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpScheduleScreen(tester, DietPlanApi(dio));

    await tester.tap(find.text('Colazione'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Testo della ricetta'), 'Con miele');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Serve una denominazione se è presente il testo della ricetta'), findsOneWidget);
  });
}
