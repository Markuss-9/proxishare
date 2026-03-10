import 'package:flutter/material.dart';

class ReceivedFile {
  final String filename;
  final String path;
  final String mime;
  final int size;
  final bool isMedia;

  ReceivedFile({
    required this.filename,
    required this.path,
    required this.mime,
    required this.size,
    required this.isMedia,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isImage => mime.startsWith('image/');
  bool get isVideo => mime.startsWith('video/');
  bool get isPdf => mime.contains('pdf');

  String get ext => filename.split('.').last.toUpperCase();

  IconData get icon {
    if (isImage) return Icons.image;
    if (isVideo) return Icons.video_file;
    if (mime.startsWith('audio/')) return Icons.audio_file;
    if (isPdf) return Icons.picture_as_pdf;
    if (mime.contains('zip') || mime.contains('rar') || mime.contains('tar')) {
      return Icons.folder_zip;
    }
    if (mime.contains('word') || mime.contains('document')) {
      return Icons.description;
    }
    if (mime.contains('excel') || mime.contains('spreadsheet')) {
      return Icons.table_chart;
    }
    if (mime.contains('powerpoint') || mime.contains('presentation')) {
      return Icons.slideshow;
    }
    return Icons.insert_drive_file;
  }
}
