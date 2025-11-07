import 'package:logger/logger.dart' as log;

extension LoggerAliases on log.Logger {
  void trace(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      t(message, error: error, stackTrace: stackTrace);

  void debug(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      d(message, error: error, stackTrace: stackTrace);

  void info(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      i(message, error: error, stackTrace: stackTrace);

  void warn(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      w(message, error: error, stackTrace: stackTrace);

  void error(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      e(message, error: error, stackTrace: stackTrace);
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
