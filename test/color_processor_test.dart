import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:color_extractor/src/color_processor.dart';
import 'package:color_extractor/src/models.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'mocks/mocks.mocks.dart';

void main() {
  late ColorProcessor colorProcessor;
  late MockINativeBridge mockNativeBridge;
  late MockIIsolateManager mockIsolateManager;
  late MockIImageConverter mockImageConverter;

  setUp(() {
    mockNativeBridge = MockINativeBridge();
    mockIsolateManager = MockIIsolateManager();
    mockImageConverter = MockIImageConverter();
    colorProcessor = ColorProcessor();
  });

  Future<void> initializeColorProcessor() async {
    when(mockNativeBridge.initialize()).thenAnswer((_) async {});
    when(mockIsolateManager.initialize(any)).thenAnswer((_) async {});

    await colorProcessor.initialize(
      nativeBridge: mockNativeBridge,
      isolateManager: mockIsolateManager,
      imageConverter: mockImageConverter,
    );
  }

  test('initialize should set up dependencies', () async {
    await initializeColorProcessor();

    verify(mockNativeBridge.initialize()).called(1);
    verify(mockIsolateManager.initialize(any)).called(1);
  });

  test('getDominantColors should return colors', () async {
    await initializeColorProcessor();

    final mockImageSource = MockImageSource();
    final expectedColors = [Colors.red, Colors.blue];

    when(mockIsolateManager.sendMessage(any)).thenAnswer((invocation) async {
      final List<dynamic> args = invocation.positionalArguments[0];
      final SendPort sendPort = args[2];
      sendPort.send(expectedColors);
    });

    final colors =
        await colorProcessor.getDominantColors(image: mockImageSource);

    expect(colors, expectedColors);
    verify(mockIsolateManager.sendMessage(any)).called(1);
  });

  test('processImage should extract colors and send them', () async {
    await initializeColorProcessor();

    final mockImageSource = MockImageSource();
    final mockSendPort = MockSendPort();

    when(mockImageConverter.convertToRgb(any))
        .thenReturn(ImageData(data: Uint8List(0), width: 100, height: 100));
    when(mockNativeBridge.extractDominantColors(any, any))
        .thenReturn([Colors.red, Colors.blue]);

    colorProcessor.processImage([mockImageSource, 2, mockSendPort]);

    verify(mockImageConverter.convertToRgb(any)).called(1);
    verify(mockNativeBridge.extractDominantColors(any, 2)).called(1);
    verify(mockSendPort.send([Colors.red, Colors.blue])).called(1);
  });
}
