import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/widgets/group_day_grid_view.dart';
import 'package:healthylog/features/dietplan/providers/meal_swap_providers.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';

import '../../../../support/l10n_test_support.dart';

/// Risponde alla sola lettura della giornata di gruppo (EP-1) con il
/// corpo fornito dal banco di prova.
class _GroupDayAdapter implements HttpClientAdapter {
  _GroupDayAdapter(this.body);

  final Map<String, dynamic> body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode(body),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

final _today = dateOnly(DateTime.now());

Map<String, dynamic> _slot(
  String slotId,
  String type,
  int order,
  String content, {
  String? label,
  String status = 'TO_CONSUME',
  String? note,
  String? recipeName,
  String? recipeText,
}) =>
    {
      'slotId': slotId,
      'type': type,
      'label': label,
      'order': order,
      'content': content,
      'note': note,
      'recipeName': recipeName,
      'recipeText': recipeText,
      'status': status,
    };

Map<String, dynamic> _member(
  String userId,
  String firstName,
  List<Map<String, dynamic>> slots, {
  String coverage = 'ACTIVE',
  String? planId,
}) =>
    {
      'userId': userId,
      'firstName': firstName,
      'lastName': 'Rossi',
      'date': isoDate(_today),
      'coverage': coverage,
      'planId': planId ?? 'plan-$userId',
      'planName': 'Dieta',
      'planStartDate': '2026-09-01',
      'planEndDate': null,
      'slots': slots,
    };

/// [cook]: CU-2, CU-3. La larghezza è quella predefinita del banco di
/// prova (800): `medium`, tre colonne visibili — sufficiente ai due
/// membri di ogni prova qui.
Future<ProviderContainer> _pumpGrid(
  WidgetTester tester,
  List<Map<String, dynamic>> members, {
  bool cook = true,
}) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _GroupDayAdapter({'date': isoDate(_today), 'members': members})
    ..interceptors.add(ApiErrorInterceptor());

  final container = ProviderContainer(
    overrides: [
      planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
      isCookProvider.overrideWithValue(cook),
    ],
  );
  addTearDown(container.dispose);

