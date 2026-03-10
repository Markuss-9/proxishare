import 'package:flutter/material.dart';

import 'toast.dart';
import 'upload_settings_widget.dart';
import 'package:proxishare/logger.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool showUploadSettings;
  final bool isLoading;

  const ActionButtonsWidget({
    super.key,
    this.showUploadSettings = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () async {
            final ctx = context;
            final path = await LogService.exportLogs();
            final message = path != null
                ? 'Logs exported to:\n$path'
                : 'Failed to export logs. Check storage permissions.';
            if (!ctx.mounted) return;
            showToast(ctx, message);
          },
          child: const Text('Export logs'),
        ),
        if (showUploadSettings) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const UploadSettingsWidget(),
              );
            },
            child: const Text('Upload Settings'),
          ),
        ],
      ],
    );
  }
}
