import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/server/error_handler.dart';

import 'package:proxishare/server/router.dart';

class LocalServer {
  final int port;
  HttpServer? _server;
  String? ipAddress;
  String? url;

  LocalServer({required this.port});

  Router router = Router();

  Future<void> start() async {
    logger.info('Starting local server...');

    ipAddress = await _getBestIPAddress();
    logger.info('Server IP: $ipAddress');

    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);

    url = "http://$ipAddress:$port";
    logger.info('Server running on $url');

    _server!.listen(_handleRequest);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    logger.info('Server stopped.');
  }

  Future<void> _handleRequest(HttpRequest request) async {
    logger.trace('Request: ${request.method} ${request.uri.path}');

    var handler = router.routes[request.uri.path];

    // If no exact match, check for prefix-based route
    if (handler == null) {
      for (var entry in router.routes.entries) {
        final check = request.uri.path.startsWith("${entry.key}/");
        logger.debug(
          "searching for request ${request.uri.path} if matching entry ${entry.key}/   $check",
        );
        if (request.uri.path.startsWith("${entry.key}/")) {
          logger.debug("found ${entry.key}");
          handler = entry.value;
          break;
        }
      }
    }

    if (handler != null) {
      try {
        await handler(request);
      } on Error catch (e, st) {
        logger.error('REAL Error handling ${request.uri.path}: $e\n$st');
        sendJsonError(request, HttpStatus.internalServerError, e);
      } catch (e, st) {
        logger.error('Error handling ${request.uri.path}: $e\n$st');
        sendError(request, HttpStatus.notFound, 'Route not found');
      }
    } else {
      logger.error("Route ${request.uri.path} not found");
      sendError(request, HttpStatus.notFound, 'Route not found');
    }
  }

  /// ========== Utilities ==========

  Future<String?> _getBestIPAddress() async {
    try {
      final info = NetworkInfo();
      final ip = await info.getWifiIP();
      if (ip != null && ip.isNotEmpty) return ip;
    } catch (e) {
      logger.error('NetworkInfoPlus not available: $e');
    }
    return await _getLocalIp();
  }

  Future<String?> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        return addr.address;
      }
    }
    return '127.0.0.1';
  }
}
