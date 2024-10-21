import 'dart:ffi';
import 'dart:io';

import 'package:color_extractor/src/bindings.dart';
import 'package:color_extractor/src/logger/logger_mixin.dart';
import 'package:color_extractor/src/models.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

import 'interfaces/i_native_bridge.dart';

/// A class to bridge Dart and native code for extracting dominant colors from images.
///
/// This class is responsible for initializing the native function, handling FFI calls,
/// and providing a clean Dart interface for extracting dominant colors using the native library.
class NativeBridge extends INativeBridge with AppLogger {
  /// The FFI function for extracting dominant colors. This will be initialized once.
  ExtractDominantColors? _extractDominantColors;

  /// A callback function that loads the native function for extracting dominant colors.
  /// This is either provided by the caller or defaults to [_defaultLoadFunction].
  final Future<ExtractDominantColors> Function() _loadFunction;

  /// Constructs a [NativeBridge] instance.
  ///
  /// [loadFunction] is an optional parameter that allows for a custom method to load the native function.
  /// [enableDebugLogs] is used to enable or disable debug logs through [AppLogger].
  NativeBridge({
    Future<ExtractDominantColors> Function()? loadFunction,
    required super.enableDebugLogs,
  }) : _loadFunction = loadFunction ?? _defaultLoadFunction;

  /// Default method for loading the native function from the native library based on the platform.
  ///
  /// This method loads the shared library for Android (`libcolor_extractor.so`) and
  /// uses the `DynamicLibrary.process()` method for iOS.
  ///
  /// Throws [UnsupportedError] if the platform is not Android or iOS.
  static Future<ExtractDominantColors> _defaultLoadFunction() async {
    late DynamicLibrary nativeLib;

    if (Platform.isAndroid) {
      nativeLib = DynamicLibrary.open('libcolor_extractor.so');
    } else if (Platform.isIOS) {
      nativeLib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // Looks up the `extract_dominant_colors` function in the loaded native library.
    return nativeLib.lookupFunction<ExtractDominantColorsNative,
        ExtractDominantColors>('extract_dominant_colors');
  }

  /// Initializes the native bridge by loading the FFI function for extracting dominant colors.
  ///
  /// This must be called before any attempt to extract dominant colors, or a [StateError] will be thrown.
  @override
  Future<void> initialize() async {
    _extractDominantColors = await _loadFunction();
  }

  /// Extracts dominant colors from the given [imageData] using the native function.
  ///
  /// - [imageData]: The image data containing the pixel information (bytes) and the dimensions.
  /// - [numColors]: The number of dominant colors to extract.
  ///
  /// Returns a list of [Color] objects representing the dominant colors extracted.
  ///
  /// Throws a [StateError] if the bridge is not initialized by calling [initialize].
  @override
  List<Color> extractDominantColors(ImageData imageData, int numColors) {
    // Ensure that the native function has been loaded.
    if (_extractDominantColors == null) {
      throw StateError(
          'NativeBridge not initialized. Call initialize() first.');
    }

    // Allocate memory for the image data.
    final imageDataPointer = malloc<Uint8>(imageData.data.length);
    imageDataPointer
        .asTypedList(imageData.data.length)
        .setAll(0, imageData.data);

    // Allocate memory for the dominant colors to be returned by the native function.
    final dominantColorsPointer = malloc<MColor>(numColors);

    try {
      // Call the native function to extract dominant colors.
      _extractDominantColors!(
        imageDataPointer,
        imageData.width,
        imageData.height,
        dominantColorsPointer,
        numColors,
      );

      // Convert the native MColor struct data to Flutter's Color objects.
      return List.generate(
        numColors,
        (index) => Color.fromARGB(
          255, // Alpha channel is always set to 255 (fully opaque).
          dominantColorsPointer[index].r, // Red component.
          dominantColorsPointer[index].g, // Green component.
          dominantColorsPointer[index].b, // Blue component.
        ),
      );
    } finally {
      // Free the allocated memory.
      malloc.free(imageDataPointer);
      malloc.free(dominantColorsPointer);
    }
  }

  /// Getter to check if debug logs are enabled. This is used by [AppLogger].
  @override
  bool get enableLogs => enableDebugLogs;
}
