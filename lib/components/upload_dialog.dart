import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:proxishare/server/events.dart';
import 'package:proxishare/components/toast.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/services/notifications/notification_service.dart';
import 'package:proxishare/server/upload_settings.dart';

Future<void> showFilesUploadDialog(
  BuildContext context,
  List<UploadedFile> files,
) async {
  if (!context.mounted) return;

  final settings = await UploadSettings.init();
  final alwaysAsk = settings.alwaysAskSaveLocation;
  final filesDest = settings.filesDestination;

  final shouldAlwaysAsk =
      alwaysAsk || filesDest == UploadSettings.askEveryTimePath;

  if (!shouldAlwaysAsk) {
    final fileNames = files.map((f) => f.filename);

    await NotificationService.showNewMediaReceived(fileNames)
        .then((_) {
          logger.info('Notification shown for uploaded files');
        })
        .catchError((e) {
          logger.error('Failed to show notification', error: e);
        });

    if (!context.mounted) return;

    final defaultFolder = await settings.getFilesDestinationWithDefault();

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New files received'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Files: ${fileNames.join(', ')}'),
            const SizedBox(height: 8),
            Text(
              'Default: $defaultFolder',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final customPath = await FilePicker.platform.getDirectoryPath(
                dialogTitle: 'Select folder',
              );
              if (customPath != null && context.mounted) {
                await _saveMediaToFolder(context, files, customPath);
              }
            },
            child: const Text('Choose folder'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _saveMediaToFolder(context, files, defaultFolder);
            },
            child: const Text('Save to default'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  } else {
    if (!context.mounted) return;
    await _showSaveOptionsDialog(context, files);
  }
}

Future<void> _showSaveOptionsDialog(
  BuildContext context,
  List<UploadedFile> files,
) async {
  final fileNames = files.map((f) => f.filename);

  await NotificationService.showNewMediaReceived(fileNames)
      .then((_) {
        logger.info('Notification shown for uploaded files');
      })
      .catchError((e) {
        logger.error('Failed to show notification', error: e);
      });

  final settings = await UploadSettings.init();
  final defaultFolder = await settings.getFilesDestinationWithDefault();

  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Where would you like to save?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Files: ${fileNames.join(', ')}')],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            final customPath = await FilePicker.platform.getDirectoryPath(
              dialogTitle: 'Select folder',
            );
            if (customPath != null && context.mounted) {
              await _saveMediaToFolder(context, files, customPath);
            }
          },
          child: const Text('Choose folder'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await _saveMediaToFolder(context, files, defaultFolder);
          },
          child: const Text('Save to default'),
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
    if (!context.mounted) return;
    showToast(context, 'Saved ${files.length} file(s) to gallery');
  } catch (e) {
    logger.error('Saving to gallery failed: $e');
    if (!context.mounted) return;
    showToast(context, 'Failed to save to gallery: $e');
  }
}

Future<void> showMediaUploadDialog(
  BuildContext context,
  List<UploadedFile> files,
) async {
  final settings = await UploadSettings.init();

  bool hasGalleryAccess = false;
  try {
    hasGalleryAccess = await Gal.hasAccess(toAlbum: false);
  } catch (e) {
    logger.debug('Gallery access check failed (platform not supported): $e');
  }

  final folderDestination = await settings.getFilesDestinationWithDefault();

  final fileNames = files.map((f) => f.filename);

  await NotificationService.showNewMediaReceived(fileNames)
      .then((_) {
        logger.info('Notification shown for uploaded files');
      })
      .catchError((e) {
        logger.error('Failed to show notification', error: e);
      });

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New media received'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Files: ${fileNames.join(', ')}'),
          const SizedBox(height: 8),
          if (hasGalleryAccess)
            Text(
              'Save to gallery or folder?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Text(
              'Saved to: $folderDestination',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [
        if (hasGalleryAccess) ...[
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
              final customPath = await FilePicker.platform.getDirectoryPath(
                dialogTitle: 'Select folder',
              );
              if (customPath != null && context.mounted) {
                await _saveMediaToFolder(context, files, customPath);
              }
            },
            child: const Text('Save to folder'),
          ),
        ] else ...[
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final customPath = await FilePicker.platform.getDirectoryPath(
                dialogTitle: 'Select folder',
              );
              if (customPath != null && context.mounted) {
                await _saveMediaToFolder(context, files, customPath);
              }
            },
            child: const Text('Save to folder'),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _saveMediaToFolder(
  BuildContext context,
  List<UploadedFile> files,
  String folderDestination,
) async {
  try {
    final targetDir = folderDestination;
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
    if (!context.mounted) return;
    showToast(context, 'Saved ${files.length} file(s) to $targetDir');
  } catch (e) {
    logger.error('Saving to folder failed: $e');
    if (!context.mounted) return;
    showToast(context, 'Failed to save to folder: $e');
  }
}
