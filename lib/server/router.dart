import 'package:proxishare/server/middlewares.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:proxishare/server/controllers.dart';

final router = Router()
  ..get('/test.txt', serveTestFile)
  ..post('/upload/media', serveUploadMedia)
  ..post('/upload/files', serveUploadFiles)
  ..get('/webui', serveWebui)
  ..get(
    '/webui/<path|.*>',
    Pipeline()
        .addMiddleware(Middlewares.addCacheControl(maxAge: 2592000))
        .addHandler(serveWebui),
  );
