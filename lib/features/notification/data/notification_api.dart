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

  /// NT-10: marcatura conseguente al tocco esplicito.
  Future<void> markRead(String id) => _dio.post('/notifications/$id/read');

  /// NT-11: tutte in un'unica operazione.
  Future<void> markAllRead() => _dio.post('/notifications/read-all');

  /// NT-12: eliminazione singola, di una notifica letta o non letta.
  Future<void> delete(String id) => _dio.delete('/notifications/$id');
}
