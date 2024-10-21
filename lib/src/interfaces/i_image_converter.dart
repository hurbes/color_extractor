import 'dart:typed_data';

import '../models.dart';
import 'image_source.dart';

abstract class IImageConverter {
  IImageConverter({required this.enableDebugLogs});

  final bool enableDebugLogs;

  ImageData convertToRgb(ImageSource imageSource);
  Uint8List convertYuv420ToRgb(KYuv420Data yuv420);
  Uint8List convertBgra8888ToRgb(Uint8List bgra);
  Uint8List convertNv21ToRgb(Uint8List nv21, int width, int height);
}
