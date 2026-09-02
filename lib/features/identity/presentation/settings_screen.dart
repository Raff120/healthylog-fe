import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../data/timezones.dart';
import '../providers/profile_providers.dart';

/// Impostazioni (12.2 interfaccia.md). Versione minima introdotta in F11
/// (deroga: vedi decisioni.md): le sole sezioni Aspetto e Fuso orario, più
/// "Dispositivi collegati" — trasferita qui dal Profilo, sua sede propria
/// — non ancora Lingua, Unità di misura (F29) né Privacy (F31).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTimezone(BuildContext context, WidgetRef ref, String? current) async {
    final selected = await showModalBottomSheet<TimezoneOption>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _TimezonePickerSheet(current: current),
    );
    if (selected == null || !context.mounted) return;

    try {
      await ref.read(profileControllerProvider.notifier).saveTimezone(selected.id);
    } catch (error) {
      if (!context.mounted) return;
      final code = error.asApiException?.code;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeApiError(code ?? ''))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final profileState = ref.watch(profileControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Impostazioni', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _SectionHeader('Aspetto'),
            const SizedBox(height: AppSpacing.xs),
            _ThemeModeSelector(
              value: themeMode,
              onChanged: (mode) => ref.read(themeModeControllerProvider.notifier).setThemeMode(mode),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader('Data e ora'),
            const SizedBox(height: AppSpacing.xs),
            profileState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(
                describeApiError(error.asApiException?.code ?? ''),
                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
              data: (profile) => _SettingsRow(
                icon: Icons.public_outlined,
                label: 'Fuso orario',
                value: _labelFor(profile.timezone),
                onTap: () => _pickTimezone(context, ref, profile.timezone),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader('Sicurezza'),
            const SizedBox(height: AppSpacing.xs),
            _SettingsRow(
              icon: Icons.devices_outlined,
              label: 'Dispositivi collegati',
              onTap: () => context.push('/profile/devices'),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(String? timezoneId) {
    if (timezoneId == null) return 'Non impostato';
    final match = kTimezoneOptions.where((option) => option.id == timezoneId);
    return match.isEmpty ? timezoneId : match.first.label;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Text(label.toUpperCase(), style: typography.overline.copyWith(color: colors.textSecondary));
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(value: ThemeMode.light, label: Text('Chiaro')),
        ButtonSegment(value: ThemeMode.dark, label: Text('Scuro')),
        ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
      ],
      selected: {value},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) onChanged(selection.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: colors.surface,
        selectedBackgroundColor: colors.accentSubtle,
        selectedForegroundColor: colors.accent,
        textStyle: typography.label,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.label, required this.onTap, this.value});

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: typography.bodyLarge.copyWith(color: colors.textPrimary))),
              if (value != null) ...[
                Text(value!, style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
                const SizedBox(width: AppSpacing.xs),
              ],
              Icon(Icons.chevron_right, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimezonePickerSheet extends StatefulWidget {
  const _TimezonePickerSheet({required this.current});

  final String? current;

  @override
  State<_TimezonePickerSheet> createState() => _TimezonePickerSheetState();
}

class _TimezonePickerSheetState extends State<_TimezonePickerSheet> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final query = _query.text.trim().toLowerCase();
    final results = query.isEmpty
        ? kTimezoneOptions
        : kTimezoneOptions
            .where((option) =>
                option.label.toLowerCase().contains(query) || option.id.toLowerCase().contains(query))
            .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                  style: typography.bodyLarge.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cerca fuso orario',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final option = results[index];
                    return ListTile(
                      title: Text(option.label, style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
                      subtitle: Text(option.id, style: typography.caption.copyWith(color: colors.textSecondary)),
                      trailing: option.id == widget.current ? Icon(Icons.check, color: colors.accent) : null,
                      onTap: () => Navigator.of(context).pop(option),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
