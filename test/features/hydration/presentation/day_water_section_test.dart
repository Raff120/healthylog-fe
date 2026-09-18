import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/hydration/data/hydration_api.dart';
import 'package:healthylog/features/hydration/presentation/widgets/day_water_section.dart';
import 'package:healthylog/features/hydration/providers/hydration_providers.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';

import '../../../support/l10n_test_support.dart';

/// Sezione dell'acqua nella vista giornaliera (AQ-16, 6.2
/// interfaccia.md): totale e obiettivo in forma testuale, **senza barra
/// di avanzamento** (AQ-16, AQ-17); comandi che registrano senza
/// conferma (AQ-5); annullamento della singola aggiunta (AQ-8); sezione
/// presente anche a totale nullo (AQ-19) e priva di comandi sulla
/// giornata futura (AQ-9).

String _iso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Registra le scritture, che sono ciò che i comandi devono produrre.
class _HydrationAdapter implements HttpClientAdapter {
  _HydrationAdapter({required this.day, required this.goalMl});

  Map<String, dynamic>? day;
  final int? goalMl;
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
    if (options.path == '/me/water-goal') return _json(200, {'valueMl': goalMl});
    if (options.path == '/water-intakes' && options.method == 'GET') {
      return _json(200, day == null ? const <Object>[] : [day!]);
    }
    if (options.path == '/water-intakes' && options.method == 'POST') {
      return _json(200, day ?? {'userId': 'user-1', 'date': options.data['date'], 'totalMl': 0, 'entries': []});
    }
    if (options.path.startsWith('/water-intakes/') && options.method == 'DELETE') {
      return _json(200, {'userId': 'user-1', 'date': _iso(DateTime.now()), 'totalMl': 0, 'entries': []});
    }
    return _json(404, {'code': 'RESOURCE_NOT_FOUND'});
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

class _ProfileAdapter implements HttpClientAdapter {
  _ProfileAdapter({this.unitSystem = 'METRIC'});

  final String unitSystem;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode({
          'id': 'user-1',
          'email': 'a@b.it',
          'emailVerified': true,
          'username': 'utente',
          'firstName': 'Nome',
          'lastName': 'Cognome',
          'birthDate': '1990-01-01',
          'birthPlace': 'Roma',
          'sex': 'MALE',
          'role': 'USER',
          'height': 180,
          'targetWeightKg': null,
          'timezone': 'Europe/Rome',
          'locale': 'IT',
          'unitSystem': unitSystem,
          'privacyPolicyVersion': '1',
          'privacyAcceptedAt': '2026-01-01T00:00:00Z',
          'deletionRequestedAt': null,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

Future<_HydrationAdapter> _pump(
  WidgetTester tester, {
  Map<String, dynamic>? day,
  int? goalMl,
  DateTime? date,
  String unitSystem = 'METRIC',
}) async {
  final adapter = _HydrationAdapter(day: day, goalMl: goalMl);
  final hydrationDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());
  final profileDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _ProfileAdapter(unitSystem: unitSystem)
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hydrationApiProvider.overrideWithValue(HydrationApi(hydrationDio)),
        profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
      ],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: Scaffold(body: DayWaterSection(date: date ?? DateTime.now())),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

/// Le quantità delle aggiunte sono diverse da quelle dei comandi rapidi
/// (AQ-6), che restano a schermo dietro il foglio: altrimenti la
/// medesima scritta comparirebbe due volte e l'asserzione non
/// distinguerebbe il foglio dalla pastiglia.
Map<String, dynamic> _dayJson({int totalMl = 750, List<Map<String, dynamic>>? entries}) => {
      'userId': 'user-1',
      'date': _iso(DateTime.now()),
      'totalMl': totalMl,
      'entries': entries ?? [
        {'entryId': 'e1', 'amountMl': 250},
        {'entryId': 'e2', 'amountMl': 300},
      ],
    };

void main() {
  testWidgets('presenta il totale e l\'obiettivo senza alcuna barra di avanzamento (AQ-16, AQ-17)',
      (tester) async {
    await _pump(tester, day: _dayJson(), goalMl: 2000);

    expect(find.text('750 ml'), findsOneWidget);
    expect(find.text('di 2 L'), findsOneWidget);
    // AQ-16: né barra, né percentuale, né ruota di avanzamento.
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('senza obiettivo presenta il solo bevuto, e nulla ne segnala la mancanza (AQ-11)',
      (tester) async {
    await _pump(tester, day: _dayJson());

    expect(find.text('750 ml'), findsOneWidget);
    expect(find.textContaining('di '), findsNothing);
  });

  testWidgets('resta presente a totale nullo, dove i comandi servono di più (AQ-19)', (tester) async {
    await _pump(tester);

    expect(find.text('0 ml'), findsOneWidget);
    expect(find.text('Bicchiere'), findsOneWidget);
    expect(find.text('Bottiglietta'), findsOneWidget);
    expect(find.text('Bottiglia'), findsOneWidget);
  });

  testWidgets('il tocco su una pastiglia registra la quantità senza conferma (AQ-5, AQ-6)', (tester) async {
    final adapter = await _pump(tester);

    await tester.tap(find.text('Bicchiere'));
    await tester.pumpAndSettle();

    final posts = adapter.requests.where((r) => r.method == 'POST').toList();
    expect(posts, hasLength(1));
    expect(posts.single.data['amountMl'], 150);
    // Nessuna conferma si è frapposta: l'errore si disfa dal foglio (AQ-8).
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('il foglio della giornata annulla una singola aggiunta (AQ-8, AQ-10)', (tester) async {
    final adapter = await _pump(tester, day: _dayJson());

    await tester.tap(find.text('750 ml'));
    await tester.pumpAndSettle();

    expect(find.text('Aggiunte della giornata'), findsOneWidget);
    expect(find.text('250 ml'), findsOneWidget);
    expect(find.text('300 ml'), findsOneWidget);
    // AQ-10: l'ora dell'aggiunta non compare.
    expect(find.textContaining(':'), findsNothing);

    await tester.tap(find.byTooltip('Rimuovi questa aggiunta').first);
    await tester.pumpAndSettle();

    final deletes = adapter.requests.where((r) => r.method == 'DELETE').toList();
    expect(deletes, hasLength(1));
    expect(deletes.single.path, endsWith('/entries/e1'));
  });

  /// LO-4bis: nel sistema imperiale i comandi portano le taglie d'uso —
  /// 6, 16 e 32 once fluide — e non la conversione dei valori metrici,
  /// che darebbe 5,1 fl oz per un bicchiere.
  testWidgets('nel sistema imperiale i comandi portano le taglie d\'uso (LO-4, LO-4bis)', (tester) async {
    final adapter = await _pump(tester, unitSystem: 'IMPERIAL');

    expect(find.text('6 fl oz'), findsOneWidget);
    expect(find.text('16 fl oz'), findsOneWidget);
    expect(find.text('32 fl oz'), findsOneWidget);

    await tester.tap(find.text('Bicchiere'));
    await tester.pumpAndSettle();

    // LO-7: quel che si registra sono comunque millilitri.
    final posts = adapter.requests.where((r) => r.method == 'POST').toList();
    expect(posts.single.data['amountMl'], 177);
  });

  testWidgets('sulla giornata futura non offre alcun comando (AQ-9)', (tester) async {
    await _pump(tester, date: DateTime.now().add(const Duration(days: 1)));

    expect(find.text('ACQUA'), findsOneWidget);
    expect(find.text('Bicchiere'), findsNothing);
    expect(find.text('0 ml'), findsNothing);
  });
}
