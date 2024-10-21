import 'package:flutter/material.dart';
import '../models.dart';

abstract class INativeBridge {
  INativeBridge({required this.enableDebugLogs});

  final bool enableDebugLogs;

  Future<void> initialize();
  List<Color> extractDominantColors(ImageData imageData, int numColors);
}
