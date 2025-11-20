import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log;
import 'package:logger/web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const logFileName = 'proxishare.log';

class LogService {
  static final List<String> _logs = [];

  static void add(String message) {
    _logs.add(message);
  }

  static List<String> get logs => _logs;

  static Future<String?> exportLogs() async {
    try {
      if (Platform.isAndroid) {
        // Request storage permission for older Android versions
        final storageGranted = await Permission.storage.request().isGranted;

        // Request MANAGE_EXTERNAL_STORAGE for Android 11+
        final manageGranted = await Permission.manageExternalStorage
            .request()
            .isGranted;

        if (storageGranted || manageGranted) {
          try {
            final externalPath = '/storage/emulated/0/Download/$logFileName';
            final file = File(externalPath);
            await file.writeAsString(_logs.join('\n'));
            return file.path;
          } catch (e) {
            debugPrint('Failed to write to Downloads: $e');
          }
        }
      }

      // iOS or fallback for Android
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$logFileName');
      await file.writeAsString(_logs.join('\n'));
      return file.path;
    } catch (e) {
      debugPrint('Failed to export logs: $e');
      return null;
    }
  }
}

extension LoggerAliases on Logger {
  void trace(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    logger.t(message, error: error, stackTrace: stackTrace);
    LogService.add('[TRACE]\t\t${message.toString()}');
  }

  void debug(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    logger.d(message, error: error, stackTrace: stackTrace);
    LogService.add('[DEBUG]\t\t${message.toString()}');
  }

  void info(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    logger.i(message, error: error, stackTrace: stackTrace);
    LogService.add('[INFO]\t\t${message.toString()}');
  }

  void warn(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    logger.w(message, error: error, stackTrace: stackTrace);
    LogService.add('[WARN]\t\t${message.toString()}');
  }

  void error(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    logger.e(message, error: error, stackTrace: stackTrace);
    LogService.add('[ERROR]\t\t${message.toString()}');
  }
}

final logger = log.Logger(
  printer: log.PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);
