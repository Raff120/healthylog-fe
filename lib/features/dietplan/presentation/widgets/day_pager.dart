import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/plan_day_date.dart';

/// Scorrimento fra giorni adiacenti della vista giornaliera (6.2
/// interfaccia.md: «lo scorrimento orizzontale del contenuto cambia
/// giorno»).
///
/// Il contenuto segue il dito e si assesta sul giorno di arrivo, come
/// nello sfogliare una galleria: il giorno accanto entra via via che il
/// gesto procede, invece di sostituire il precedente a gesto concluso.
/// Il gesto interrotto a metà torna indietro da sé — la conferma che il
/// giorno cambia sta nel movimento, non solo nel risultato.
///
/// Il giorno visibile resta quello del riferimento temporale condiviso
/// (VS-14): il pager lo comunica quando la pagina cambia e vi si allinea
/// quando cambia altrove — riga dei giorni, calendario, «Oggi», frecce
/// della settimana, secondo tocco su *Piano*.
class DayPager extends StatefulWidget {
  const DayPager({
    super.key,
    required this.selectedDate,
    required this.onSelect,
    required this.dayBuilder,
  });

  /// Giorno mostrato, normalizzato a mezzanotte locale dal pager stesso.
  final DateTime selectedDate;

  /// Chiamato quando lo scorrimento si assesta su un altro giorno.
  final ValueChanged<DateTime> onSelect;

  /// Contenuto di una giornata. Costruito per il giorno visibile e, non
  /// appena il gesto comincia, per quello verso cui ci si sta spostando.
  final Widget Function(BuildContext context, DateTime date) dayBuilder;

  @override
  State<DayPager> createState() => _DayPagerState();
}

class _DayPagerState extends State<DayPager> {
  /// VG-16, VG-17: la navigazione non ha limite temporale, ma
  /// [PageView] non conosce indici negativi. Il giorno di partenza sta
  /// a metà di una scala che lascia oltre mille anni per parte: il
  /// limite non è raggiungibile, e le pagine sono costruite a richiesta,
  /// quindi la scala non costa nulla.
  static const int _anchorPage = 500000;

  /// Giorno cui corrisponde [_anchorPage]. Fissato alla costruzione e
  /// mai più mosso: la corrispondenza fra indice e data deve restare
  /// stabile per tutta la vita del pager.
  late final DateTime _anchor;

  late final PageController _controller;

  /// Pagina su cui il pager si considera fermo. Tenuta qui e non letta
  /// da [PageController.page], che durante un'animazione indica una
  /// posizione intermedia.
  int _page = _anchorPage;

  @override
  void initState() {
    super.initState();
    _anchor = dateOnly(widget.selectedDate);
    _controller = PageController(initialPage: _anchorPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DayPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _pageOf(widget.selectedDate);
    if (target == _page) return;
    _page = target;
    if (!_controller.hasClients) return;
    // Il giorno accanto è raggiungibile scorrendo, e chi lo tocca nella
    // riga dei giorni si aspetta lo stesso movimento; un salto lontano
    // — il calendario, «Oggi» da un altro mese — non ha un percorso da
    // mostrare, e attraversare centinaia di giornate sarebbe un inganno.
    if ((target - _controller.page!.round()).abs() == 1) {
      _controller.animateToPage(
        target,
        duration: AppSpacing.motionStateTransition,
        curve: AppSpacing.motionSoftCurve,
      );
    } else {
      _controller.jumpToPage(target);
    }
  }

  DateTime _dateAtPage(int page) =>
      DateTime(_anchor.year, _anchor.month, _anchor.day + page - _anchorPage);

  /// Distanza in giorni calcolata su UTC: fra due mezzanotti locali
  /// separate dal cambio dell'ora legale ne corrono 23 o 25, e
  /// `Duration.inDays` le troncherebbe al giorno sbagliato.
  int _pageOf(DateTime date) {
    final day = dateOnly(date);
    final from = DateTime.utc(_anchor.year, _anchor.month, _anchor.day);
    final to = DateTime.utc(day.year, day.month, day.day);
    return _anchorPage + to.difference(from).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      // FE-11: il gesto non dipende dalla piattaforma. Su schermo ampio
      // si trascina con il puntatore, che Flutter di suo non conta fra
      // i dispositivi di scorrimento.
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
          PointerDeviceKind.trackpad,
        },
        scrollbars: false,
      ),
      onPageChanged: (page) {
        if (page == _page) return;
        _page = page;
        widget.onSelect(_dateAtPage(page));
      },
      itemBuilder: (context, index) =>
          widget.dayBuilder(context, _dateAtPage(index)),
    );
  }
}
