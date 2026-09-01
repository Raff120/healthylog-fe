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
import 'package:healthylog/features/dietplan/presentation/diet_plan_management_screen.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';

/// 7.1 interfaccia.md: card del piano in corso, voci compatte per gli
/// altri piani (Bozza compresa, PA-9) e azioni di stato (F10).
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

Map<String, dynamic> _planJson({
  required String status,
  String id = 'plan-1',
  String name = 'Dieta di prova',
  String startDate = '2026-09-01',
}) =>
    {
      'id': id,
      'ownerId': 'user-1',
      'authorId': 'user-1',
      'authorRole': 'USER',
      'name': name,
      'status': status,
      'startDate': startDate,
      'endDate': null,
      'periods': const [],
      'suspensions': const [],
      'weeklySchedule': const [],
      'createdAt': '2026-09-01T00:00:00Z',
      'updatedAt': '2026-09-01T00:00:00Z',
    };

/// L'elenco (`GET /diet-plans`, senza segmenti successivi) è l'unica
/// richiesta che il client emette per popolare la schermata: le mutazioni
/// (confirm/withdraw/...) restituiscono il piano aggiornato ma il client
/// non lo usa direttamente, si affida all'invalidazione e a una nuova
/// lettura dell'elenco.
bool _isListRequest(RequestOptions options) => options.method == 'GET' && options.path == '/diet-plans';

