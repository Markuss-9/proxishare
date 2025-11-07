import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'dart:developer' as dev;

Future<void> _serveHome(HttpRequest request) async {
  // TODO: built application like react?
  final file = File("lib/server/index.html");
  dev.log("file ${file.absolute}");
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
  final file = File('$path/test.txt');
  if (!await file.exists()) {
    await file.writeAsString('Hello from Flutter local server!');
  }

  await request.response
      .addStream(file.openRead())
      .whenComplete(() => request.response.close());
}

class Router {
  final routes = <String, Future<void> Function(HttpRequest)>{
    '/': _serveHome,
    '/index.html': _serveHome,
    '/test.txt': _serveTestFile,
  };

  void addRoute(String path, Future<void> Function(HttpRequest) handler) {
    routes[path] = handler;
  }
}
