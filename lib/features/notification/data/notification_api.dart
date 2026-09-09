import 'package:dio/dio.dart';

import 'app_notification.dart';

/// Chiamate HTTP del centro notifiche (4.4 tecnica; 4.5 funzionale).
class NotificationApi {
  const NotificationApi(this._dio);

  final Dio _dio;

  /// NT-7: l'elenco in ordine cronologico decrescente. NT-9: [unreadOnly]
  /// lo restringe alle non lette.
  Future<List<AppNotification>> list({bool unreadOnly = false}) async {
    final response = await _dio.get('/notifications', queryParameters: {
      if (unreadOnly) 'unreadOnly': true,
    });
    return (response.data as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// NT-8: il conteggio delle non lette.
  Future<int> unreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return (response.data as Map<String, dynamic>)['unread'] as int;
  }
}
