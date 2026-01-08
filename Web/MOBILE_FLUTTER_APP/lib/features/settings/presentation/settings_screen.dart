import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/theme_provider.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/connection_diagnostics_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Appearance',
            subtitle: 'Light and dark themes',
          ),
          const SizedBox(height: 12),
          DataCard(
            title: 'Theme mode',
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('System'),
                  selected: themeMode == ThemeMode.system,
                  onSelected: (_) =>
                      ref.read(themeModeProvider.notifier).setMode(ThemeMode.system),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Light'),
                  selected: themeMode == ThemeMode.light,
                  onSelected: (_) =>
                      ref.read(themeModeProvider.notifier).setMode(ThemeMode.light),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Dark'),
                  selected: themeMode == ThemeMode.dark,
                  onSelected: (_) =>
                      ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Connectivity',
            subtitle: 'Validate Firebase Realtime Database access',
          ),
          const SizedBox(height: 12),
          const ConnectionDiagnosticsCard(),
          const SizedBox(height: 16),
          DataCard(
            title: 'Firebase setup reminder',
            child: const Text(
              'Run `flutterfire configure --project agri-bot-17548 --out=lib/firebase_options.dart` '
              'to generate platform configs. This project ships with a placeholder firebase_options.dart.',
            ),
          ),
        ],
      ),
    );
  }
}
