import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/rtdb_paths.dart';
import '../../../data/repositories/rtdb_repository.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/status_badge.dart';

class ConnectionDiagnosticsCard extends ConsumerStatefulWidget {
  const ConnectionDiagnosticsCard({super.key});

  @override
  ConsumerState<ConnectionDiagnosticsCard> createState() =>
      _ConnectionDiagnosticsCardState();
}

class _ConnectionDiagnosticsCardState
    extends ConsumerState<ConnectionDiagnosticsCard> {
  bool? _readOk;
  bool? _writeOk;
  String? _message;
  bool _running = false;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _message = null;
    });
    final repo = ref.read(rtdbRepositoryProvider);
    try {
      final readVal =
          await repo.readString(RtdbPaths.diagnosticsRead); // /light/state
      setState(() {
        _readOk = readVal != null;
      });
      await repo.writeValue(
        RtdbPaths.diagnosticsWrite,
        {'pinged_at': DateTime.now().toIso8601String()},
      );
      setState(() {
        _writeOk = true;
        _message =
            'Read ${readVal ?? 'null'} from ${RtdbPaths.diagnosticsRead} and wrote ping to ${RtdbPaths.diagnosticsWrite}';
      });
    } catch (e) {
      setState(() {
        _message = 'Diagnostics failed: $e';
        _writeOk = false;
        _readOk = false;
      });
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataCard(
      title: 'Connection diagnostics',
      subtitle: 'Reads /light/state then writes a safe ping',
      trailing: _running
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(
                label: _readOk == null
                    ? 'Read: not run'
                    : _readOk == true
                        ? 'Read: OK'
                        : 'Read: fail',
                color: _readOk == null
                    ? Theme.of(context).colorScheme.outline
                    : _readOk == true
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
              ),
              StatusBadge(
                label: _writeOk == null
                    ? 'Write: not run'
                    : _writeOk == true
                        ? 'Write: OK'
                        : 'Write: fail',
                color: _writeOk == null
                    ? Theme.of(context).colorScheme.outline
                    : _writeOk == true
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
              ),
            ],
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(
              _message!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: const Icon(Icons.health_and_safety),
            label: const Text('Run checks'),
          ),
        ],
      ),
    );
  }
}
