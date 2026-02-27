import 'package:shelf/shelf.dart';
import 'package:proxishare/logger.dart';

abstract class Middlewares {
  static Middleware handleCorsShelf() {
    return createMiddleware(
      requestHandler: (Request request) {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        return null;
      },
      responseHandler: (Response response) {
        return response.change(headers: _corsHeaders);
      },
    );
  }

  static Middleware addCacheControl({required int maxAge}) {
    return createMiddleware(
      responseHandler: (Response response) {
        return response.change(
          headers: {'Cache-Control': 'public, max-age=$maxAge, immutable'},
        );
      },
    );
  }

  static Middleware handleErrors() {
    return createMiddleware(
      errorHandler: (Object error, StackTrace stackTrace) {
        logger.error(
          'Unhandled error: $error',
          error: error,
          stackTrace: stackTrace,
        );
        return Response.internalServerError(
          body: '{"error": "Internal server error"}',
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  static Middleware handleNotFound() {
    return createMiddleware(
      requestHandler: (Request request) {
        if (request.method == 'OPTIONS') {
          return null;
        }
        return null;
      },
    );
  }

  static const _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
  };
}
