import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/theme_mode_controller.dart';
import 'package:healthylog/core/storage/preferences_store.dart';

/// 12.2 interfaccia.md: Chiaro, Scuro o Sistema, predefinito Sistema.
class _InMemoryPreferencesStore extends PreferencesStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  test('restituisce Sistema quando nessuna preferenza è ancora conservata', () async {
    final container = ProviderContainer(
      overrides: [preferencesStoreProvider.overrideWithValue(_InMemoryPreferencesStore())],
    );
    addTearDown(container.dispose);

    final mode = await container.read(themeModeControllerProvider.future);

    expect(mode, ThemeMode.system);
  });

  test('ripristina la preferenza già conservata', () async {
    final store = _InMemoryPreferencesStore()..values['theme_mode'] = ThemeMode.dark.name;
    final container = ProviderContainer(overrides: [preferencesStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);

    final mode = await container.read(themeModeControllerProvider.future);

    expect(mode, ThemeMode.dark);
  });

  test('setThemeMode aggiorna lo stato e persiste la nuova preferenza', () async {
    final store = _InMemoryPreferencesStore();
    final container = ProviderContainer(overrides: [preferencesStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);
    await container.read(themeModeControllerProvider.future);

    await container.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.light);

    expect(container.read(themeModeControllerProvider).value, ThemeMode.light);
    expect(store.values['theme_mode'], ThemeMode.light.name);
  });
}
