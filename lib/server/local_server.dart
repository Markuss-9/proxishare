import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/server/events.dart';
import 'package:proxishare/server/error_handler.dart';
import 'package:proxishare/server/middlewares.dart';

import 'package:proxishare/server/router.dart';

class LocalServer {
  int? port;
  HttpServer? _server;
  String? ipAddress;
  String? url;
  bool loading = true;
  final _events = StreamController<ServerEvent>.broadcast();
  static LocalServer? current;

  LocalServer({this.port});

  Stream<ServerEvent> get events => _events.stream;

  Router router = Router();

  Future<void> start() async {
    logger.info('Starting local server...');

    // register singleton so controllers can notify
    LocalServer.current = this;

    ipAddress = await getBestIPAddress();
    logger.info('Server IP: $ipAddress');

    _server = await HttpServer.bind(InternetAddress.anyIPv4, port ?? 0);
    port = _server!.port;

    url = "http://$ipAddress:$port";
    logger.info('Server running on $url');

    _server!.listen(_handleRequest);
    loading = false;
  }

  void notifyEvent(ServerEvent event) {
    try {
      _events.add(event);
    } catch (e, st) {
      logger.error('Failed to notify event: $e\n$st');
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    logger.info('Server stopped.');
    try {
      LocalServer.current = null;
      await _events.close();
    } catch (_) {}
  }

  Future<void> _handleRequest(HttpRequest request) async {
    logger.trace('Request: ${request.method} ${request.uri.path}');
    Middlewares.handleCors(request);

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

  Future<String> getBestIPAddress() async {
    String? ip;

    try {
      final info = NetworkInfo();
      ip = await info.getWifiIP();
      logger.debug('NetworkInfoPlus returned WiFi IP: $ip');
    } catch (e, st) {
      logger.error('NetworkInfoPlus failed: $e\n$st');
    }

    ip ??= await _getLocalIp();

    ip ??= '127.0.0.1';

    // if (_isAndroidEmulator(ip)) {
    //   logger.debug(
    //     'Detected Android Emulator IP: $ip — remapping to 10.0.2.2 (host)',
    //   );
    //   return '10.0.2.2';
    // }

    // if (_isiOSSimulator(ip)) {
    //   logger.debug(
    //     'Detected iOS Simulator IP: $ip — remapping to 127.0.0.1 (host)',
    //   );
    //   return '127.0.0.1';
    // }

    return ip;
  }

  Future<String?> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      logger.debug(
        'Found network interfaces: ${interfaces.map((e) => e.name).join(', ')}',
      );

      for (final interface in interfaces) {
        // Skip virtual or docker interfaces
        if (interface.name.startsWith('docker') ||
            interface.name.startsWith('veth') ||
            interface.name.startsWith('br-')) {
          continue;
        }

        for (final addr in interface.addresses) {
          final address = addr.address;
          // Skip link-local
          if (address.startsWith('169.254.')) continue;
          // Only take 192.168.x.x (your home network)
          if (address.startsWith('192.168.')) return address;
          // Optional: include 10.x.x.x if you know the subnet is reachable
        }
      }

      throw Exception('No suitable local IP found');
    } catch (e, st) {
      logger.error('Failed to get local IP: $e\n$st');
    }
    return null;
  }

  bool _isAndroidEmulator(String ip) {
    // Android emulators use 10.0.2.x (default) or 10.0.3.x (Genymotion)
    return ip.startsWith('10.0.2.') || ip.startsWith('10.0.3.');
  }

  bool _isiOSSimulator(String ip) {
    // iOS simulator often uses 127.0.0.1 or 0.0.0.0
    return ip == '127.0.0.1' || ip == '0.0.0.0';
  }
}
