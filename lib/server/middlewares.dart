import 'dart:io' show HttpRequest;

abstract class Middlewares {
  static void handleCors(HttpRequest request) {
    request.response.headers
      ..add('Access-Control-Allow-Origin', '*')
      ..add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..add('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept');
  }

  static void addCacheControl(HttpRequest request, {required maxAge}) {
    request.response.headers.add(
      'Cache-Control',
      'public, max-age=$maxAge, immutable',
    );
  }
}


 // if (request.method == 'OPTIONS') {
 //      request.response.statusCode = HttpStatus.noContent;
 //      await request.response.close();
 //      continue;
 //    }


// so that only frontend can access those apis
// request.response.headers.add('Access-Control-Allow-Origin', 'http://localhost:3000');
