import 'package:shelf_router/shelf_router.dart';
import 'package:proxishare/server/controllers.dart';

final router = Router()
  ..get('/test.txt', serveTestFile)
  ..post('/upload/media', serveUploadMedia)
  ..post('/upload/files', serveUploadFiles)
  ..get('/webui', serveWebui)
  ..get('/webui/<path|.*>', serveWebui);
