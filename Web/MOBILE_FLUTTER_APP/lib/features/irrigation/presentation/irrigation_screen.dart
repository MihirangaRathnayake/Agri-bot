import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/rtdb_paths.dart';
import '../../../data/providers/rtdb_providers.dart';
import '../../../data/repositories/rtdb_repository.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../../../shared/widgets/status_badge.dart';

class IrrigationScreen extends ConsumerStatefulWidget {
  const IrrigationScreen({super.key});

  @override
  ConsumerState<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends ConsumerState<IrrigationScreen> {
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    ref.listen<AsyncValue<bool?>>(pumpStatusProvider(1), (prev, next) {
      final val = next.asData?.value;
      if (val != null) _appendLog('Pump 1 ${val ? 'ON' : 'OFF'}');
    });
    ref.listen<AsyncValue<bool?>>(pumpStatusProvider(2), (prev, next) {
      final val = next.asData?.value;
      if (val != null) _appendLog('Pump 2 ${val ? 'ON' : 'OFF'}');
    });
  }

  void _appendLog(String message) {
    setState(() {
      _log.insert(0, '${DateTime.now().toLocal().toIso8601String().substring(11, 19)} • $message');
      if (_log.length > 12) _log.removeLast();
    });
  }

  Future<void> _togglePump(int index) async {
    final repo = ref.read(rtdbRepositoryProvider);
    final path = index == 1 ? RtdbPaths.pump1 : RtdbPaths.pump2;
    try {
      await repo.toggleBool(path);
      _appendLog('Toggle requested for pump $index');
    } catch (e) {
      _appendLog('Pump $index toggle failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pump1 = ref.watch(pumpStatusProvider(1));
    final pump2 = ref.watch(pumpStatusProvider(2));
    final soil1 = ref.watch(soilMoistureProvider(1));
    final soil2 = ref.watch(soilMoistureProvider(2));

    return Scaffold(
      appBar: AppBar(title: const Text('Irrigation control')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pumpStatusProvider(1));
          ref.invalidate(pumpStatusProvider(2));
          ref.invalidate(soilMoistureProvider(1));
          ref.invalidate(soilMoistureProvider(2));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              title: 'Pumps',
              subtitle: 'Two-way control mirrored with /soil/pump1 and /soil/pump2',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _pumpTile(context, 'Pump 1', pump1, () => _togglePump(1))),
                const SizedBox(width: 12),
                Expanded(child: _pumpTile(context, 'Pump 2', pump2, () => _togglePump(2))),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              title: 'Soil moisture',
              subtitle: 'Reference sensors before toggling pumps',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _moistureTile(context, 'Sensor 1', soil1)),
                const SizedBox(width: 12),
                Expanded(child: _moistureTile(context, 'Sensor 2', soil2)),
              ],
            ),
            const SizedBox(height: 16),
            DataCard(
              title: 'Recent log',
              subtitle: 'Local UI log of status updates',
              child: _log.isEmpty
                  ? const Text('No activity yet')
                  : Column(
                      children: _log
                          .map(
                            (entry) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.bolt, size: 18),
                              title: Text(entry),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pumpTile(
      BuildContext context, String title, AsyncValue<bool?> async, VoidCallback onToggle) {
    return DataCard(
      title: title,
      child: async.when(
        data: (value) {
          final isOn = value ?? false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                label: isOn ? 'ON' : 'OFF',
                color: isOn
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                icon: Icons.power_settings_new,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onToggle,
                icon: const Icon(Icons.switch_left),
                label: Text(isOn ? 'Turn OFF' : 'Turn ON'),
              ),
            ],
          );
        },
        loading: () => const SkeletonBox(height: 42),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }

  Widget _moistureTile(
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
            Text(
              value == null ? '--' : '${value.toStringAsFixed(0)}%',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: value == null ? null : (value.clamp(0, 100) / 100),
              minHeight: 10,
            ),
          ],
        ),
        loading: () => const SkeletonBox(height: 38),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}
