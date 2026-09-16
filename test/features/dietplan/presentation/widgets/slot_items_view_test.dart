import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/features/dietplan/data/slot_item.dart';
import 'package:healthylog/features/dietplan/presentation/widgets/slot_items_view.dart';

import '../../../../support/l10n_test_support.dart';

/// VG-3, GG-24, GG-25, 4.1 interfaccia: gli elementi di uno slot come li
/// presentano la card del pasto e le altre viste. Le quantità sono rese come
/// scritte, mai convertite, e le alternative sono annunciate da chiusa ed
/// elencate da aperta.
void main() {
  Future<void> pump(
    WidgetTester tester,
    List<SlotItem> items, {
    bool expanded = false,
    int maxItems = 4,
    Locale locale = testLocale,
  }) async {
    await tester.pumpWidget(MaterialApp(
      locale: locale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light,
      home: Scaffold(body: SlotItemsView(items: items, expanded: expanded, maxItems: maxItems)),
    ));
    await tester.pumpAndSettle();
  }

  const tisana = SlotItem(
    itemId: 'i1',
    kindCode: 'FOOD',
    name: 'Tisana',
    quantity: 250,
    unitCode: 'MILLILITER',
    alternatives: [
      SlotItemAlternative(kindCode: 'FOOD', name: 'Latte di soia', quantity: 200, unitCode: 'MILLILITER'),
      SlotItemAlternative(kindCode: 'FOOD', name: 'Tè verde'),
    ],
  );

  testWidgets('presenta denominazione e quantità nell\'unità scritta (GG-24)', (tester) async {
    await pump(tester, const [
      SlotItem(itemId: 'i1', kindCode: 'FOOD', name: 'Cornflakes', quantity: 30, unitCode: 'GRAM'),
      SlotItem(itemId: 'i2', kindCode: 'FOOD', name: 'Fette biscottate', quantity: 2, unitCode: 'SLICE'),
      SlotItem(itemId: 'i3', kindCode: 'FOOD', name: 'Miele', quantity: 1, unitCode: 'TEASPOON'),
    ]);

    expect(find.textContaining('Cornflakes'), findsOneWidget);
    expect(find.textContaining('30 g'), findsOneWidget);
    // Il plurale segue il numero, il singolare quando è uno.
    expect(find.textContaining('2 fette'), findsOneWidget);
    expect(find.textContaining('1 cucchiaino'), findsOneWidget);
  });

  testWidgets('un alimento senza quantità è ammesso (GG-22)', (tester) async {
    await pump(tester, const [SlotItem(itemId: 'i1', kindCode: 'FOOD', name: 'Verdure a volontà')]);

    expect(find.text('Verdure a volontà', findRichText: true), findsOneWidget);
  });

  testWidgets('uno slot privo di elementi dice che è da definire (GG-13)', (tester) async {
    await pump(tester, const []);

    expect(find.text('Da definire'), findsOneWidget);
  });

  testWidgets('da chiusa le alternative sono annunciate, da aperta elencate (GG-25, 4.1)', (tester) async {
    await pump(tester, const [tisana]);

    expect(find.textContaining('+2 alternative'), findsOneWidget);
    expect(find.textContaining('Latte di soia'), findsNothing);

    await pump(tester, const [tisana], expanded: true);

    expect(find.textContaining('+2 alternative'), findsNothing);
    expect(find.text('oppure Latte di soia  200 ml'), findsOneWidget);
    expect(find.text('oppure Tè verde'), findsOneWidget);
  });

  testWidgets('da chiusa gli elementi oltre il quarto sono riassunti (4.1)', (tester) async {
    await pump(tester, [
      for (var i = 1; i <= 6; i++) SlotItem(itemId: 'i$i', kindCode: 'FOOD', name: 'Elemento $i'),
    ]);

    expect(find.text('Elemento 4', findRichText: true), findsOneWidget);
    expect(find.text('Elemento 5', findRichText: true), findsNothing);
    expect(find.text('e altri 2'), findsOneWidget);
  });

  testWidgets('un\'unità sconosciuta è presentata col proprio codice (CO-7quater)', (tester) async {
    await pump(tester, const [
      SlotItem(itemId: 'i1', kindCode: 'FOOD', name: 'Passata', quantity: 2, unitCode: 'BARATTOLO'),
    ]);

    expect(find.textContaining('2 BARATTOLO'), findsOneWidget);
  });

  testWidgets('in inglese le unità seguono la lingua, non il sistema di misura (LO-3)', (tester) async {
    await pump(
      tester,
      const [SlotItem(itemId: 'i1', kindCode: 'FOOD', name: 'Bread', quantity: 2, unitCode: 'SLICE')],
      locale: const Locale('en'),
    );

    // GG-24: nessuna conversione, solo la denominazione dell'unità.
    expect(find.textContaining('2 slices'), findsOneWidget);
  });
}
