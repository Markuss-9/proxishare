import 'package:flutter/material.dart';

import 'package:proxishare/logger.dart';

import 'package:proxishare/views/server_not_running.dart';
import 'package:proxishare/views/server_running.dart';

import 'package:proxishare/components/received_file.dart';
import 'package:proxishare/components/upload_settings_widget.dart';
import 'package:proxishare/components/upload_dialog.dart';

import 'package:proxishare/server/upload_settings.dart';
import 'package:proxishare/server/local_server.dart';
import 'package:proxishare/server/events.dart';

class LocalShareApp extends StatefulWidget {
  const LocalShareApp({super.key});
  @override
  State<LocalShareApp> createState() => LocalShareAppState();
}

class LocalShareAppState extends State<LocalShareApp> {
  LocalServer? server;
  final TextEditingController portController = TextEditingController();
  final List<ReceivedFile> _sessionFiles = [];

  @override
  void initState() {
    UploadSettings.init();
    super.initState();
  }

  void _handleServerEvents(event) {
    logger.info("SERVER EVENT: $event");
    if (event is UploadMediaEvent) {
      _addReceivedFiles(event.files, isMedia: true);
      showMediaUploadDialog(context, event.files);
    } else if (event is UploadFilesEvent) {
      _addReceivedFiles(event.files, isMedia: false);
      showFilesUploadDialog(context, event.files);
    } else {
      logger.warn("Unhandled server event: $event");
    }
  }

  void _addReceivedFiles(List<UploadedFile> files, {required bool isMedia}) {
    setState(() {
      for (final file in files) {
        _sessionFiles.add(
          ReceivedFile(
            filename: file.filename,
            path: file.path,
            mime: file.mime,
            size: file.size,
            isMedia: isMedia,
          ),
        );
      }
    });
  }

  Future<void> _startServer({int? port}) async {
    try {
      LocalServer s = LocalServer(port: port);
      await s.getBestIPAddress();
      await s.start();
      setState(() {
        server = s;
        _sessionFiles.clear();
      });
      s.events.listen(_handleServerEvents);
    } catch (e, st) {
      logger.error('Failed to start server: $e', error: e, stackTrace: st);
    }
  }

  void _stopServer() {
    server?.stop();
    setState(() {
      server = null;
      portController.clear();
    });
  }

  Future<void> _handleStartPressed() async {
    final text = portController.text;
    final port = (text.isEmpty) ? null : int.tryParse(text);
    await _startServer(port: (port != null && port > 0) ? port : null);
  }

  void _clearSessionFiles() {
    setState(() {
      _sessionFiles.clear();
    });
  }

  void _showUploadSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Expanded(child: UploadSettingsWidget()),
          ],
        ),
      ),
    );
  }

  void _exportLogs() async {
    final path = await LogService.exportLogs();
    final message = path != null
        ? 'Logs exported to:\n$path'
        : 'Failed to export logs. Check storage permissions.';
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProxiShare'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showUploadSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Upload Settings',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (server == null) {
      return ServerNotRunning(
        portController: portController,
        onStartPressed: _handleStartPressed,
        onExportLogs: _exportLogs,
      );
    }

    if (server!.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ServerRunning(
      url: server!.url!,
      onStopServer: _stopServer,
      files: _sessionFiles,
      onClearFiles: _clearSessionFiles,
    );
  }

  @override
  void dispose() {
    server?.stop();
    portController.dispose();
    super.dispose();
  }
}
