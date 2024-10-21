import 'package:flutter/material.dart';
import 'color_processor.dart';
import 'image_converter.dart';
import 'interfaces/image_source.dart';
import 'interfaces/i_color_processor.dart';
import 'interfaces/i_image_converter.dart';
import 'interfaces/i_isolate_manager.dart';
import 'interfaces/i_native_bridge.dart';
import 'isolate_manager.dart';
import 'native_bridge.dart';

/// Singleton class to extract dominant colors from images.
class ColorExtractor {
  static ColorExtractor? _instance; // Singleton instance.
  final IColorProcessor _processor; // ColorProcessor instance.

  // Private constructor for singleton pattern.
  ColorExtractor._({required IColorProcessor processor})
      : _processor = processor;

  /// Initializes the ColorExtractor singleton with optional custom components.
  static Future<ColorExtractor> initialize({
    INativeBridge? nativeBridge,
    IIsolateManager? isolateManager,
    IImageConverter? imageConverter,
    bool enableDebugLogs = false,
  }) async {
    if (_instance == null) {
      final processor = ColorProcessor();

      // Initializes the processor with either provided components or defaults.
      await processor.initialize(
        nativeBridge:
            nativeBridge ?? NativeBridge(enableDebugLogs: enableDebugLogs),
        isolateManager:
            isolateManager ?? IsolateManager(enableDebugLogs: enableDebugLogs),
        imageConverter:
            imageConverter ?? ImageConverter(enableDebugLogs: enableDebugLogs),
        enableDebugLogs: enableDebugLogs,
      );

      // Assign the singleton instance.
      _instance = ColorExtractor._(processor: processor);
    }
    return _instance!;
  }

  /// Getter for the singleton instance.
  static ColorExtractor get instance {
    if (_instance == null) {
      throw StateError(
          'ColorExtractor not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Extracts dominant colors from the given [image].
  Future<List<Color>> getDominantColors({
    required ImageSource image,
    int numColors = 3,
  }) {
    return _processor.getDominantColors(image: image, numColors: numColors);
  }
}
