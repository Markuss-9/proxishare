import 'dart:io';

void handleCors(HttpRequest request) {
  request.response.headers
    ..add('Access-Control-Allow-Origin', '*')
    ..add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    ..add('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept');
}

 // if (request.method == 'OPTIONS') {
 //      request.response.statusCode = HttpStatus.noContent;
 //      await request.response.close();
 //      continue;
 //    }


// so that only frontend can access those apis
// request.response.headers.add('Access-Control-Allow-Origin', 'http://localhost:3000');
