import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/device/system_gesture_guard.dart';

/// La striscia del gesto di sistema al bordo inferiore (3.2
/// interfaccia.md).
///
/// Segnalato dall'utente: risalendo dall'indicatore di Home per uscire
/// dall'applicazione, la schermata scorreva insieme al gesto.
void main() {
  const viewportHeight = 600.0;
  const band = 34.0;

  /// Un elenco scorrevole che arriva al bordo inferiore, avvolto
  /// dall'involucro, con la zona riservata del dispositivo dichiarata.
  Future<ScrollController> pumpList(WidgetTester tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, viewportHeight),
          padding: EdgeInsets.only(bottom: band),
          viewPadding: EdgeInsets.only(bottom: band),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: withSystemGestureGuard(
            child: ListView.builder(
              controller: controller,
              itemCount: 40,
              itemBuilder: (context, index) => SizedBox(
                height: 80,
                child: Text('riga $index'),
              ),
            ),
          ),
        ),
      ),
    );
    return controller;
  }

  testWidgets('il trascinamento che parte dalla striscia non scorre la schermata',
      (tester) async {
    final controller = await pumpList(tester);

    // Un punto dentro la striscia: è di lì che parte la risalita verso
    // l'indicatore di Home.
    await tester.dragFrom(
      const Offset(200, viewportHeight - band / 2),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
  });

  testWidgets('il trascinamento che parte sopra la striscia scorre come prima',
      (tester) async {
    final controller = await pumpList(tester);

    await tester.dragFrom(
      const Offset(200, viewportHeight - band - 20),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
  });

  /// Un `PageView` orizzontale che arriva al bordo inferiore, come la
  /// vista giornaliera. La superficie di prova è larga 800 quale che sia
  /// la `size` dichiarata: i trascinamenti ne superano la metà.
  Future<PageController> pumpPager(WidgetTester tester, {double padding = band, double minimumBand = 0}) async {
    final controller = PageController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: const Size(400, viewportHeight),
          padding: EdgeInsets.only(bottom: padding),
          viewPadding: EdgeInsets.only(bottom: padding),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: withSystemGestureGuard(
            minimumBand: minimumBand,
            child: PageView.builder(
              controller: controller,
              itemBuilder: (context, index) => Text('giorno $index'),
            ),
          ),
        ),
      ),
    );
    return controller;
  }

  /// La risalita obliqua: segnalato dall'utente, cambiava giornata.
  testWidgets('la risalita obliqua dalla striscia non cambia pagina', (tester) async {
    final controller = await pumpPager(tester);

    await tester.dragFrom(
      const Offset(700, viewportHeight - band / 2),
      const Offset(-500, -120),
    );
    await tester.pumpAndSettle();

    expect(controller.page, 0);
  });

  testWidgets('lo scorrimento orizzontale sopra la striscia cambia pagina come prima', (tester) async {
    final controller = await pumpPager(tester);

    await tester.dragFrom(
      const Offset(700, viewportHeight / 2),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(controller.page, 1);
  });

  /// Sul web la zona riservata può risultare nulla benché il gesto di
  /// sistema esista: la striscia minima resta.
  testWidgets('senza zona riservata resta la striscia minima, se dichiarata', (tester) async {
    final controller = await pumpPager(tester, padding: 0, minimumBand: 24);

    await tester.dragFrom(
      const Offset(700, viewportHeight - 12),
      const Offset(-500, -60),
    );
    await tester.pumpAndSettle();

    expect(controller.page, 0);
  });

  /// L'involucro non è un diaframma: contende il solo trascinamento
  /// verticale, e il tocco raggiunge quanto sta sotto.
  testWidgets('il tocco dentro la striscia raggiunge il comando sottostante',
      (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, viewportHeight),
          padding: EdgeInsets.only(bottom: band),
          viewPadding: EdgeInsets.only(bottom: band),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: withSystemGestureGuard(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: band,
                width: 200,
                child: GestureDetector(
                  onTap: () => pressed = true,
                  child: const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Il comando occupa per intero la striscia: vi si tocca dentro.
    await tester.tapAt(tester.getCenter(find.byType(ColoredBox)));
    await tester.pump();

    expect(pressed, isTrue);
  });

  /// Dove il dispositivo non riserva nulla al bordo inferiore non c'è
  /// striscia da sottrarre, e l'involucro non aggiunge alcun elemento.
  testWidgets('senza zona riservata l\'involucro è trasparente', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, viewportHeight)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: withSystemGestureGuard(child: const SizedBox.shrink()),
        ),
      ),
    );

    expect(find.byType(Stack), findsNothing);
  });
}
