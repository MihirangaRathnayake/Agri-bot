import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/rtdb_providers.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../../../shared/widgets/status_badge.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastMotion = ref.watch(lastMotionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(lastMotionProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              title: 'Motion detection',
              subtitle: 'From /security/last_motion_time',
            ),
            const SizedBox(height: 12),
            DataCard(
              title: 'Last motion',
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
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        StatusBadge(
                          label: value == null ? 'Idle' : 'Activity',
                          color: value == null
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.error,
                          icon: Icons.visibility,
                        ),
                      ],
                    ),
                    Icon(Icons.shield, size: 42, color: Theme.of(context).colorScheme.secondary),
                  ],
                ),
                loading: () => const SkeletonBox(height: 40),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
            const SizedBox(height: 16),
            _tipsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _tipsCard(BuildContext context) {
    final tips = [
      'Keep sensors powered and online.',
      'Use Firebase alerts to push notifications when motion is detected.',
      'Mount the camera feed (ESP32-CAM) with stable Wi-Fi.',
    ];
    return DataCard(
      title: 'Operational tips',
      child: Column(
        children: tips
            .map(
              (tip) => ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle_outline, size: 18),
                title: Text(tip),
              ),
            )
            .toList(),
      ),
    );
  }
}
