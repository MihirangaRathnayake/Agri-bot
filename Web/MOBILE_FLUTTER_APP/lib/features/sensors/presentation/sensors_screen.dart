import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/rtdb_providers.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/value_pill.dart';

class SensorsScreen extends ConsumerWidget {
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soil1 = ref.watch(soilMoistureProvider(1));
    final soil2 = ref.watch(soilMoistureProvider(2));
    final light = ref.watch(lightStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sensors')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(soilMoistureProvider(1));
          ref.invalidate(soilMoistureProvider(2));
          ref.invalidate(lightStateProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              title: 'Soil health',
              subtitle: 'Realtime moisture from /soil/sensor1_percent and /soil/sensor2_percent',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _moistureCard(context, 'Sensor 1', soil1)),
                const SizedBox(width: 12),
                Expanded(child: _moistureCard(context, 'Sensor 2', soil2)),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              title: 'Ambient light',
              subtitle: 'From /light/state',
            ),
            const SizedBox(height: 12),
            DataCard(
              title: 'Light condition',
              child: light.when(
                data: (value) {
                  final isDark = value == 'DARK';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValuePill(
                        label: 'Light sensor',
                        value: value ?? '--',
                        icon: isDark ? Icons.nightlight_round : Icons.wb_sunny,
                        color: isDark
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                      StatusBadge(
                        label: isDark ? 'Night mode' : 'Day mode',
                        color: isDark
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  );
                },
                loading: () => const SkeletonBox(height: 40),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              title: 'Camera feed',
              subtitle: 'Placeholder stream for ESP32-CAM (http://<ESP32-CAM-IP>/stream)',
            ),
            const SizedBox(height: 12),
            DataCard(
              title: 'Live camera',
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'http://<ESP32-CAM-IP>/stream',
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Center(
                        child: Text(
                          'Camera offline. Update the stream URL when ready.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moistureCard(
    BuildContext context,
    String title,
    AsyncValue<double?> async,
  ) {
    return DataCard(
      title: title,
      child: async.when(
        data: (value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValuePill(
              label: 'Moisture',
              value: value == null ? '--' : '${value.toStringAsFixed(0)}%',
              icon: Icons.water_drop,
              color: _colorForValue(context, value),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value == null ? null : (value.clamp(0, 100) / 100),
              minHeight: 10,
            ),
          ],
        ),
        loading: () => const SkeletonBox(height: 40),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }

  Color _colorForValue(BuildContext context, double? value) {
    final scheme = Theme.of(context).colorScheme;
    if (value == null) return scheme.outline;
    if (value < 30) return scheme.error;
    if (value < 60) return scheme.tertiary;
    return scheme.primary;
  }
}
