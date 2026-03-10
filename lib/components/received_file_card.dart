import 'dart:io';

import 'package:flutter/material.dart';
import 'package:proxishare/components/received_file.dart';

class ReceivedFileCard extends StatelessWidget {
  final ReceivedFile file;

  const ReceivedFileCard({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildThumbnail(context)),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      file.formattedSize,
                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        file.ext,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (file.isImage || file.isVideo) {
      return _FileThumbnail(file: file);
    }
    return _buildDefaultIcon(context);
  }

  Widget _buildDefaultIcon(BuildContext context) {
    final color = file.isPdf
        ? Colors.red
        : file.mime.contains('zip') ||
              file.mime.contains('rar') ||
              file.mime.contains('tar')
        ? Colors.orange
        : Theme.of(context).colorScheme.primary;

    return Container(
      color: file.isPdf
          ? Colors.red.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(file.icon, size: 32, color: color),
            if (file.isPdf) ...[
              const SizedBox(height: 4),
              Text(
                'PDF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FileThumbnail extends StatefulWidget {
  final ReceivedFile file;

  const _FileThumbnail({required this.file});

  @override
  State<_FileThumbnail> createState() => _FileThumbnailState();
}

class _FileThumbnailState extends State<_FileThumbnail> {
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(widget.file.icon, size: 32, color: Colors.grey[400]),
        ),
      );
    }

    return Image.file(
      File(widget.file.path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _isError = true);
          }
        });
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: widget.file.isVideo
                ? const Icon(Icons.videocam_off, size: 32, color: Colors.grey)
                : const Icon(Icons.broken_image, size: 32, color: Colors.grey),
          ),
        );
      },
    );
  }
}
