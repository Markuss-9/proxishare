import 'dart:io' show HttpRequest;

import 'package:proxishare/server/controllers.dart';

typedef RouteHandler = Future<void> Function(HttpRequest request);

typedef RoutesType = Map<String, RouteHandler>;

class Router {
  final RoutesType routes = {
    '/test.txt': serveTestFile,
    '/upload/media': serveUploadMedia,
    '/upload/files': serveUploadFiles,
    '/webui': serveWebui,
  };
  void addRoute(String path, Future<void> Function(HttpRequest) handler) {
    routes[path] = handler;
  }
}
