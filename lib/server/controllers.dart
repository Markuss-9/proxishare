import 'dart:io';

import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/server/upload.dart';
import 'package:proxishare/server/local_server.dart';
import 'package:proxishare/server/events.dart';
import 'package:proxishare/server/upload_settings.dart';
import 'package:shelf/shelf.dart';

Future<String> get _localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

bool _isImageOrVideo(String mime) {
  return mime.startsWith('image/') || mime.startsWith('video/');
}

Future<Response> serveTestFile(Request request) async {
  final path = await _localPath;
  final file = File('$path/ProxiShare/test.txt');
  if (!await file.exists()) {
    await file.writeAsString('Hello from Flutter local server!');
  }

  final bytes = await file.readAsBytes();
  return Response.ok(bytes);
}

Future<Response> serveUpload(Request request) async {
  final settings = UploadSettings.instance;

  try {
    final saved = await handleShelfFileUpload(request, '');
    if (saved.isEmpty) {
      return Response.ok('No files uploaded');
    }

    final files = saved.map((m) => UploadedFile.fromMap(m)).toList();
    final hasMedia = files.any((f) => _isImageOrVideo(f.mime));

    final saveDir = await settings.getFilesDestinationWithDefault();
    final alwaysAsk = settings.alwaysAskSaveLocation;

    logger.debug("saveDir $saveDir - alwaysAsk $alwaysAsk");

    if (hasMedia) {
      final mediaFiles = files.where((f) => _isImageOrVideo(f.mime)).toList();
      final otherFiles = files.where((f) => !_isImageOrVideo(f.mime)).toList();

      await _moveFiles(mediaFiles, saveDir);
      if (alwaysAsk) {
        LocalServer.current?.notifyEvent(UploadMediaEvent(mediaFiles));
      }

      if (otherFiles.isNotEmpty) {
        await _moveFiles(otherFiles, saveDir);
        if (alwaysAsk) {
          LocalServer.current?.notifyEvent(UploadFilesEvent(otherFiles));
        }
      }
    } else {
      await _moveFiles(files, saveDir);
      if (alwaysAsk) {
        LocalServer.current?.notifyEvent(UploadFilesEvent(files));
      }
    }

    return Response.ok('Uploaded ${saved.length} file(s)');
  } catch (e, st) {
    logger.error('serveUpload failed: $e\n$st');
    return Response.internalServerError(body: 'Upload failed: $e');
  }
}

Future<void> _moveFiles(List<UploadedFile> files, String saveDir) async {
  final dir = Directory(saveDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  for (final file in files) {
    final tmpFile = File(file.path);
    final destPath = '$saveDir/${file.filename}';
    final destFile = File(destPath);
    await tmpFile.copy(destFile.path);
    await tmpFile.delete();
    file.path = destPath;
  }
}

Future<Response> serveWebui(Request request) async {
  final uriPath = request.url.path;
  final isIndex = uriPath.isEmpty || uriPath == 'webui';
  final assetPath = isIndex
      ? 'assets/webui/index.html'
      : 'assets/webui/${uriPath.replaceFirst('webui/', '')}';

  logger.debug("serveWebui Trying to load assetPath $assetPath");

  try {
    final Uint8List data = await rootBundle
        .load(assetPath)
        .then((bd) => bd.buffer.asUint8List());

    logger.debug("serveWebui lookupMimeType for assetPath $assetPath");
    final mimeType = lookupMimeType(assetPath) ?? 'application/octet-stream';
    logger.debug("serveWebui mimeType $mimeType");

    return Response.ok(data, headers: {'Content-Type': mimeType});
  } catch (e) {
    logger.error("serveWebui asset $assetPath gave error ${e.toString()}");
    return Response.notFound('Asset not found: $assetPath');
  }
}
