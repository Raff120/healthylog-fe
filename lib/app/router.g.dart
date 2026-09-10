// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Instradamento (FE-3): ogni schermata corrisponde a un indirizzo (3.2
/// interfaccia.md). Le schermate esterne all'applicazione (3.1) sono
/// definite qui. La protezione delle rotte autenticate è centralizzata
/// nel `redirect` sottostante — un solo punto di decisione, non
/// duplicato nelle singole schermate (vedi il commento su
/// [SplashScreen]).

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// Instradamento (FE-3): ogni schermata corrisponde a un indirizzo (3.2
/// interfaccia.md). Le schermate esterne all'applicazione (3.1) sono
/// definite qui. La protezione delle rotte autenticate è centralizzata
/// nel `redirect` sottostante — un solo punto di decisione, non
/// duplicato nelle singole schermate (vedi il commento su
/// [SplashScreen]).

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Instradamento (FE-3): ogni schermata corrisponde a un indirizzo (3.2
  /// interfaccia.md). Le schermate esterne all'applicazione (3.1) sono
  /// definite qui. La protezione delle rotte autenticate è centralizzata
  /// nel `redirect` sottostante — un solo punto di decisione, non
  /// duplicato nelle singole schermate (vedi il commento su
  /// [SplashScreen]).
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'24390a325b3e0c8c9e4478ff78c34c0a6e4c163f';
