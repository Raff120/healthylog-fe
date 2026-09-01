import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_template_api.dart';
import 'package:healthylog/features/dietplan/presentation/create_diet_plan_screen.dart';
import 'package:healthylog/features/dietplan/presentation/diet_plan_template_list_screen.dart';
import 'package:healthylog/features/dietplan/presentation/diet_plan_template_preview_screen.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_template_providers.dart';

/// CT-1, CT-2, CT-4, CT-5, CT-6: elenco e anteprima dei template, e scelta
/// dell'origine alla creazione del piano. Verifica per intero, con un
/// client dio fittizio, sul modello già seguito da
/// `diet_plan_schedule_screen_test.dart`.
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

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._responseFor);

  final Object? Function(RequestOptions options) _responseFor;
  final List<RequestOptions> requests = [];

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
      jsonEncode(_responseFor(options)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

final _templateSummaryJson = {
  'id': 'template-1',
  'name': 'Template estivo',
  'description': 'Per i mesi caldi',
  'updatedAt': '2026-08-01T00:00:00Z',
};

Map<String, dynamic> _templateJson() {
  const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
  return {
    'id': 'template-1',
    'ownerId': 'user-1',
    'name': 'Template estivo',
    'description': 'Per i mesi caldi',
    'notes': null,
    'weeklySchedule': days
        .map((day) => {
              'dayOfWeek': day,
              'slots': [
                {
                  'slotId': 'slot-$day',
                  'type': 'BREAKFAST',
                  'label': null,
                  'order': 0,
                  'content': day == 'MONDAY' ? 'Frutta fresca' : null,
                  'note': null,
                  'recipeName': null,
                  'recipeText': null,
                  'adherenceWeight': 1.0,
                },
              ],
            })
        .toList(),
    'createdAt': '2026-08-01T00:00:00Z',
    'updatedAt': '2026-08-01T00:00:00Z',
  };
}

DietPlanTemplateApi _templateApi(Object? Function(RequestOptions options) responseFor) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _JsonAdapter(responseFor);
  dio.interceptors.add(ApiErrorInterceptor());
  return DietPlanTemplateApi(dio);
}

void main() {
  testWidgets('elenca i template e apre l\'anteprima al tocco (CT-2, CT-6)', (tester) async {
    final api = _templateApi((options) {
      if (options.path == '/diet-plan-templates') return [_templateSummaryJson];
      return _templateJson();
    });
    final router = GoRouter(
      initialLocation: '/diet-plan-templates',
      routes: [
        GoRoute(path: '/diet-plan-templates', builder: (context, state) => const DietPlanTemplateListScreen()),
        GoRoute(
          path: '/diet-plan-templates/:id',
          builder: (context, state) =>
              DietPlanTemplatePreviewScreen(templateId: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dietPlanTemplateApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Template estivo'), findsOneWidget);
    expect(find.text('Per i mesi caldi'), findsOneWidget);

    await tester.tap(find.text('Template estivo'));
    await tester.pumpAndSettle();

    // CT-4: schema settimanale integrale, di sola lettura.
    expect(find.text('Frutta fresca'), findsOneWidget);
    expect(find.text('Usa questo template'), findsOneWidget);
    expect(find.text('Modifica'), findsOneWidget);
  });

  testWidgets('offre la scelta fra origine da zero e da template quando esistono template (CT-1)',
      (tester) async {
    final api = _templateApi((options) => [_templateSummaryJson]);
    final router = GoRouter(
      initialLocation: '/diet-plans/new',
      routes: [
        GoRoute(path: '/diet-plans/new', builder: (context, state) => const CreateDietPlanScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dietPlanTemplateApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Da zero'), findsOneWidget);
    expect(find.text('Da un template'), findsOneWidget);
    expect(find.text('Denominazione'), findsNothing);

    await tester.tap(find.text('Da zero'));
    await tester.pumpAndSettle();

    expect(find.text('Denominazione'), findsOneWidget);
  });

  testWidgets('nessun template: la scelta dell\'origine non compare (7.2 interfaccia.md)', (tester) async {
    final api = _templateApi((options) => <Object>[]);
    final router = GoRouter(
      initialLocation: '/diet-plans/new',
      routes: [
        GoRoute(path: '/diet-plans/new', builder: (context, state) => const CreateDietPlanScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dietPlanTemplateApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Da un template'), findsNothing);
    expect(find.text('Denominazione'), findsOneWidget);
  });

  testWidgets('la creazione senza denominazione non invia alcuna richiesta (TP-3)', (tester) async {
    final adapter = _RecordingAdapter((options) => [_templateSummaryJson]);
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(ApiErrorInterceptor());
    final api = DietPlanTemplateApi(dio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dietPlanTemplateApiProvider.overrideWithValue(api)],
        child: MaterialApp(theme: AppTheme.light, home: const DietPlanTemplateListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();

    expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
  });

  testWidgets('la creazione con denominazione la invia e apre la redazione (TP-3)', (tester) async {
    final adapter = _RecordingAdapter((options) {
      if (options.method == 'POST') return _templateJson();
      return [_templateSummaryJson];
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(ApiErrorInterceptor());
    final api = DietPlanTemplateApi(dio);
    final router = GoRouter(
      initialLocation: '/diet-plan-templates',
      routes: [
        GoRoute(path: '/diet-plan-templates', builder: (context, state) => const DietPlanTemplateListScreen()),
        GoRoute(
          path: '/diet-plan-templates/:id/schedule',
          builder: (context, state) => Text('redazione ${state.pathParameters['id']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dietPlanTemplateApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Il mio template');
    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();

    final created = adapter.requests.firstWhere((r) => r.method == 'POST');
    expect((created.data as Map)['name'], 'Il mio template');
    expect(find.text('redazione template-1'), findsOneWidget);
  });

  testWidgets('la denominazione è modificabile dall\'anteprima (TP-12)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    final adapter = _RecordingAdapter((options) => _templateJson());
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(ApiErrorInterceptor());
    final api = DietPlanTemplateApi(dio);
    final router = GoRouter(
      initialLocation: '/diet-plan-templates/template-1',
      routes: [
        GoRoute(
          path: '/diet-plan-templates/:id',
          builder: (context, state) =>
              DietPlanTemplatePreviewScreen(templateId: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dietPlanTemplateApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rinomina'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Template estivo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Nome nuovo');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    final patched = adapter.requests.firstWhere((r) => r.method == 'PATCH');
    expect((patched.data as Map)['name'], 'Nome nuovo');
  });
}
