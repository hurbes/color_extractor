import 'dart:typed_data';
import 'package:color_extractor/src/utils/utils.dart';
import 'package:flutter/material.dart';
import '../interfaces/image_source.dart';

class MemoryImageAdapter implements ImageSource {
  final Uint8List _bytes;
  late final int _width;
  late final int _height;
  late final ImageFormat _format;

  MemoryImageAdapter._(this._bytes, this._width, this._height, this._format);

  static Future<MemoryImageAdapter> load(Uint8List bytes) async {
    final image = await decodeImageFromList(bytes);
    final format = detectImageFormat(bytes);
    return MemoryImageAdapter._(bytes, image.width, image.height, format);
  }

  @override
  int get width => _width;

  @override
  int get height => _height;

  @override
  Uint8List getRawData() => _bytes;

  @override
  ImageFormat getFormat() => _format;
}