  // Provider autoDispose: senza un ascoltatore lo stato scritto
  // dall'azione "Sposta" sarebbe eliminato prima che la prova possa
  // leggerlo — nell'applicazione è `PlanScreen` a osservarli.
  for (final subscription in [
    container.listen(mealSwapSelectionProvider, (_, _) {}),
    container.listen(selectedGroupMemberProvider, (_, _) {}),
    container.listen(selectedPlanViewProvider, (_, _) {}),
    container.listen(sideBySideModeProvider, (_, _) {}),
  ]) {
    addTearDown(subscription.close);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: Scaffold(body: GroupDayGridView(date: _today, currentUserId: 'user-1')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Due celle stanno nella medesima riga quando il loro contenuto
/// comincia alla stessa altezza: le colonne condividono la disposizione,
/// e la riga le allinea in cima (VG-14).
void _expectSameRow(WidgetTester tester, String first, String second) {
  expect(tester.getTopLeft(find.text(first)).dy, tester.getTopLeft(find.text(second)).dy);
}

void main() {
  group('allineamento delle righe (VG-14, GG-5, 6.3 interfaccia.md)', () {
    testWidgets(
      'il pranzo di chi non prevede la colazione sta nella riga del pranzo',
      (tester) async {
        await _pumpGrid(tester, [
          _member('user-1', 'Io', [
            _slot('a1', 'BREAKFAST', 0, 'Yogurt e cereali'),
            _slot('a2', 'LUNCH', 1, 'Pasta al pomodoro'),
            _slot('a3', 'DINNER', 2, 'Pesce al forno'),
          ]),
          // Solo pranzo e cena: allineati per `order` finivano nelle
          // righe di colazione e pranzo (segnalato dall'utente).
          _member('user-2', 'Maria', [
            _slot('b1', 'LUNCH', 0, 'Riso e verdure'),
            _slot('b2', 'DINNER', 1, 'Zuppa di legumi'),
          ]),
        ]);

        expect(find.text('Colazione'), findsOneWidget);
        expect(find.text('Pranzo'), findsOneWidget);
        expect(find.text('Cena'), findsOneWidget);

        _expectSameRow(tester, 'Pasta al pomodoro', 'Riso e verdure');
        _expectSameRow(tester, 'Pesce al forno', 'Zuppa di legumi');
        expect(
          tester.getTopLeft(find.text('Yogurt e cereali')).dy,
          lessThan(tester.getTopLeft(find.text('Riso e verdure')).dy),
        );

        // La colazione che il secondo membro non prevede reca il tratto
        // di assenza, non uno spazio vuoto.
        expect(find.byKey(const Key('groupSlotAbsent')), findsOneWidget);
      },
    );

    testWidgets(
      'gli spuntini si allineano per posizione nel tratto di giornata (GG-4)',
      (tester) async {
        await _pumpGrid(tester, [
          _member('user-1', 'Io', [
            _slot('a1', 'BREAKFAST', 0, 'Yogurt e cereali'),
            _slot('a2', 'SNACK', 1, 'Mandorle', label: 'Spuntino del mattino'),
            _slot('a3', 'LUNCH', 2, 'Pasta al pomodoro'),
            _slot('a4', 'SNACK', 3, 'Frutta fresca', label: 'Spuntino del pomeriggio'),
            _slot('a5', 'DINNER', 4, 'Pesce al forno'),
          ]),
          // Un solo spuntino, dopo il pranzo: sta con quello del
          // pomeriggio dell'altro, non con quello del mattino.
          _member('user-2', 'Maria', [
            _slot('b1', 'BREAKFAST', 0, 'Fette biscottate'),
            _slot('b2', 'LUNCH', 1, 'Riso e verdure'),
            _slot('b3', 'SNACK', 2, 'Yogurt greco', label: 'Spuntino del pomeriggio'),
            _slot('b4', 'DINNER', 3, 'Zuppa di legumi'),
          ]),
        ]);

        _expectSameRow(tester, 'Frutta fresca', 'Yogurt greco');
        expect(
          tester.getTopLeft(find.text('Mandorle')).dy,
          lessThan(tester.getTopLeft(find.text('Frutta fresca')).dy),
        );

        // GG-10: la riga del pomeriggio porta la denominazione su cui i
        // due concordano; quella del mattino la denominazione di chi
        // solo la prevede.
        expect(find.text('Spuntino del mattino'), findsOneWidget);
        expect(find.text('Spuntino del pomeriggio'), findsOneWidget);
        // Chi non prevede lo spuntino del mattino ne reca il tratto.
        expect(find.byKey(const Key('groupSlotAbsent')), findsOneWidget);
      },
    );

    testWidgets(
      'la riga riporta la denominazione generica quando i membri non concordano (GG-10)',
      (tester) async {
        await _pumpGrid(tester, [
          _member('user-1', 'Io', [
            _slot('a1', 'SNACK', 0, 'Mandorle', label: 'Spuntino del mattino'),
            _slot('a2', 'LUNCH', 1, 'Pasta al pomodoro'),
          ]),
          _member('user-2', 'Maria', [
            _slot('b1', 'SNACK', 0, 'Cracker', label: 'Metà mattina'),
            _slot('b2', 'LUNCH', 1, 'Riso e verdure'),
          ]),
        ]);

        _expectSameRow(tester, 'Mandorle', 'Cracker');
        expect(find.text('Spuntino'), findsOneWidget);
        expect(find.text('Spuntino del mattino'), findsNothing);
      },
    );
  });

  group('card espandibile (4.1 interfaccia.md)', () {
    testWidgets('il tocco apre il pannello e ne mostra la nota accessoria (GG-14)', (tester) async {
      await _pumpGrid(tester, [
        _member('user-1', 'Io', [
          _slot('a1', 'LUNCH', 0, 'Pasta al pomodoro', note: 'Con parmigiano a parte'),
        ]),
      ]);

      expect(find.text('Con parmigiano a parte'), findsNothing);

      await tester.tap(find.text('Pasta al pomodoro'));
      await tester.pumpAndSettle();

      expect(find.text('Con parmigiano a parte'), findsOneWidget);

      await tester.tap(find.text('Pasta al pomodoro'));
      await tester.pumpAndSettle();

      expect(find.text('Con parmigiano a parte'), findsNothing);
    });

    testWidgets(
      'con una ricetta il contenuto compare solo da aperta, e la denominazione apre il foglio (GG-15, GG-18)',
      (tester) async {
        await _pumpGrid(tester, [
          _member('user-1', 'Io', [
            _slot(
              'a1',
              'LUNCH',
              0,
              'Pasta al pomodoro',
              recipeName: 'Pasta fresca',
              recipeText: 'Cuocere la pasta...',
            ),
          ]),
        ]);

        expect(find.text('Pasta fresca'), findsOneWidget);
        expect(find.text('Pasta al pomodoro'), findsNothing);

        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();
        expect(find.text('Pasta al pomodoro'), findsOneWidget);

        await tester.tap(find.text('Pasta fresca'));
        await tester.pumpAndSettle();

        expect(find.text('Cuocere la pasta...'), findsOneWidget);
      },
    );
  });

  group('inversione dalla vista affiancata (VG-13, IG-1)', () {
    testWidgets(
      'il Cuoco avvia lo spostamento sulla colonna di un membro e passa alla settimanale',
      (tester) async {
        final container = await _pumpGrid(tester, [
          _member('user-1', 'Io', [_slot('a1', 'LUNCH', 0, 'Pasta al pomodoro')]),
          _member('user-2', 'Maria', [_slot('b1', 'LUNCH', 0, 'Riso e verdure')], planId: 'plan-2'),
        ]);

        await tester.tap(find.text('Riso e verdure'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sposta'));
        await tester.pumpAndSettle();

        final origin = container.read(mealSwapSelectionProvider);
        expect(origin, isNotNull);
        expect(origin!.planId, 'plan-2');
        expect(origin.slotId, 'b1');
        // VS-8: la destinazione si sceglie in settimanale, sul piano del
        // membro, che diventa quello corrente (VG-11).
        expect(container.read(selectedGroupMemberProvider), 'user-2');
        expect(container.read(selectedPlanViewProvider), PlanViewMode.week);
        expect(container.read(sideBySideModeProvider), isFalse);
      },
    );

    testWidgets('sulla propria colonna lo spostamento non porta alcun membro', (tester) async {
      final container = await _pumpGrid(tester, [
        _member('user-1', 'Io', [_slot('a1', 'LUNCH', 0, 'Pasta al pomodoro')], planId: 'plan-1'),
      ]);

      await tester.tap(find.text('Pasta al pomodoro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sposta'));
      await tester.pumpAndSettle();

      expect(container.read(mealSwapSelectionProvider)!.planId, 'plan-1');
      expect(container.read(selectedGroupMemberProvider), isNull);
    });

    testWidgets('il membro non Cuoco non trova lo spostamento sulla colonna altrui (UT-12)', (tester) async {
      await _pumpGrid(
        tester,
        [
          _member('user-1', 'Io', [_slot('a1', 'LUNCH', 0, 'Pasta al pomodoro')]),
          _member('user-2', 'Maria', [_slot('b1', 'LUNCH', 0, 'Riso e verdure')]),
        ],
        cook: false,
      );

      await tester.tap(find.text('Riso e verdure'));
      await tester.pumpAndSettle();
      expect(find.text('Sposta'), findsNothing);

      await tester.tap(find.text('Pasta al pomodoro'));
      await tester.pumpAndSettle();
      expect(find.text('Sposta'), findsOneWidget);
    });

    testWidgets(
      'la card aperta con lo spostamento sta nella colonna stretta di uno schermo compatto (VG-15)',
      (tester) async {
        // `compact` (< 600): due colonne visibili, la larghezza minima
        // di 140 per ciascuna — il caso più angusto per l'azione.
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pumpGrid(tester, [
          _member('user-1', 'Io', [
            _slot('a1', 'LUNCH', 0, 'Pasta al pomodoro con verdure di stagione', note: 'Senza sale'),
          ]),
          _member('user-2', 'Maria', [_slot('b1', 'LUNCH', 0, 'Riso e verdure')]),
        ]);

        await tester.tap(find.text('Pasta al pomodoro con verdure di stagione'));
        await tester.pumpAndSettle();

        expect(find.text('Senza sale'), findsOneWidget);
        expect(find.text('Sposta'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('lo slot già consumato non è ammissibile come origine (MS-8)', (tester) async {
      await _pumpGrid(tester, [
        _member('user-1', 'Io', [
          _slot('a1', 'LUNCH', 0, 'Pasta al pomodoro', status: 'CONSUMED'),
        ]),
      ]);

      await tester.tap(find.text('Pasta al pomodoro'));
      await tester.pumpAndSettle();

      expect(find.text('Sposta'), findsNothing);
    });

    testWidgets('la giornata non coperta da un piano Attivo non offre lo spostamento (MS-8)', (tester) async {
      await _pumpGrid(tester, [
        _member(
          'user-1',
          'Io',
          [_slot('a1', 'LUNCH', 0, 'Pasta al pomodoro')],
          coverage: 'COMPLETED',
        ),
      ]);

      await tester.tap(find.text('Pasta al pomodoro'));
      await tester.pumpAndSettle();

      expect(find.text('Sposta'), findsNothing);
    });
  });
}
