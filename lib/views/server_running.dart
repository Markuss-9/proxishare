import 'package:flutter/material.dart';
import 'package:proxishare/components/server_qr_widget.dart';
import 'package:proxishare/components/start_stop_button.dart';
import 'package:proxishare/components/received_file.dart';
import 'package:proxishare/components/received_files_grid.dart';

class ServerRunning extends StatelessWidget {
  final String url;
  final VoidCallback onStopServer;
  final List<ReceivedFile> files;
  final VoidCallback onClearFiles;

  const ServerRunning({
    super.key,
    required this.url,
    required this.onStopServer,
    required this.files,
    required this.onClearFiles,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ServerQrWidget(url: url, imageAsset: 'assets/cervino.png'),
          const SizedBox(height: 16),
          Center(
            child: StartStopButton(
              isServerRunning: true,
              onPressed: onStopServer,
            ),
          ),
          const SizedBox(height: 32),
          ReceivedFilesGrid(files: files, onClear: onClearFiles),
        ],
      ),
    );
  }
}
