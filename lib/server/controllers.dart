import 'dart:io';

import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/server/upload.dart';
import 'package:proxishare/server/local_server.dart';
import 'package:proxishare/server/events.dart';
import 'package:shelf/shelf.dart';

Future<String> get _localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
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

Future<Response> serveUploadMedia(Request request) async {
  final path = await _localPath;
  try {
    final saved = await handleShelfFileUpload(request, "$path/ProxiShare");
    if (saved.isNotEmpty) {
      final files = saved.map((m) => UploadedFile.fromMap(m)).toList();
      LocalServer.current?.notifyEvent(UploadMediaEvent(files));
    }
    return Response.ok('Uploaded ${saved.length} file(s)');
  } catch (e, st) {
    logger.error('serveUploadMedia failed: $e\n$st');
    return Response.internalServerError(body: 'Upload failed: $e');
  }
}

Future<Response> serveUploadFiles(Request request) async {
  final path = await _localPath;
  try {
    final saved = await handleShelfFileUpload(request, "$path/ProxiShare");
    if (saved.isNotEmpty) {
      final files = saved.map((m) => UploadedFile.fromMap(m)).toList();
      LocalServer.current?.notifyEvent(UploadFilesEvent(files));
    }
    return Response.ok('Uploaded ${saved.length} file(s)');
  } catch (e, st) {
    logger.error('serveUploadFiles failed: $e\n$st');
    return Response.internalServerError(body: 'Upload failed: $e');
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
