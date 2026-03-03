import 'dart:io';
import 'dart:async';
import 'package:mime/mime.dart';
import 'package:proxishare/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';

Future<List<Map<String, dynamic>>> handleShelfFileUpload(
  Request request,
  String saveDirectory,
) async {
  final savedFiles = <Map<String, dynamic>>[];

  if (request.method != 'POST' ||
      request.headers['content-type']?.contains('multipart/form-data') !=
          true) {
    throw Exception('Only POST with multipart/form-data supported');
  }

  final tmpBase = Directory('${Directory.systemTemp.path}/proxishare_uploads');
  if (!await tmpBase.exists()) await tmpBase.create(recursive: true);

  final multipart = request.multipart();
  if (multipart == null) {
    throw Exception('Not a multipart request');
  }

  await for (final part in multipart.parts) {
    final contentDisposition = part.headers['content-disposition'];
    if (contentDisposition == null) continue;

    final filenameMatch = RegExp(
      r'filename="([^"]+)"',
    ).firstMatch(contentDisposition);
    if (filenameMatch == null) continue;
    final filename = filenameMatch.group(1)!;

    final fileBytes = await part.readBytes();
    final mimeType = lookupMimeType(filename, headerBytes: fileBytes) ?? '';

    final safeName = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final tmpFile = File('${tmpBase.path}/$safeName');
    await tmpFile.writeAsBytes(fileBytes, flush: true);

    final meta = <String, dynamic>{
      'filename': filename,
      'path': tmpFile.path,
      'mime': mimeType,
      'size': await tmpFile.length(),
    };

    savedFiles.add(meta);
    logger.debug(
      'Saved upload to temp: ${meta['path']} (${meta['size']} bytes)',
    );
  }

  return savedFiles;
}
