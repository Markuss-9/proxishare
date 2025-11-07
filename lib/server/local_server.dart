import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
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
    dev.log('Starting local server...');

    ipAddress = await _getBestIPAddress();
    dev.log('Server IP: $ipAddress');

    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);

    url = "http://$ipAddress:$port";
    dev.log('Server running on $url');

    _server!.listen(_handleRequest);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    dev.log('Server stopped.');
  }

  Future<void> _handleRequest(HttpRequest request) async {
    dev.log('Request: ${request.method} ${request.uri.path}');
    final handler = router.routes[request.uri.path];

    if (handler != null) {
      try {
        await handler(request);
      } on Error catch (e, st) {
        // TODO: better handling of errors, depending from api json vs html
        dev.log('REAL Error handling ${request.uri.path}: $e\n$st');
        sendJsonError(request, HttpStatus.internalServerError, e);
      } catch (e, st) {
        dev.log('Error handling ${request.uri.path}: $e\n$st');
        sendError(request, HttpStatus.notFound, 'Route not found');
      }
    } else {
      dev.log("Route ${request.uri.path} not found");
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
      dev.log('NetworkInfoPlus not available: $e');
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
