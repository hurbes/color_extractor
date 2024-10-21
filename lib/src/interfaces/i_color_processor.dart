import 'package:flutter/material.dart';
import 'image_source.dart';
import 'i_image_converter.dart';
import 'i_isolate_manager.dart';
import 'i_native_bridge.dart';

abstract class IColorProcessor {
  Future<void> initialize({
    required INativeBridge nativeBridge,
    required IIsolateManager isolateManager,
    required IImageConverter imageConverter,
    bool enableDebugLogs = false,
  });

  Future<List<Color>> getDominantColors({
    required ImageSource image,
    int numColors,
  });
  void processImage(List<dynamic> message);
  List<Color> extractDominantColors(ImageSource imageSource, int numColors);
}
