import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'interfaces/i_isolate_manager.dart';
import 'logger/logger_mixin.dart';

/// [IsolateManager] manages communication between the main Dart thread
/// and a spawned isolate for background tasks.
class IsolateManager extends IIsolateManager with AppLogger {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _receivePort;
  late void Function(List<dynamic>) _processFunction;
  final Completer<void> _initCompleter = Completer<void>();

  /// Creates an [IsolateManager] instance.
  ///
  /// [enableDebugLogs] controls whether debug logs are enabled.
  IsolateManager({required super.enableDebugLogs});

  /// Initializes the isolate and sets up communication.
  ///
  /// [processFunction] is the function to run inside the isolate.
  @override
  Future<void> initialize(void Function(List<dynamic>) processFunction) async {
    logI('Initializing IsolateManager');

    if (_isolate != null) {
      logW('Isolate already initialized');
      return;
    }

    _processFunction = processFunction;
    _receivePort = ReceivePort();

    try {
      logI('Spawning isolate');
      _isolate = await Isolate.spawn(
        _isolateEntryPoint,
        _IsolateSetup(sendPort: _receivePort!.sendPort),
        debugName: 'ColorExtractor',
        errorsAreFatal: true,
      );

      logI('Waiting for isolate send port');
      _setupMessageListener();
      await _initCompleter.future;
      logI('Isolate initialization complete');
    } catch (e, stackTrace) {
      logE('Error spawning isolate: $e');
      logE('Stack trace: $stackTrace');
      await _dispose();
      // Instead of rethrowing, we'll complete the future with an error
      _initCompleter.completeError(e, stackTrace);
    }
  }

  void _setupMessageListener() {
    _receivePort?.listen(
      (dynamic message) {
        if (message is SendPort) {
          _isolateSendPort = message;
          _initCompleter.complete();
        } else if (message is List) {
          try {
            _processFunction(message);
          } catch (e, stackTrace) {
            logE('Error processing message: $e');
            logE('Stack trace: $stackTrace');
          }
        } else {
          logW('Unexpected message type: ${message.runtimeType}');
        }
      },
      onError: (error) {
        logE('Error in receive port: $error');
        if (!_initCompleter.isCompleted) {
          _initCompleter.completeError(error);
        }
      },
      onDone: () {
        logI('Receive port closed');
        if (!_initCompleter.isCompleted) {
          _initCompleter.completeError('Receive port closed unexpectedly');
        }
      },
    );
  }

  /// Sends a message to the isolate.
  ///
  /// [message] is the data to send.
  @override
  Future<void> sendMessage(List<dynamic> message) async {
    logI('Sending message to isolate');

    if (_isolateSendPort == null) {
      logE('IsolateManager not initialized');
      return;
    }

    try {
      _isolateSendPort!.send(message);
      logI('Message sent to isolate');
    } catch (e, stackTrace) {
      logE('Error sending message: $e');
      logE('Stack trace: $stackTrace');
    }
  }

  /// Disposes of the isolate and cleans up resources.
  @mustCallSuper
  Future<void> _dispose() async {
    logI('Disposing IsolateManager');
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isolateSendPort = null;
    _receivePort = null;
  }

  /// The entry point for the spawned isolate.
  static void _isolateEntryPoint(_IsolateSetup setup) {
    final receivePort = ReceivePort();
    setup.sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic message) {
      try {
        if (message is List) {
          // Process the message here in the isolate
          // For now, we'll just send it back to the main isolate
          setup.sendPort.send(message);
        } else {
          setup.sendPort.send(
              ['ERROR', 'Unexpected message type: ${message.runtimeType}']);
        }
      } catch (e, stackTrace) {
        setup.sendPort.send(['ERROR', e.toString(), stackTrace.toString()]);
      }
    });
  }

  /// Getter to check if debug logs are enabled.
  @override
  bool get enableLogs => super.enableDebugLogs;
}

/// Helper class to pass data to the isolate entry point.
class _IsolateSetup {
  final SendPort sendPort;

  _IsolateSetup({required this.sendPort});
}
