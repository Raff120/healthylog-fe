// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Preferenza del tema (12.2 interfaccia.md): Chiaro, Scuro o Sistema,
/// predefinito Sistema — FE-18 definisce già le due varianti, questo
/// controller sceglie quale applicare. Persistita localmente
/// ([PreferencesStore]): nessuna sincronizzazione col server, a
/// differenza del fuso orario (LO-13), che il job di chiusura deve
/// conoscere (vedi decisioni.md).

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// Preferenza del tema (12.2 interfaccia.md): Chiaro, Scuro o Sistema,
/// predefinito Sistema — FE-18 definisce già le due varianti, questo
/// controller sceglie quale applicare. Persistita localmente
/// ([PreferencesStore]): nessuna sincronizzazione col server, a
/// differenza del fuso orario (LO-13), che il job di chiusura deve
/// conoscere (vedi decisioni.md).
final class ThemeModeControllerProvider
    extends $AsyncNotifierProvider<ThemeModeController, ThemeMode> {
  /// Preferenza del tema (12.2 interfaccia.md): Chiaro, Scuro o Sistema,
  /// predefinito Sistema — FE-18 definisce già le due varianti, questo
  /// controller sceglie quale applicare. Persistita localmente
  /// ([PreferencesStore]): nessuna sincronizzazione col server, a
  /// differenza del fuso orario (LO-13), che il job di chiusura deve
  /// conoscere (vedi decisioni.md).
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();
}

String _$themeModeControllerHash() =>
    r'96b47d77255f3ee11ba3ca4458dcf54703c9cdc0';

/// Preferenza del tema (12.2 interfaccia.md): Chiaro, Scuro o Sistema,
/// predefinito Sistema — FE-18 definisce già le due varianti, questo
/// controller sceglie quale applicare. Persistita localmente
/// ([PreferencesStore]): nessuna sincronizzazione col server, a
/// differenza del fuso orario (LO-13), che il job di chiusura deve
/// conoscere (vedi decisioni.md).

abstract class _$ThemeModeController extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
