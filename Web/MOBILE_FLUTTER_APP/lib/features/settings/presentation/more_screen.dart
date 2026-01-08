import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../widgets/connection_diagnostics_card.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Utilities',
            subtitle: 'Chatbot, settings, and diagnostics',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DataCard(
                  title: 'Chatbot',
                  subtitle: 'Agriculture helper',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/chatbot'),
                  child: const StatusBadge(
                    label: 'Open chat',
                    icon: Icons.chat_bubble_outline,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DataCard(
                  title: 'Settings',
                  subtitle: 'Theme & diagnostics',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings'),
                  child: const StatusBadge(
                    label: 'Configure',
                    icon: Icons.tune,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ConnectionDiagnosticsCard(),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Contact & About',
            subtitle: 'From the web Contact/About sections',
          ),
          const SizedBox(height: 12),
          DataCard(
            title: 'Contact team',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  dense: true,
                  leading: Icon(Icons.mail_outline),
                  title: Text('agribot.team@nibm.lk'),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.phone),
                  title: Text('+94 71 108 8627'),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.location_on_outlined),
                  title: Text('No:2, Asgiri Vihara Mawatha, Kandy, Sri Lanka'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DataCard(
            title: 'About Agri-Bot',
            child: const Text(
              'Agri-Bot is a smart farming dashboard with real-time soil, weather, irrigation, '
              'camera, and security monitoring powered by Firebase Realtime Database.',
            ),
          ),
        ],
      ),
    );
  }
}
