import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/server/events.dart';
import 'package:proxishare/server/middlewares.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:proxishare/server/router.dart';

class LocalServer {
  int? port;
  String? ipAddress;
  String? url;
  bool loading = true;
  final _events = StreamController<ServerEvent>.broadcast();
  static LocalServer? current;
  HttpServer? _shelfServer;

  LocalServer({this.port});

  Stream<ServerEvent> get events => _events.stream;

  Future<void> start() async {
    logger.info('Starting local server...');

    LocalServer.current = this;

    ipAddress = await getBestIPAddress();
    logger.info('Server IP: $ipAddress');

    _shelfServer = await shelf_io.serve(
      Pipeline()
          .addMiddleware(Middlewares.handleCorsShelf())
          .addMiddleware(Middlewares.handleErrors())
          .addMiddleware(logRequests())
          .addHandler(_createCascadeHandler()),
      InternetAddress.anyIPv4,
      port ?? 0,
    );

    port = _shelfServer!.port;
    url = "http://$ipAddress:$port";
    logger.info('Server running on $url');

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
    await _shelfServer?.close();
    logger.info('Server stopped.');
    try {
      LocalServer.current = null;
      await _events.close();
    } catch (_) {}
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
        if (interface.name.startsWith('docker') ||
            interface.name.startsWith('veth') ||
            interface.name.startsWith('br-')) {
          continue;
        }

        for (final addr in interface.addresses) {
          final address = addr.address;
          if (address.startsWith('169.254.')) continue;
          if (address.startsWith('192.168.')) return address;
        }
      }

      throw Exception('No suitable local IP found');
    } catch (e, st) {
      logger.error('Failed to get local IP: $e\n$st');
    }
    return null;
  }

  Handler _createCascadeHandler() {
    return (Request request) async {
      try {
        return await router.call(request);
      } on HttpException catch (e) {
        final path = request.url.path;
        if (path.startsWith('webui') || path.isEmpty || path == '/') {
          return Response(
            HttpStatus.notFound,
            body: '<h2>404 Not Found</h2><p>${e.message}</p>',
            headers: {'Content-Type': 'text/html'},
          );
        }
        return Response(HttpStatus.notFound, body: '{"error": "Not found"}');
      } catch (e, st) {
        logger.error('Error handling ${request.url}: $e\n$st');
        final path = request.url.path;
        if (path.startsWith('webui') || path.isEmpty || path == '/') {
          return Response(
            HttpStatus.internalServerError,
            body: '<h2>500 Internal Server Error</h2><p>$e</p>',
            headers: {'Content-Type': 'text/html'},
          );
        }
        return Response(
          HttpStatus.internalServerError,
          body: '{"error": "Internal server error"}',
        );
      }
    };
  }
}
