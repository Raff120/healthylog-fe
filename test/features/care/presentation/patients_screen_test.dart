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
import 'package:healthylog/features/care/data/care_api.dart';
import 'package:healthylog/features/care/presentation/patients_screen.dart';
import 'package:healthylog/features/care/providers/care_providers.dart';

/// 9.1, 9.3 interfaccia.md; NU-1, VA-1..VA-6, VA-9, CP-1, CP-2, CP-8:
/// elenco dei Pazienti, richieste pendenti, ordinamento e invito.
class _CareAdapter implements HttpClientAdapter {
  _CareAdapter({this.patients = const [], this.requests = const [], this.lookupFound});

  final List<Map<String, dynamic>> patients;
  List<Map<String, dynamic>> requests;
  final Map<String, dynamic>? lookupFound;
  final requestedSorts = <String>[];
  Map<String, dynamic>? sentRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path == '/patients') {
      requestedSorts.add(options.queryParameters['sort'] as String);
      return _json(200, patients);
    }
    if (options.path == '/care-link-requests' && options.method == 'GET') return _json(200, requests);
    if (options.path == '/care-link-requests' && options.method == 'POST') {
      sentRequest = Map<String, dynamic>.from(options.data as Map);
      return _json(201, _requestJson(id: 'req-new', targetName: 'Luca Bianchi'));
    }
    if (options.method == 'DELETE' && options.path.startsWith('/care-link-requests/')) {
      requests = [];
      return _json(204, {});
    }
    if (options.path == '/users/lookup') {
      return lookupFound == null ? _json(404, {'code': 'RESOURCE_NOT_FOUND'}) : _json(200, lookupFound!);
    }
    throw StateError('Richiesta non gestita dal test: ${options.method} ${options.path}');
  }

  ResponseBody _json(int statusCode, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

Map<String, dynamic> _patientJson({
  required String id,
  required String firstName,
  required String lastName,
  Map<String, dynamic>? currentPlan,
  String? lastActivityAt,
  double? adherence,
}) =>
    {
      'userId': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': id,
      'careLinkId': 'link-$id',
      'linkedAt': '2026-09-01T00:00:00Z',
      'currentPlan': currentPlan,
      'adherence': adherence,
      'lastActivityAt': lastActivityAt,
    };

Map<String, dynamic> _requestJson({required String id, required String targetName, String status = 'PENDING'}) {
  final parts = targetName.split(' ');
  return {
    'id': id,
    'nutritionistId': 'nutri-1',
    'nutritionistFirstName': 'Anna',
    'nutritionistLastName': 'Verdi',
    'targetUserId': 'target-$id',
    'targetFirstName': parts.first,
    'targetLastName': parts.last,
    'message': null,
    'status': status,
    'expiresAt': '2026-09-30T00:00:00Z',
    'createdAt': '2026-09-08T00:00:00Z',
    'resolvedAt': null,
  };
}

Future<_CareAdapter> _pump(WidgetTester tester, _CareAdapter adapter) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const PatientsScreen()),
      GoRoute(
        path: '/patients/:id',
        builder: (context, state) => Scaffold(body: Text('Dettaglio ${state.pathParameters['id']}')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [careApiProvider.overrideWithValue(CareApi(dio))],
      child: MaterialApp.router(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

void main() {
  testWidgets('senza pazienti mostra lo stato vuoto con l\'invito (4.4)', (tester) async {
    await _pump(tester, _CareAdapter());

    expect(find.text('Nessun paziente collegato'), findsOneWidget);
    expect(find.text('Invita paziente'), findsOneWidget);
  });

  testWidgets('elenca i pazienti con gli indicatori, o un tratto in loro assenza (VA-2, VA-3)', (tester) async {
    await _pump(
      tester,
      _CareAdapter(patients: [
        _patientJson(
          id: 'p-1',
          firstName: 'Mario',
          lastName: 'Rossi',
          currentPlan: {'id': 'plan-1', 'name': 'Dieta estate', 'status': 'ACTIVE', 'startDate': '2026-09-01', 'endDate': null},
          lastActivityAt: '2026-09-07T10:00:00Z',
        ),
        _patientJson(id: 'p-2', firstName: 'Luca', lastName: 'Bianchi'),
      ]),
    );

    expect(find.text('Mario Rossi'), findsOneWidget);
    expect(find.text('Dieta estate · in corso'), findsOneWidget);
    expect(find.text('Luca Bianchi'), findsOneWidget);
    // VA-3: nessun piano, nessuna aderenza, nessuna attività — tre tratti per Luca, uno (aderenza) per Mario.
    expect(find.text('—'), findsNWidgets(4));
  });

  testWidgets('il tocco su un paziente conduce al dettaglio (VA-7)', (tester) async {
    await _pump(tester, _CareAdapter(patients: [_patientJson(id: 'p-1', firstName: 'Mario', lastName: 'Rossi')]));

    await tester.tap(find.text('Mario Rossi'));
    await tester.pumpAndSettle();

    expect(find.text('Dettaglio p-1'), findsOneWidget);
  });

  testWidgets('l\'ordinamento interroga il server con il criterio scelto (VA-4)', (tester) async {
    final adapter = await _pump(
      tester,
      _CareAdapter(patients: [_patientJson(id: 'p-1', firstName: 'Mario', lastName: 'Rossi')]),
    );
    expect(adapter.requestedSorts, ['name']);

    await tester.tap(find.text('Alfabetico'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Attività recente'));
    await tester.pumpAndSettle();

    expect(adapter.requestedSorts, ['name', 'activity']);
  });

  testWidgets('le richieste pendenti compaiono in cima e si revocano (VA-9, CP-8)', (tester) async {
    await _pump(tester, _CareAdapter(requests: [_requestJson(id: 'req-1', targetName: 'Luca Bianchi')]));

    expect(find.text('RICHIESTE PENDENTI'), findsOneWidget);
    expect(find.text('Luca Bianchi'), findsOneWidget);

    await tester.tap(find.text('Revoca'));
    await tester.pumpAndSettle();

    expect(find.text('Luca Bianchi'), findsNothing);
  });

  testWidgets('una richiesta decaduta compare senza azione (CP-7)', (tester) async {
    await _pump(tester, _CareAdapter(requests: [_requestJson(id: 'req-1', targetName: 'Luca Bianchi', status: 'EXPIRED')]));

    expect(find.text('Decaduta'), findsOneWidget);
    expect(find.text('Revoca'), findsNothing);
  });

  testWidgets('la ricerca senza esito mostra lo stato vuoto (CP-2)', (tester) async {
    await _pump(tester, _CareAdapter());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Inserisci il nome utente esatto della persona'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'inesistente');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerca'));
    await tester.pumpAndSettle();

    expect(find.text('Nessun utente con questo nome'), findsOneWidget);
  });

  testWidgets('l\'utente trovato si invita con un messaggio (CP-1, CP-3)', (tester) async {
    final adapter = await _pump(
      tester,
      _CareAdapter(lookupFound: {'id': 'user-9', 'username': 'lbianchi', 'firstName': 'Luca', 'lastName': 'Bianchi'}),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'lbianchi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerca'));
    await tester.pumpAndSettle();

    expect(find.text('Luca Bianchi'), findsOneWidget);
    expect(find.text('@lbianchi'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sono la dott.ssa Verdi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invia richiesta'));
    await tester.pumpAndSettle();

    expect(adapter.sentRequest, {'targetUserId': 'user-9', 'message': 'Sono la dott.ssa Verdi'});
    expect(find.text('Richiesta inviata.'), findsOneWidget);
  });

  /// VA-2, VA-5: l'aderenza del periodo recente compare come numero puro,
  /// senza soglie né denominazioni qualificative; il Paziente che segua un
  /// piano estraneo compare privo di indicatori (VA-3).
  testWidgets('mostra l\'aderenza del periodo recente, senza qualificazioni (VA-2)', (tester) async {
    await _pump(
      tester,
      _CareAdapter(patients: [
        _patientJson(id: 'p-1', firstName: 'Mario', lastName: 'Rossi', adherence: 72.4),
        _patientJson(id: 'p-2', firstName: 'Anna', lastName: 'Verdi'),
      ]),
    );

    expect(find.text('72%'), findsOneWidget);
    // VA-3: nessun indicatore per chi segue un piano non redatto dal
    // Nutrizionista — un trattino, non uno zero.
    expect(find.text('0%'), findsNothing);
  });
}
