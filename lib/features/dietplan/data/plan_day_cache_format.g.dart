// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_day_cache_format.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Svuota le occorrenze locali se sono state scritte in un formato diverso da
/// quello corrente. Atteso da ogni lettura e scrittura della cache, cosicché
/// nessuna preceda la verifica quale che sia l'ordine in cui le schermate si
/// aprono.
///
/// `keepAlive`: la verifica è dell'avvio, non della schermata che per prima vi
/// incappa.

@ProviderFor(planDayCacheFormatCheck)
final planDayCacheFormatCheckProvider = PlanDayCacheFormatCheckProvider._();

/// Svuota le occorrenze locali se sono state scritte in un formato diverso da
/// quello corrente. Atteso da ogni lettura e scrittura della cache, cosicché
/// nessuna preceda la verifica quale che sia l'ordine in cui le schermate si
/// aprono.
///
/// `keepAlive`: la verifica è dell'avvio, non della schermata che per prima vi
/// incappa.

final class PlanDayCacheFormatCheckProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Svuota le occorrenze locali se sono state scritte in un formato diverso da
  /// quello corrente. Atteso da ogni lettura e scrittura della cache, cosicché
  /// nessuna preceda la verifica quale che sia l'ordine in cui le schermate si
  /// aprono.
  ///
  /// `keepAlive`: la verifica è dell'avvio, non della schermata che per prima vi
  /// incappa.
  PlanDayCacheFormatCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDayCacheFormatCheckProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDayCacheFormatCheckHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return planDayCacheFormatCheck(ref);
  }
}

String _$planDayCacheFormatCheckHash() =>
    r'07cbde91bc75e2514d83a77a2ac4dc618885aab7';
