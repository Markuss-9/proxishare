import 'dart:io';

void sendError(HttpRequest request, int statusCode, String message) {
  request.response
    ..statusCode = statusCode
    ..headers.contentType = ContentType.html
    ..write('<h2>Error $statusCode</h2><p>$message</p>')
    ..close();
}

void sendJsonError(HttpRequest request, int statusCode, Error error) {
  request.response
    ..statusCode = statusCode
    ..headers.contentType = ContentType.json
    ..write({"error": error.toString()})
    ..close();
}
