import 'dart:async';
import 'dart:isolate';
import 'package:color_extractor/src/models.dart';
import 'package:flutter/material.dart';
import 'interfaces/i_color_processor.dart';
import 'interfaces/i_image_converter.dart';
import 'interfaces/i_isolate_manager.dart';
import 'interfaces/i_native_bridge.dart';
import 'logger/logger_mixin.dart';
import 'interfaces/image_source.dart';

/// ColorProcessor extracts dominant colors from images using isolates.
class ColorProcessor with AppLogger implements IColorProcessor {
  late final INativeBridge
      _nativeBridge; // Interface to native code for color extraction.
  late final IIsolateManager
      _isolateManager; // Manages isolate for image processing.
  late final IImageConverter _imageConverter; // Converts images to RGB format.
  late final bool _enableDebugLogs; // Flag to control debug logging.

  /// Initializes the processor with native bridge, isolate manager, and image converter.
  @override
  Future<void> initialize({
    required INativeBridge nativeBridge,
    required IIsolateManager isolateManager,
    required IImageConverter imageConverter,
    bool enableDebugLogs = false,
  }) async {
    _nativeBridge = nativeBridge;
    _isolateManager = isolateManager;
    _imageConverter = imageConverter;
    _enableDebugLogs = enableDebugLogs;

    await _nativeBridge.initialize(); // Initialize native bridge.
    await _isolateManager
        .initialize(processImage); // Setup isolate for image processing.
  }

  /// Extracts dominant colors from the given [image] using an isolate.
  @override
  Future<List<Color>> getDominantColors({
    required ImageSource image,
    int numColors = 3,
  }) {
    final completer = Completer<List<Color>>();
    final responsePort =
        ReceivePort(); // Port to receive response from the isolate.

    responsePort.listen((message) {
      completer.complete(
          message as List<Color>); // Completes future with extracted colors.
      responsePort.close(); // Close port after receiving response.
    });

    _isolateManager.sendMessage(
        [image, numColors, responsePort.sendPort]); // Send message to isolate.

    return completer.future; // Return future to await result.
  }

  /// Processes the image within the isolate, converts it, and extracts dominant colors.
  @override
  void processImage(List<dynamic> message) {
    final ImageSource imageSource = message[0];
    final int numColors = message[1];
    final SendPort responsePort = message[2];

    try {
      List<Color> dominantColors =
          extractDominantColors(imageSource, numColors); // Extract colors.
      if (_enableDebugLogs) {
        logI('Extracted colors: $dominantColors');
      }
      responsePort.send(dominantColors); // Send result back to main thread.
    } catch (e) {
      if (_enableDebugLogs) {
        logE('Error in color extraction: $e');
      }
      responsePort.send([]); // Send empty list in case of error.
    }
  }

  /// Converts the image to RGB and extracts dominant colors using native bridge.
  @visibleForTesting
  @override
  List<Color> extractDominantColors(ImageSource imageSource, int numColors) {
    final ImageData imageData =
        _imageConverter.convertToRgb(imageSource); // Convert image to RGB.
    return _nativeBridge.extractDominantColors(
        imageData, numColors); // Extract colors using native bridge.
  }

  /// Whether logging is enabled.
  @override
  bool get enableLogs => _enableDebugLogs;
}
