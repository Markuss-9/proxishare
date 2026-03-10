import 'package:flutter/material.dart';

import 'package:proxishare/components/port_selector_widget.dart';
import 'package:proxishare/components/server_qr_widget.dart';
import 'package:proxishare/components/action_buttons_widget.dart';
import 'package:proxishare/components/start_stop_button.dart';
import 'package:proxishare/server/local_server.dart';
import 'package:proxishare/server/events.dart';
import 'package:proxishare/components/upload_dialog.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/server/upload_settings.dart';

class LocalShareApp extends StatefulWidget {
  const LocalShareApp({super.key});
  @override
  State<LocalShareApp> createState() => LocalShareAppState();
}

class LocalShareAppState extends State<LocalShareApp> {
  LocalServer? server;

  final TextEditingController portController = TextEditingController();

  @override
  void initState() {
    UploadSettings.init();
    super.initState();
  }

  void handleServerEvents(event) {
    logger.info("SERVER EVENT: $event");
    if (event is UploadMediaEvent) {
      showMediaUploadDialog(context, event.files);
    } else if (event is UploadFilesEvent) {
      showFilesUploadDialog(context, event.files);
    } else {
      logger.warn("Unhandled server event: $event");
    }
  }

  Future<void> startServer({int? port}) async {
    try {
      LocalServer s = LocalServer(port: port);

      await s.getBestIPAddress();

      await s.start();
      setState(() {
        server = s;
      });

      s.events.listen(handleServerEvents);
    } catch (e, st) {
      logger.error('Failed to start server: $e', error: e, stackTrace: st);
    }
  }

  void stopServer() {
    server?.stop();
    setState(() {
      server = null;
      portController.clear();
    });
  }

  Future<void> handleStartPressed() async {
    final text = portController.text;
    final port = (text.isEmpty) ? null : int.tryParse(text);
    await startServer(port: (port != null && port > 0) ? port : null);
  }

  @override
  Widget build(BuildContext context) {
    if (server == null) {
      return _buildServerNotRunning();
    }

    if (server!.loading) {
      return const CircularProgressIndicator();
    }

    return _buildServerRunning();
  }

  Widget _buildServerNotRunning() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PortSelectorWidget(portController: portController),
        const SizedBox(height: 24),
        StartStopButton(isServerRunning: false, onPressed: handleStartPressed),
        const SizedBox(height: 8),
        const ActionButtonsWidget(showUploadSettings: true),
      ],
    );
  }

  Widget _buildServerRunning() {
    final url = server!.url!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ServerQrWidget(url: url, imageAsset: 'assets/cervino.png'),
        const SizedBox(height: 50),
        StartStopButton(isServerRunning: true, onPressed: stopServer),
        const ActionButtonsWidget(showUploadSettings: false),
      ],
    );
  }

  @override
  void dispose() {
    server?.stop();
    portController.dispose();
    super.dispose();
  }
}
