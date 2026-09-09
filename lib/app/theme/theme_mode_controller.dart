import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/storage/preferences_store.dart';

part 'theme_mode_controller.g.dart';

const _themeModeKey = 'theme_mode';

/// Preferenza del tema (12.2 interfaccia.md): Chiaro, Scuro o Sistema,
/// predefinito Sistema — FE-18 definisce già le due varianti, questo
/// controller sceglie quale applicare. Persistita localmente
/// ([PreferencesStore]): nessuna sincronizzazione col server, a
/// differenza del fuso orario (LO-13), che il job di chiusura deve
/// conoscere (vedi decisioni.md).
@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  Future<ThemeMode> build() async {
    final stored = await ref.watch(preferencesStoreProvider).read(_themeModeKey);
    return ThemeMode.values.firstWhere((mode) => mode.name == stored, orElse: () => ThemeMode.system);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncValue.data(mode);
    await ref.read(preferencesStoreProvider).write(_themeModeKey, mode.name);
  }
}
