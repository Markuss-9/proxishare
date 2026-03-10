import 'package:flutter/material.dart';
import 'package:proxishare/components/port_selector_widget.dart';
import 'package:proxishare/components/start_stop_button.dart';

class ServerNotRunning extends StatelessWidget {
  final TextEditingController portController;
  final VoidCallback onStartPressed;
  final VoidCallback onExportLogs;

  const ServerNotRunning({
    super.key,
    required this.portController,
    required this.onStartPressed,
    required this.onExportLogs,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.wifi_tethering_off,
                size: 80,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Start Sharing',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Start the server to begin receiving files',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PortSelectorWidget(portController: portController),
              const SizedBox(height: 24),
              StartStopButton(
                isServerRunning: false,
                onPressed: onStartPressed,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: onExportLogs,
                icon: const Icon(Icons.description_outlined),
                label: const Text('Export logs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
