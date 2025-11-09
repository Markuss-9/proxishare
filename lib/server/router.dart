import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:proxishare/logger.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:proxishare/server/error_handler.dart';
import 'package:proxishare/server/upload.dart';

Future<void> _serveHome(HttpRequest request) async {
  final file = File("webui/index.html");
  // final file = File("lib/server/index.html");
  logger.debug("file ${file.absolute}");
  if (!await file.exists()) {
    throw Error();
  }
  final html = await file.readAsString();

  request.response
    ..headers.contentType = ContentType.html
    ..write(html)
    ..close();
}

Future<String> get _localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<void> _serveTestFile(HttpRequest request) async {
  final path = await _localPath;
  // NOTE: attention this is created on ~/Documents directory
  final file = File('$path/ProxiShare/test.txt');
  if (!await file.exists()) {
    await file.writeAsString('Hello from Flutter local server!');
  }

  await request.response
      .addStream(file.openRead())
      .whenComplete(() => request.response.close());
}

Future<void> _serveUpload(HttpRequest request) async {
  final path = await _localPath;
  handleFileUpload(request, "$path/ProxiShare");
}

ContentType getContentType(String path) {
  if (path.endsWith('.html')) return ContentType.html;
  if (path.endsWith('.js')) return ContentType('application', 'javascript');
  if (path.endsWith('.css')) return ContentType('text', 'css');
  if (path.endsWith('.svg')) return ContentType('image', 'svg+xml');
  if (path.endsWith('.json')) return ContentType.json;
  return ContentType.binary;
}

Future<void> _serveWebui(HttpRequest request) async {
  final subPath = request.uri.path.replaceFirst('/webui', '');
  final filePath = 'assets/webui${subPath.isEmpty ? '/index.html' : subPath}';

  logger.debug("_serveWebui Trying to load filePath $filePath");

  try {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Error();
    }

    request.response.headers.contentType = getContentType(filePath);
    await request.response.addStream(file.openRead());
    await request.response.close();
  } catch (e) {
    logger.error("_serveWebui file $filePath gave error ${e.toString()}");
    sendError(request, HttpStatus.notFound, 'File not found: $filePath');
  }
}

typedef RouteHandler = Future<void> Function(HttpRequest request);

typedef RoutesType = Map<String, RouteHandler>;

class Router {
  final RoutesType routes = {
    '/': _serveHome,
    '/index.html': _serveHome,
    '/test.txt': _serveTestFile,
    '/upload': _serveUpload,
    '/webui': _serveWebui,
  };
  void addRoute(String path, Future<void> Function(HttpRequest) handler) {
    routes[path] = handler;
  }
}
