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
import 'package:healthylog/features/care/presentation/nutritionist_screen.dart';
import 'package:healthylog/features/care/providers/care_providers.dart';

/// 9.3 interfaccia.md, lato Utente; CP-4, CP-5, CP-6, CP-14, CP-18,
/// RG-5: stato vuoto, richiesta ricevuta con le conseguenze presentate
/// prima della scelta, collegamento in corso e revoca.
Map<String, dynamic> _linkJson() => {
      'id': 'link-1',
      'nutritionistId': 'nutri-1',
      'nutritionistFirstName': 'Anna',
      'nutritionistLastName': 'Verdi',
      'patientId': 'user-1',
      'patientFirstName': 'Mario',
      'patientLastName': 'Rossi',
      'status': 'ACTIVE',
      'createdAt': '2026-09-01T00:00:00Z',
      'revokedAt': null,
    };

Map<String, dynamic> _requestJson() => {
      'id': 'req-1',
      'nutritionistId': 'nutri-1',
      'nutritionistFirstName': 'Anna',
      'nutritionistLastName': 'Verdi',
      'targetUserId': 'user-1',
      'targetFirstName': 'Mario',
      'targetLastName': 'Rossi',
      'message': 'Ci siamo sentiti in studio',
      'status': 'PENDING',
      'expiresAt': '2026-09-30T00:00:00Z',
      'createdAt': '2026-09-08T00:00:00Z',
      'resolvedAt': null,
    };

/// Simula il ciclo: nessun collegamento e una richiesta pendente; poi,
/// secondo l'azione compiuta, il collegamento istituito (accettazione)
/// o l'assenza di richieste (rifiuto); infine la revoca.
class _CareLifecycleAdapter implements HttpClientAdapter {
  _CareLifecycleAdapter({this.linked = false, this.pending = false});

  bool linked;
  bool pending;
  final actions = <String>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path == '/care-links/current') {
      return linked ? _json(200, _linkJson()) : _json(404, {'code': 'RESOURCE_NOT_FOUND'});
    }
    if (options.path == '/care-link-requests') return _json(200, pending ? [_requestJson()] : const <Object>[]);
    if (options.path.endsWith('/accept')) {
      actions.add('accept');
      linked = true;
      pending = false;
      return _json(200, _linkJson());
    }
    if (options.path.endsWith('/reject')) {
      actions.add('reject');
      pending = false;
      return _json(204, {});
    }
    if (options.method == 'DELETE' && options.path.startsWith('/care-links/')) {
      actions.add('revoke');
      linked = false;
      return _json(204, {});
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

Future<_CareLifecycleAdapter> _pump(WidgetTester tester, _CareLifecycleAdapter adapter) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());
  final router = GoRouter(
    initialLocation: '/profile/nutritionist',
    routes: [GoRoute(path: '/profile/nutritionist', builder: (context, state) => const NutritionistScreen())],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [careApiProvider.overrideWithValue(CareApi(dio))],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

void main() {
  testWidgets('senza collegamento né richieste mostra lo stato vuoto, senza azione (RG-5, 4.4)', (tester) async {
    await _pump(tester, _CareLifecycleAdapter());

    expect(find.text('Nessun nutrizionista collegato'), findsOneWidget);
    expect(find.text('Puoi gestire il piano in autonomia'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('la richiesta ricevuta presenta identità e conseguenze prima dell\'accettazione (CP-5)', (tester) async {
    final adapter = await _pump(tester, _CareLifecycleAdapter(pending: true));

    expect(find.text('RICHIESTE RICEVUTE'), findsOneWidget);
    await tester.tap(find.text('Anna Verdi'));
    await tester.pumpAndSettle();

    expect(find.text('“Ci siamo sentiti in studio”'), findsOneWidget);
    expect(find.text('redigerà il tuo piano alimentare'), findsOneWidget);
    expect(find.text('potrà registrare misurazioni per tuo conto'), findsOneWidget);
    expect(find.textContaining('non potrai più modificare il contenuto del piano'), findsOneWidget);
    // CP-18: cosa conserverà dopo un'eventuale revoca.
    expect(find.textContaining('Dopo la revoca conserverà solo'), findsOneWidget);

    await tester.tap(find.text('Accetta'));
    await tester.pumpAndSettle();

    expect(adapter.actions, ['accept']);
    expect(find.text('COLLEGAMENTO IN CORSO'), findsOneWidget);
    expect(find.text('Anna Verdi'), findsOneWidget);
  });

  testWidgets('il rifiuto non richiede motivazione (CP-6)', (tester) async {
    final adapter = await _pump(tester, _CareLifecycleAdapter(pending: true));

    await tester.tap(find.text('Anna Verdi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rifiuta'));
    await tester.pumpAndSettle();

    expect(adapter.actions, ['reject']);
    expect(find.text('Nessun nutrizionista collegato'), findsOneWidget);
  });

  testWidgets('la revoca è a conferma rafforzata ed espone cosa sarà conservato (CP-14, CP-18)', (tester) async {
    final adapter = await _pump(tester, _CareLifecycleAdapter(linked: true));

    expect(find.text('COLLEGAMENTO IN CORSO'), findsOneWidget);
    await tester.tap(find.text('Revoca il collegamento'));
    await tester.pumpAndSettle();

    expect(find.text('Revocare il collegamento?'), findsOneWidget);
    expect(find.text('Il nutrizionista conserverà:'), findsOneWidget);
    expect(find.textContaining('gli schemi dei piani che ha redatto'), findsOneWidget);
    expect(find.textContaining('spunte, inversioni e statistiche'), findsOneWidget);

    await tester.tap(find.text('Revoca'));
    await tester.pumpAndSettle();

    expect(adapter.actions, ['revoke']);
    // CP-19, 9.3: barra temporanea sul riacquisto delle facoltà.
    expect(find.textContaining('piena facoltà sul tuo piano'), findsOneWidget);
    expect(find.text('Nessun nutrizionista collegato'), findsOneWidget);
  });
}
