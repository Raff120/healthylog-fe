import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../device/client_platform.dart';
import 'client_build.dart';

/// VR-13: dichiara a ogni richiesta, pubblica o autenticata, la piattaforma
/// e il numero di build del client. Il backend li confronta con il build
/// minimo (VR-15) e li registra sulla sessione (VR-20).
///
/// Una dichiarazione non disponibile è omessa, non inventata (VR-16).
class ClientHeadersInterceptor extends Interceptor {
  ClientHeadersInterceptor(this._ref, {this.platform = currentClientPlatform});

  static const platformHeader = 'X-App-Platform';
  static const buildHeader = 'X-App-Build';

  final Ref _ref;

  /// Rilevazione della piattaforma, sostituibile nei test.
  final String? Function() platform;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final declaredPlatform = platform();
    if (declaredPlatform != null) {
      options.headers[platformHeader] = declaredPlatform;
    }
    final build = _ref.read(clientBuildProvider);
    if (build != null) {
      options.headers[buildHeader] = '$build';
    }
    handler.next(options);
  }
}
