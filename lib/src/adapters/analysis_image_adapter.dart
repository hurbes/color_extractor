import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import '../interfaces/image_source.dart';

class AnalysisImageAdapter implements ImageSource {
  final AnalysisImage _analysisImage;

  AnalysisImageAdapter(this._analysisImage);

  @override
  int get width => _analysisImage.width;

  @override
  int get height => _analysisImage.height;
  @override
  Uint8List getRawData() {
    return _analysisImage.when(
          nv21: (nv21Image) => nv21Image.bytes,
          bgra8888: (bgra8888Image) => bgra8888Image.bytes,
          yuv420: (yuv420Image) => Uint8List.fromList([
            ...yuv420Image.planes[0].bytes,
            ...yuv420Image.planes[1].bytes,
            ...yuv420Image.planes[2].bytes,
          ]),
          jpeg: (jpegImage) => jpegImage.bytes,
        ) ??
        Uint8List(0); // Return an empty Uint8List if the result is null
  }

  @override
  ImageFormat getFormat() {
    return _analysisImage.when(
          nv21: (_) => ImageFormat.nv21,
          bgra8888: (_) => ImageFormat.bgra8888,
          yuv420: (_) => ImageFormat.yuv420,
          jpeg: (_) => ImageFormat.jpeg,
        ) ??
        ImageFormat.nv21; // Default to nv21 if the result is null
  }
}
