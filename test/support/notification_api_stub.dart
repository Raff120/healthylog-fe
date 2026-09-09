import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/notification/data/notification_api.dart';

/// Stub di [NotificationApi] per i banchi di prova che non riguardano le
/// notifiche ma attraversano schermate che ne recano l'indicatore
/// nell'intestazione (NT-8: ogni destinazione principale, 3.1).
///
/// Senza di esso l'indicatore interrogherebbe il client HTTP reale: la
/// richiesta fallirebbe, e il fallimento porterebbe l'applicazione in
/// stato offline (OF-6), disabilitando le azioni di scrittura che il
/// banco di prova sta verificando.
NotificationApi stubNotificationApi({
  List<Map<String, dynamic>> notifications = const [],
  int unread = 0,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _NotificationStubAdapter(notifications: notifications, unread: unread)
    ..interceptors.add(ApiErrorInterceptor());
  return NotificationApi(dio);
}

class _NotificationStubAdapter implements HttpClientAdapter {
  _NotificationStubAdapter({required this.notifications, required this.unread});

  final List<Map<String, dynamic>> notifications;
  final int unread;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/notifications/unread-count') return _json(200, {'unread': unread});
    if (options.path == '/notifications') return _json(200, notifications);
    // NT-10, NT-11, NT-12: marcature ed eliminazione, senza corpo.
    return _json(204, const <String, Object>{});
  }

  ResponseBody _json(int statusCode, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}
