import 'package:logger/logger.dart';

import 'app.logger.dart';

mixin AppLogger {
  // Logger instance specific to the class using this mixin
  Logger get _logger => getLogger('$runtimeType');
  bool get enableLogs;

  // Check if logging is enabled; if not, exit early
  void logEntryCheck() {
    if (enableLogs) return;
  }

  // Debug logging
  void logD(dynamic message) {
    logEntryCheck();
    _logger.d(message);
  }

  // Info logging
  void logI(dynamic message) {
    logEntryCheck();
    _logger.i(message);
  }

  // Warning logging
  void logW(dynamic message) {
    logEntryCheck();
    _logger.w(message);
  }

  // Error logging
  void logE(dynamic message) {
    logEntryCheck();
    _logger.e(message);
  }
}
