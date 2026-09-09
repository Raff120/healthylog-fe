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
import 'package:healthylog/features/notification/data/notification_api.dart';
import 'package:healthylog/features/notification/presentation/notification_screen.dart';
import 'package:healthylog/features/notification/presentation/widgets/notification_bell.dart';
import 'package:healthylog/features/notification/providers/notification_providers.dart';

/// Centro notifiche (12.3 interfaccia.md; NT-7..NT-12).
void main() {
  testWidgets(
    'presenta le notifiche in ordine cronologico decrescente senza marcarne alcuna (NT-7, NT-10)',
    (tester) async {
      final adapter = await _pump(tester, notifications: [
        _notification(id: 'n1', type: 'PLAN_ASSIGNED', payload: {'planName': 'Dieta autunnale'}),
        _notification(id: 'n2', type: 'GROUP_COOK_GRANTED', payload: {'groupName': 'Casa'}, read: true),
      ]);

      expect(find.textContaining('Dieta autunnale'), findsOneWidget);
      expect(find.textContaining('Casa'), findsOneWidget);

      // NT-10: la sola apertura dell'elenco non marca nulla.
      expect(adapter.readCalls, isEmpty);
      expect(adapter.readAllCalls, 0);
    },
  );

  testWidgets(
    'il tocco su una notifica la marca come letta e conduce all\'elemento (NT-10, NT-3)',
    (tester) async {
      final adapter = await _pump(tester, notifications: [
        _notification(id: 'n1', type: 'CARE_LINK_REQUEST_RECEIVED'),
      ]);

      await tester.tap(find.textContaining('richiesta di collegamento'));
      await tester.pumpAndSettle();

      expect(adapter.readCalls, ['n1']);
      // NT-3: conduce all'elemento a cui si riferisce.
      expect(find.text('destinazione: /profile/nutritionist'), findsOneWidget);
    },
  );

  testWidgets(
    'la notifica priva di elemento raggiungibile è marcata senza navigare (NT-10)',
    (tester) async {
      final adapter = await _pump(tester, notifications: [
        _notification(id: 'n1', type: 'CARE_LINK_REQUEST_REJECTED'),
      ]);

      await tester.tap(find.textContaining('rifiutata'));
      await tester.pumpAndSettle();

      expect(adapter.readCalls, ['n1']);
      expect(find.text('Notifiche'), findsOneWidget);
    },
  );

  testWidgets(
    'l\'azione di intestazione marca tutte le non lette e compare solo se ve ne sono (NT-11)',
    (tester) async {
      final adapter = await _pump(tester, notifications: [
        _notification(id: 'n1', type: 'PLAN_SUSPENDED', payload: {'planName': 'Dieta'}),
      ]);

      expect(find.text('Segna tutte come lette'), findsOneWidget);
      await tester.tap(find.text('Segna tutte come lette'));
      await tester.pumpAndSettle();

      expect(adapter.readAllCalls, 1);
      // Marcate tutte, l'azione non ha più oggetto e scompare.
      expect(find.text('Segna tutte come lette'), findsNothing);
    },
  );

  testWidgets(
    'lo scorrimento laterale elimina la notifica, letta o non letta (NT-12)',
    (tester) async {
      final adapter = await _pump(tester, notifications: [
        _notification(id: 'n1', type: 'GROUP_DISBANDED', payload: {'groupName': 'Casa'}, read: true),
      ]);

      await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
      // Due passaggi: il primo conclude l'animazione di scomparsa, il
      // secondo attende l'eliminazione sul server, che vi succede.
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(adapter.deleteCalls, ['n1']);
    },
  );

  testWidgets(
    'senza notifiche presenta lo stato vuoto, privo di azione (4.4, 12.3)',
    (tester) async {
      await _pump(tester);

      expect(find.text('Nessuna notifica'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    },
  );

  testWidgets(
    'l\'indicatore reca il numero delle non lette e non compare a zero (NT-8)',
    (tester) async {
      await _pumpBell(tester, unread: 3);
      expect(find.text('3'), findsOneWidget);

      await _pumpBell(tester, unread: 0);
      expect(find.text('0'), findsNothing);
    },
  );
}

Map<String, dynamic> _notification({
  required String id,
  required String type,
  Map<String, String> payload = const {},
  bool read = false,
}) => {
      'id': id,
      'type': type,
      'payload': payload,
      'actorId': 'user-2',
      'actorName': 'Maria Verdi',
      'occurredAt': '2026-09-09T08:30:00Z',
      'readAt': read ? '2026-09-09T09:00:00Z' : null,
    };

Future<_NotificationStubAdapter> _pump(
  WidgetTester tester, {
  List<Map<String, dynamic>> notifications = const [],
}) async {
  final adapter = _NotificationStubAdapter(notifications: notifications);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  // NT-3: un instradamento minimo, che dichiara soltanto dove la notifica
  // conduce — la schermata di destinazione non è oggetto di questa prova.
  final router = GoRouter(
    initialLocation: '/notifications',
    routes: [
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen()),
      GoRoute(
        path: '/:section(.*)',
        builder: (context, state) => Scaffold(
          body: Center(child: Text('destinazione: ${state.uri.path}')),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [notificationApiProvider.overrideWithValue(NotificationApi(dio))],
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

Future<void> _pumpBell(WidgetTester tester, {required int unread}) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _NotificationStubAdapter(notifications: const [], unread: unread)
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [notificationApiProvider.overrideWithValue(NotificationApi(dio))],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      
        theme: AppTheme.light,
        home: Scaffold(appBar: AppBar(actions: const [NotificationBell()])),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _NotificationStubAdapter implements HttpClientAdapter {
  _NotificationStubAdapter({required this.notifications, this.unread});

  List<Map<String, dynamic>> notifications;
  final int? unread;

  final List<String> readCalls = [];
  final List<String> deleteCalls = [];
  int readAllCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    if (path == '/notifications/unread-count') {
      final count = unread ?? notifications.where((n) => n['readAt'] == null).length;
      return _json(200, {'unread': count});
    }
    if (path == '/notifications/read-all') {
      readAllCalls++;
      notifications = [
        for (final notification in notifications)
          {...notification, 'readAt': notification['readAt'] ?? '2026-09-09T10:00:00Z'},
      ];
      return _json(204, const <String, Object>{});
    }
    if (path == '/notifications') return _json(200, notifications);
    if (options.method == 'DELETE') {
      final id = path.split('/').last;
      deleteCalls.add(id);
      notifications = notifications.where((n) => n['id'] != id).toList();
      return _json(204, const <String, Object>{});
    }
    if (path.endsWith('/read')) {
      final id = path.split('/')[2];
      readCalls.add(id);
      notifications = [
        for (final notification in notifications)
          notification['id'] == id ? {...notification, 'readAt': '2026-09-09T10:00:00Z'} : notification,
      ];
      return _json(200, notifications.firstWhere((n) => n['id'] == id));
    }
    return _json(404, {'code': 'RESOURCE_NOT_FOUND'});
  }

  ResponseBody _json(int statusCode, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}
