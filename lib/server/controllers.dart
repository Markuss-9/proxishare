import 'dart:io';

import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/server/error_handler.dart';
import 'package:proxishare/server/middlewares.dart';
import 'package:proxishare/server/upload.dart';

Future<String> get _localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<void> serveTestFile(HttpRequest request) async {
  final path = await _localPath;
  final file = File('$path/ProxiShare/test.txt');
  if (!await file.exists()) {
    await file.writeAsString('Hello from Flutter local server!');
  }

  await request.response
      .addStream(file.openRead())
      .whenComplete(() => request.response.close());
}

Future<void> serveUpload(HttpRequest request) async {
  final path = await _localPath;
  handleFileUpload(request, "$path/ProxiShare");
}

Future<void> serveWebui(HttpRequest request) async {
  final subPath = request.uri.path.replaceFirst('/webui', '');
  final isIndex = subPath.isEmpty;
  final assetPath = 'assets/webui${isIndex ? '/index.html' : subPath}';

  logger.debug("_serveWebui Trying to load assetPath $assetPath");

  try {
    // Load file bytes from Flutter asset bundle
    final Uint8List data = await rootBundle
        .load(assetPath)
        .then((bd) => bd.buffer.asUint8List());

    // Guess MIME type from file extension
    final mimeType = lookupMimeType(assetPath) ?? 'application/octet-stream';
    logger.debug("serveWebui mimeType $mimeType");
    request.response.headers.contentType = ContentType.parse(mimeType);
    if (!isIndex) {
      // 1 month, files are hashed
      Middlewares.addCacheControl(request, maxAge: 30 * 24 * 60 * 60);
    }

    // Write response
    request.response.add(data);
    await request.response.close();
  } catch (e) {
    logger.error("_serveWebui asset $assetPath gave error ${e.toString()}");
    sendError(request, HttpStatus.notFound, 'Asset not found: $assetPath');
  }
}
