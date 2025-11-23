import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:proxishare/server/events.dart';
import 'package:proxishare/components/toast.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/services/notifications/notification_service.dart';

Future<void> showUploadDialog(
  BuildContext context,
  List<UploadedFile> files,
) async {
  if (!context.mounted) return;

  final fileNames = files.map((f) => f.filename);

  await NotificationService.showNewMediaReceived(fileNames)
      .then((_) {
        logger.info('Notification shown for uploaded files');
      })
      .catchError((e) {
        logger.error('Failed to show notification', error: e);
      });

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New upload received'),
      content: Text('Files: ${fileNames.join(', ')}'),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await _saveToGallery(context, files);
          },
          child: const Text('Save to gallery'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await _saveToFolder(context, files);
          },
          child: const Text('Save to folder'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

Future<void> _saveToGallery(
  BuildContext context,
  List<UploadedFile> files,
) async {
  try {
    for (final f in files) {
      final path = f.path;
      final mime = f.mime;
      if (mime.startsWith('image/')) {
        await Gal.putImage(path);
      } else if (mime.startsWith('video/')) {
        await Gal.putVideo(path);
      } else {
        try {
          await Gal.putImage(path);
        } catch (_) {}
      }
      try {
        final tmp = File(path);
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
    }
    showToast(context, 'Saved ${files.length} file(s) to gallery');
  } catch (e) {
    logger.error('Saving to gallery failed: $e');
    showToast(context, 'Failed to save to gallery: $e');
  }
}

Future<void> _saveToFolder(
  BuildContext context,
  List<UploadedFile> files,
) async {
  try {
    final targetDir = await FilePicker.platform.getDirectoryPath();
    if (targetDir == null) {
      showToast(context, 'Folder selection cancelled');
      return;
    }

    for (final f in files) {
      final src = f.path;
      final filename = f.filename;
      final dest = File('$targetDir${Platform.pathSeparator}$filename');
      await File(src).copy(dest.path);
      try {
        final tmp = File(src);
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
    }

    showToast(context, 'Saved ${files.length} file(s) to $targetDir');
  } catch (e) {
    logger.error('Saving to folder failed: $e');
    showToast(context, 'Failed to save to folder: $e');
  }
}
