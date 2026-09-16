import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import '../api/client_headers_interceptor.dart';

part 'service_status_client.g.dart';

/// Client HTTP per il solo endpoint di stato, con cui si riconosce la fine
/// della manutenzione (MM-9).
///
/// È distinto dagli altri per la base: lo stato non appartiene al contratto e
/// non reca il prefisso di versione (VR-1), che gli altri client antepongono a
/// ogni percorso. Passa comunque dal proxy, l'unico a sapere della
/// manutenzione (MM-3).
///
/// Non porta l'intercettore della manutenzione — l'esito lo interpreta
/// [MaintenanceController], che di quella verifica ha bisogno in entrambi i
/// sensi — né quello della connettività: una verifica periodica che fallisce
/// per assenza di rete non è un'osservazione dell'Utente sulla propria
/// connessione. Dichiara invece piattaforma e build, come ogni altra
/// richiesta (VR-13).
///
/// `keepAlive`: stessa ragione degli altri client HTTP.
@Riverpod(keepAlive: true)
Dio serviceStatusClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(ClientHeadersInterceptor(ref));
  return dio;
}
