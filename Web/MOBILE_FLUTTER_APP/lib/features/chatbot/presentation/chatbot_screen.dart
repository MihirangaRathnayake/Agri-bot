import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/rtdb_providers.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'Hi! I am Agri-Bot Assistant. Ask me about pumps, soil moisture, weather, or run "diagnostics" to check connectivity.',
      isBot: true,
    ),
  ];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isBot: false));
    });
    _controller.clear();
    _reply(text.trim());
  }

  void _reply(String input) {
    final lower = input.toLowerCase();
    String response = 'I can help with irrigation, sensors, weather, and diagnostics.';

    if (lower.contains('pump')) {
      response =
          'Pump control uses /soil/pump1 and /soil/pump2. Toggle them from the Irrigation screen for real-time writes.';
    } else if (lower.contains('soil') || lower.contains('moisture')) {
      response = 'Soil sensors live at /soil/sensor1_percent and /soil/sensor2_percent.';
    } else if (lower.contains('weather') || lower.contains('temp')) {
      response = 'Weather data streams from /weather/temperature and /weather/humidity.';
    } else if (lower.contains('diagnostic')) {
      response = 'Open Settings -> Connection diagnostics to read /light/state and write a test ping.';
    } else if (lower.contains('status')) {
      response = _sensorSnapshot();
    }

    setState(() {
      _messages.add(_ChatMessage(text: response, isBot: true));
    });
  }

  String _sensorSnapshot() {
    final soil1 = ref.read(soilMoistureProvider(1)).value;
    final soil2 = ref.read(soilMoistureProvider(2)).value;
    final temp = ref.read(temperatureProvider).value;
    final hum = ref.read(humidityProvider).value;
    return 'Live snapshot:\n'
        '- Soil 1: ${soil1?.toStringAsFixed(0) ?? '--'}%\n'
        '- Soil 2: ${soil2?.toStringAsFixed(0) ?? '--'}%\n'
        '- Temp: ${temp?.toStringAsFixed(1) ?? '--'} degC\n'
        '- Humidity: ${hum?.toStringAsFixed(0) ?? '--'}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agri-Bot Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final alignment =
                    msg.isBot ? Alignment.centerLeft : Alignment.centerRight;
                final color = msg.isBot
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primary;
                final textColor =
                    msg.isBot ? Theme.of(context).colorScheme.onSurface : Colors.white;
                return Align(
                  alignment: alignment,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about sensors or controls...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _sendMessage(_controller.text),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.isBot});

  final String text;
  final bool isBot;
}