Future<void> _pumpManagementScreen(WidgetTester tester, DietPlanApi api) async {
  final router = GoRouter(
    initialLocation: '/profile/plans',
    routes: [
      GoRoute(path: '/profile/plans', builder: (context, state) => const DietPlanManagementScreen()),
      GoRoute(path: '/diet-plans/new', builder: (context, state) => const Scaffold(body: Text('Nuovo piano'))),
      GoRoute(
        path: '/diet-plans/:id/schedule',
        builder: (context, state) => Scaffold(body: Text('Redazione ${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/diet-plans/:id',
        builder: (context, state) => Scaffold(body: Text('Vista ${state.pathParameters['id']}')),
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
  testWidgets('nessun piano mostra lo stato vuoto e conduce alla creazione', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((_) => const <dynamic>[]);
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));

    expect(find.text('Inizia da qui'), findsOneWidget);
    await tester.tap(find.text('Crea piano'));
    await tester.pumpAndSettle();
    expect(find.text('Nuovo piano'), findsOneWidget);
  });

  testWidgets('un piano Attivo mostra Sospendi e Concludi (7.1)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    var status = 'ACTIVE';
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.path.endsWith('/suspend')) status = 'SUSPENDED';
      if (_isListRequest(options)) return [_planJson(status: status)];
      return _planJson(status: status);
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));

    expect(find.text('IN CORSO'), findsOneWidget);
    expect(find.text('Dieta di prova'), findsOneWidget);
    expect(find.text('Sospendi'), findsOneWidget);
    expect(find.text('Concludi'), findsOneWidget);

    // CV-S1: nessuna conferma, operazione reversibile (4.5 interfaccia.md).
    await tester.tap(find.text('Sospendi'));
    await tester.pumpAndSettle();

    expect(find.text('SOSPESO'), findsOneWidget);
    expect(find.text('Riprendi'), findsOneWidget);
  });

  testWidgets('la conclusione richiede conferma semplice (CV-5, 4.5 interfaccia.md)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    var completeCalled = false;
    var completed = false;
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.path.endsWith('/complete')) {
        completeCalled = true;
        completed = true;
        return _planJson(status: 'COMPLETED');
      }
      if (_isListRequest(options)) return completed ? const <dynamic>[] : [_planJson(status: 'ACTIVE')];
      return _planJson(status: 'ACTIVE');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));
    await tester.tap(find.text('Concludi'));
    await tester.pumpAndSettle();

    // Il riquadro di conferma è ancora aperto: nessuna chiamata compiuta.
    expect(completeCalled, isFalse);
    expect(find.text('Concludere il piano?'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Concludi')));
    await tester.pumpAndSettle();

    expect(completeCalled, isTrue);
    // Un piano Concluso esce dall'elenco: torna allo stato vuoto.
    expect(find.text('Inizia da qui'), findsOneWidget);
  });

  testWidgets('un piano Programmato mostra Modifica, Ritira e Attiva ora (7.1)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (_isListRequest(options)) return [_planJson(status: 'SCHEDULED')];
      return _planJson(status: 'SCHEDULED');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));

    expect(find.text('PROGRAMMATO'), findsOneWidget);
    expect(find.text('Modifica'), findsOneWidget);
    expect(find.text('Ritira'), findsOneWidget);
    expect(find.text('Attiva ora'), findsOneWidget);
  });

  testWidgets('"Modifica" ritira il piano e conduce alla redazione senza conferma propria (CV-6)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    var withdrawCalled = false;
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.path.endsWith('/withdraw')) {
        withdrawCalled = true;
        return _planJson(status: 'DRAFT');
      }
      if (_isListRequest(options)) return [_planJson(status: 'SCHEDULED')];
      return _planJson(status: 'SCHEDULED');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));
    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    expect(withdrawCalled, isTrue);
    expect(find.text('Redazione plan-1'), findsOneWidget);
  });

  testWidgets('un errore di transizione è mostrato in una barra temporanea', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.path.endsWith('/suspend')) {
        return const _ErrorResponse(409, {'code': 'PLAN_TRANSITION_NOT_ALLOWED'});
      }
      if (_isListRequest(options)) return [_planJson(status: 'ACTIVE')];
      return _planJson(status: 'ACTIVE');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));
    await tester.tap(find.text('Sospendi'));
    await tester.pumpAndSettle();

    expect(find.text('Questa operazione non è più possibile per il piano.'), findsOneWidget);
  });

  testWidgets('mostra la Bozza come voce compatta e vi conduce al tocco (PA-9)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (_isListRequest(options)) {
        return [
          _planJson(status: 'ACTIVE', id: 'plan-1', name: 'Dieta in corso', startDate: '2026-08-01'),
          _planJson(status: 'DRAFT', id: 'plan-2', name: 'Nuova bozza', startDate: '2026-10-01'),
        ];
      }
      return _planJson(status: 'ACTIVE');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));

    expect(find.text('Dieta in corso'), findsOneWidget);
    expect(find.text('Nuova bozza'), findsOneWidget);
    expect(find.textContaining('Bozza'), findsOneWidget);

    await tester.tap(find.text('Nuova bozza'));
    await tester.pumpAndSettle();

    expect(find.text('Redazione plan-2'), findsOneWidget);
  });

  testWidgets('un piano Attivo mostra "Modifica" e conduce alla redazione senza ritirarlo (MD-1)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    var withdrawCalled = false;
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.path.endsWith('/withdraw')) withdrawCalled = true;
      if (_isListRequest(options)) return [_planJson(status: 'ACTIVE')];
      return _planJson(status: 'ACTIVE');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));
    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    expect(withdrawCalled, isFalse);
    expect(find.text('Redazione plan-1'), findsOneWidget);
  });

  testWidgets('un piano Sospeso mostra "Elimina" con conferma rafforzata (CV-10)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    var deleteCalled = false;
    var deleted = false;
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (options.method == 'DELETE') {
        deleteCalled = true;
        deleted = true;
        return <String, dynamic>{};
      }
      if (_isListRequest(options)) return deleted ? const <dynamic>[] : [_planJson(status: 'SUSPENDED')];
      return _planJson(status: 'SUSPENDED');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isFalse);
    expect(find.text('Eliminare il piano?'), findsOneWidget);
    expect(find.textContaining('perdute in modo definitivo'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Elimina')));
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
    expect(find.text('Inizia da qui'), findsOneWidget);
  });

  testWidgets('un piano Concluso compare come voce compatta e apre la vista di sola lettura (7.5)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (_isListRequest(options)) {
        return [
          _planJson(status: 'ACTIVE', id: 'plan-1', name: 'Dieta in corso', startDate: '2026-08-01'),
          _planJson(status: 'COMPLETED', id: 'plan-2', name: 'Dieta passata', startDate: '2026-01-01'),
        ];
      }
      return _planJson(status: 'ACTIVE');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));

    expect(find.textContaining('Concluso'), findsOneWidget);

    await tester.tap(find.text('Dieta passata'));
    await tester.pumpAndSettle();

    expect(find.text('Vista plan-2'), findsOneWidget);
  });

  testWidgets('nessun pulsante di eliminazione sulle voci compatte, per evitare pressioni accidentali', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (_isListRequest(options)) {
        return [
          _planJson(status: 'ACTIVE', id: 'plan-1', name: 'Dieta in corso', startDate: '2026-08-01'),
          _planJson(status: 'COMPLETED', id: 'plan-2', name: 'Dieta passata', startDate: '2026-01-01'),
        ];
      }
      return _planJson(status: 'ACTIVE');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));

    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('il pulsante di creazione compare anche quando l\'elenco non è vuoto (7.1)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter((options) {
      if (_isListRequest(options)) return [_planJson(status: 'ACTIVE')];
      return _planJson(status: 'ACTIVE');
    });
    dio.interceptors.add(ApiErrorInterceptor());

    await _pumpManagementScreen(tester, DietPlanApi(dio));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Nuovo piano'), findsOneWidget);
  });
}
