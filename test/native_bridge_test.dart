import 'dart:ffi';
import 'dart:typed_data';
import 'package:color_extractor/src/bindings.dart';
import 'package:color_extractor/src/models.dart';
import 'package:color_extractor/src/native_bridge.dart';
import 'package:test/test.dart';

import 'package:flutter/material.dart';

void mockExtractDominantColors(Pointer<Uint8> imageData, int width, int height,
    Pointer<MColor> dominantColors, int numColors) {
  // Simulate extracting colors by setting some dummy values
  for (int i = 0; i < numColors; i++) {
    dominantColors[i].r = 255;
    dominantColors[i].g = 0;
    dominantColors[i].b = 0;
  }
}

void main() {
  late NativeBridge nativeBridge;

  setUp(() {
    nativeBridge = NativeBridge(
      enableDebugLogs: true,
      loadFunction: () async => mockExtractDominantColors,
    );
  });

  test('initialize should not throw', () async {
    await expectLater(nativeBridge.initialize(), completes);
  });

  test('extractDominantColors should return colors', () async {
    await nativeBridge.initialize();

    final imageData = ImageData(
      data: Uint8List.fromList(List.generate(300, (index) => index % 256)),
      width: 10,
      height: 10,
    );

    final colors = nativeBridge.extractDominantColors(imageData, 3);

    expect(colors, hasLength(3));
    expect(colors[0], equals(const Color(0xFFFF0000))); // Red color
    expect(colors[1], equals(const Color(0xFFFF0000))); // Red color
    expect(colors[2], equals(const Color(0xFFFF0000))); // Red color
  });

  test('extractDominantColors should throw if not initialized', () {
    final imageData = ImageData(
      data: Uint8List.fromList(List.generate(300, (index) => index % 256)),
      width: 10,
      height: 10,
    );

    expect(
      () => nativeBridge.extractDominantColors(imageData, 3),
      throwsA(isA<StateError>()),
    );
  });
}
