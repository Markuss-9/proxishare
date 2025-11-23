import 'package:flutter/foundation.dart';

enum ServerEventType { upload }

/// Simple typed model representing an uploaded file.
class UploadedFile {
  final String filename;
  final String path;
  final String mime;
  final int size;

  UploadedFile({
    required this.filename,
    required this.path,
    required this.mime,
    required this.size,
  });

  factory UploadedFile.fromMap(Map<String, dynamic> m) => UploadedFile(
    filename: m['filename'] as String,
    path: m['path'] as String,
    mime: m['mime'] as String? ?? '',
    size: (m['size'] as num).toInt(),
  );

  Map<String, dynamic> toMap() => {
    'filename': filename,
    'path': path,
    'mime': mime,
    'size': size,
  };
}

/// Base class for server events.
@immutable
abstract class ServerEvent {
  final ServerEventType type;
  const ServerEvent(this.type);
}

class UploadEvent extends ServerEvent {
  final List<UploadedFile> files;
  const UploadEvent(this.files) : super(ServerEventType.upload);
}
