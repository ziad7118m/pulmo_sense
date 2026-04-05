import 'dart:developer' as dev;

enum LogLevel { debug, info, warn, error }

class AppLogger {
  static LogLevel level = LogLevel.debug;

  static void d(String message, {Object? data}) => _log(LogLevel.debug, message, data);
  static void i(String message, {Object? data}) => _log(LogLevel.info, message, data);
  static void w(String message, {Object? data}) => _log(LogLevel.warn, message, data);
  static void e(String message, {Object? error, StackTrace? stack, Object? data}) {
    _log(LogLevel.error, message, data);
    if (error != null) dev.log('error=$error', name: 'APP', error: error, stackTrace: stack);
  }

  static void _log(LogLevel l, String message, Object? data) {
    if (l.index < level.index) return;
    dev.log(
      data == null ? message : '$message | $data',
      name: 'APP',
    );
  }
}
