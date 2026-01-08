import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/providers/rtdb_providers.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../../../shared/widgets/status_badge.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temp = ref.watch(temperatureProvider);
    final humidity = ref.watch(humidityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(temperatureProvider);
          ref.invalidate(humidityProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              title: 'Microclimate',
              subtitle: 'Live values from /weather/temperature and /weather/humidity',
            ),
            const SizedBox(height: 12),
            DataCard(
              title: 'Temperature',
              subtitle: 'Auto-updated stream',
              trailing: StatusBadge(
                label: 'Live',
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.waves,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: temp.when(
                      data: (value) => _bigReading(
                        context,
                        formatTemperature(value),
                        'Current',
                        Icons.thermostat,
                        Theme.of(context).colorScheme.primary,
                      ),
                      loading: () => const SkeletonBox(height: 48),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _rangeCard(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DataCard(
              title: 'Humidity',
              subtitle: 'Comfort indicator',
              child: humidity.when(
                data: (value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bigReading(
                      context,
                      value == null ? '--' : '${value.toStringAsFixed(0)}%',
                      'Relative humidity',
                      Icons.water_drop,
                      Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: value == null ? null : (value.clamp(0, 100) / 100),
                      minHeight: 10,
                    ),
                  ],
                ),
                loading: () => const SkeletonBox(height: 48),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigReading(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ).animate().fade(duration: 250.ms).slide(begin: const Offset(0, 0.05));
  }

  Widget _rangeCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comfort guide',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _chip(context, 'Cool < 18C', Icons.ac_unit, theme.colorScheme.tertiary),
          _chip(context, 'Optimal 18-30C', Icons.check_circle, theme.colorScheme.primary),
          _chip(context, 'Hot > 30C', Icons.local_fire_department, theme.colorScheme.error),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
