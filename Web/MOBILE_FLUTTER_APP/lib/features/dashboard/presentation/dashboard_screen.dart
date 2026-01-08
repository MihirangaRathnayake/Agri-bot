import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/rtdb_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/providers/rtdb_providers.dart';
import '../../../data/repositories/rtdb_repository.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/value_pill.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _togglePump(BuildContext context, WidgetRef ref, int pump) async {
    final repo = ref.read(rtdbRepositoryProvider);
    final path = pump == 1 ? RtdbPaths.pump1 : RtdbPaths.pump2;
    try {
      await repo.toggleBool(path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pump $pump toggled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pump $pump toggle failed: $e')),
      );
    }
  }

  Future<void> _toggleTank(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(rtdbRepositoryProvider);
    try {
      await repo.toggleBool(RtdbPaths.tankPump);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tank pump toggled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tank pump toggle failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temp = ref.watch(temperatureProvider);
    final humidity = ref.watch(humidityProvider);
    final soil1 = ref.watch(soilMoistureProvider(1));
    final soil2 = ref.watch(soilMoistureProvider(2));
    final pump1 = ref.watch(pumpStatusProvider(1));
    final pump2 = ref.watch(pumpStatusProvider(2));
    final tankLevel = ref.watch(tankLevelProvider);
    final tankPump = ref.watch(tankPumpProvider);
    final light = ref.watch(lightStateProvider);
    final lastMotion = ref.watch(lastMotionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri-Bot Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/chatbot'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(temperatureProvider);
          ref.invalidate(humidityProvider);
          ref.invalidate(soilMoistureProvider(1));
          ref.invalidate(soilMoistureProvider(2));
          ref.invalidate(pumpStatusProvider(1));
          ref.invalidate(pumpStatusProvider(2));
          ref.invalidate(tankLevelProvider);
          ref.invalidate(tankPumpProvider);
          ref.invalidate(lightStateProvider);
          ref.invalidate(lastMotionProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              title: 'Live status',
              subtitle: 'Real-time data mirrored from Firebase RTDB',
            ),
            const SizedBox(height: 12),
            _heroStats(context, temp, humidity, light),
            const SizedBox(height: 12),
            _quickActions(context, ref),
            const SizedBox(height: 16),
            _weatherCard(context, temp, humidity),
            const SizedBox(height: 12),
            _soilCard(context, soil1, soil2),
            const SizedBox(height: 12),
            _irrigationCard(context, ref, pump1, pump2),
            const SizedBox(height: 12),
            _tankCard(context, ref, tankLevel, tankPump),
            const SizedBox(height: 12),
            _securityCard(context, lastMotion),
          ],
        ),
      ),
    );
  }

  Widget _heroStats(
    BuildContext context,
    AsyncValue<double?> temp,
    AsyncValue<double?> humidity,
    AsyncValue<String?> light,
  ) {
    final theme = Theme.of(context);
    final humidityVal = humidity.maybeWhen(data: (v) => v, orElse: () => null);
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thermostat, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Weather', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  temp.when(
                    data: (value) => Text(
                      '${formatTemperature(value)} / ${formatNumber(humidityVal, fractionDigits: 0)}%',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    loading: () => const SkeletonBox(width: 120, height: 26),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(
                    label: 'Live',
                    color: theme.colorScheme.primary,
                    icon: Icons.wifi_tethering,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.light_mode, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text('Light', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  light.when(
                    data: (value) {
                      final isDark = value == 'DARK';
                      return Text(
                        value ?? '--',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? theme.colorScheme.secondary : theme.colorScheme.primary,
                        ),
                      );
                    },
                    loading: () => const SkeletonBox(width: 80, height: 26),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(
                    label: 'Skywatch',
                    color: theme.colorScheme.secondary,
                    icon: Icons.visibility,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _actionChip(
          context,
          icon: Icons.bolt,
          label: 'Pump 1',
          color: theme.colorScheme.primary,
          onTap: () => _togglePump(context, ref, 1),
        ),
        _actionChip(
          context,
          icon: Icons.bolt,
          label: 'Pump 2',
          color: theme.colorScheme.secondary,
          onTap: () => _togglePump(context, ref, 2),
        ),
        _actionChip(
          context,
          icon: Icons.water,
          label: 'Tank Pump',
          color: theme.colorScheme.tertiary,
          onTap: () => _toggleTank(context, ref),
        ),
        _actionChip(
          context,
          icon: Icons.chat,
          label: 'Chatbot',
          color: theme.colorScheme.surfaceTint,
          onTap: () => context.push('/chatbot'),
        ),
      ],
    );
  }

  Widget _actionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ).animate().fade(duration: 200.ms).slide(begin: const Offset(0, 0.05));
  }

  Widget _weatherCard(
    BuildContext context,
    AsyncValue<double?> temp,
    AsyncValue<double?> humidity,
  ) {
    return DataCard(
      title: 'Weather station',
      subtitle: 'From /weather in RTDB',
      child: Row(
        children: [
          Expanded(
            child: temp.when(
              data: (value) => ValuePill(
                label: 'Temperature',
                value: formatTemperature(value),
                icon: Icons.thermostat,
                color: Theme.of(context).colorScheme.primary,
              ),
              loading: () => const SkeletonBox(height: 40),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: humidity.when(
              data: (value) => ValuePill(
                label: 'Humidity',
                value: value == null ? '--' : '${value.toStringAsFixed(0)}%',
                icon: Icons.water_drop,
                color: Theme.of(context).colorScheme.secondary,
              ),
              loading: () => const SkeletonBox(height: 40),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _soilCard(
    BuildContext context,
    AsyncValue<double?> soil1,
    AsyncValue<double?> soil2,
  ) {
    Widget buildTile(String title, AsyncValue<double?> value) {
      return value.when(
        data: (val) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            ValuePill(
              label: 'Moisture',
              value: formatPercent(val),
              icon: Icons.water,
              color: _moistureColor(context, val),
            ),
          ],
        ),
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            const SkeletonBox(height: 38),
          ],
        ),
        error: (e, _) => Text('Error: $e'),
      );
    }

    return DataCard(
      title: 'Soil moisture',
      subtitle: 'Streaming /soil/sensor1_percent & /soil/sensor2_percent',
      child: Row(
        children: [
          Expanded(child: buildTile('Sensor 1', soil1)),
          const SizedBox(width: 12),
          Expanded(child: buildTile('Sensor 2', soil2)),
        ],
      ),
    );
  }

  Color _moistureColor(BuildContext context, double? value) {
    final scheme = Theme.of(context).colorScheme;
    if (value == null) return scheme.onSurfaceVariant;
    if (value < 30) return scheme.error;
    if (value < 60) return scheme.tertiary;
    return scheme.primary;
  }

  Widget _irrigationCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool?> pump1,
    AsyncValue<bool?> pump2,
  ) {
    Widget buildPump(String label, int index, AsyncValue<bool?> async) {
      return async.when(
        data: (status) {
          final isOn = status ?? false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusBadge(
                    label: isOn ? 'ON' : 'OFF',
                    color: isOn
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    icon: Icons.power_settings_new,
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _togglePump(context, ref, index),
                    icon: const Icon(Icons.switch_left),
                    label: const Text('Toggle'),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const SkeletonBox(height: 42),
        error: (e, _) => Text('Error: $e'),
      );
    }

    return DataCard(
      title: 'Irrigation pumps',
      subtitle: 'Two-way control for /soil/pump1 and /soil/pump2',
      child: Row(
        children: [
          Expanded(child: buildPump('Pump 1', 1, pump1)),
          const SizedBox(width: 12),
          Expanded(child: buildPump('Pump 2', 2, pump2)),
        ],
      ),
    );
  }

  Widget _tankCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<double?> tankLevel,
    AsyncValue<bool?> tankPump,
  ) {
    return DataCard(
      title: 'Water tank',
      subtitle: 'Level at /tank/level_percent, pump at /tank/pump',
      trailing: tankPump.when(
        data: (status) => StatusBadge(
          label: status == true ? 'PUMP ON' : 'PUMP OFF',
          icon: Icons.water,
          color:
              status == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
        ),
        loading: () => const SkeletonBox(width: 60, height: 20),
        error: (e, _) => Text('Error: $e'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tankLevel.when(
            data: (value) => LinearProgressIndicator(
              value: value == null ? null : (value.clamp(0, 100) / 100),
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_tankColor(context, value)),
            ),
            loading: () => const SkeletonBox(height: 12),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              tankLevel.when(
                data: (value) => Text(
                  value == null ? '--' : '${value.toStringAsFixed(0)}%',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                loading: () => const SkeletonBox(width: 50, height: 22),
                error: (e, _) => Text('Error: $e'),
              ),
              FilledButton.icon(
                onPressed: () => _toggleTank(context, ref),
                icon: const Icon(Icons.autorenew),
                label: const Text('Toggle pump'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _tankColor(BuildContext context, double? level) {
    final scheme = Theme.of(context).colorScheme;
    if (level == null) return scheme.primary;
    if (level < 20) return scheme.error;
    if (level < 50) return scheme.tertiary;
    return scheme.primary;
  }

  Widget _securityCard(
    BuildContext context,
    AsyncValue<String?> lastMotion,
  ) {
    return DataCard(
      title: 'Security',
      subtitle: 'Last motion at /security/last_motion_time',
      child: lastMotion.when(
        data: (value) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value ?? '--',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                StatusBadge(
                  label: value == null ? 'No motion data' : 'Monitoring',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.visibility_outlined,
                ),
              ],
            ),
            Icon(Icons.shield_moon, size: 36, color: Theme.of(context).colorScheme.secondary),
          ],
        ),
        loading: () => const SkeletonBox(height: 46),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}
