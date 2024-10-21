import 'dart:async';
import 'dart:isolate';
import 'package:color_extractor/src/isolate_manager.dart';
import 'package:test/test.dart';

void main() {
  late IsolateManager isolateManager;

  setUp(() {
    isolateManager = IsolateManager(enableDebugLogs: true);
  });

  test('initialize should create an isolate', () async {
    await isolateManager.initialize((message) {});
    expect(isolateManager, isNotNull);
  });

  test('sendMessage should send message after initialization', () async {
    final completer = Completer<String>();

    await isolateManager.initialize((List<dynamic> message) {
      final SendPort sendPort = message[0];
      sendPort.send('Message received: ${message[1]}');
    });

    final receivePort = ReceivePort();
    await isolateManager.sendMessage([receivePort.sendPort, 'Hello']);

    receivePort.listen((message) {
      completer.complete(message as String);
    });

    final result = await completer.future.timeout(const Duration(seconds: 5));
    expect(result, equals('Message received: Hello'));
    receivePort.close();
  });
}
