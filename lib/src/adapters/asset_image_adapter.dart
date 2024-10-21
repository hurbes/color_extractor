import 'package:color_extractor/src/interfaces/image_source.dart';
import 'package:color_extractor/src/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AssetImageAdapter implements ImageSource {
  final Uint8List _bytes;
  late final int _width;
  late final int _height;
  late final ImageFormat _format;

  AssetImageAdapter._(this._bytes, this._width, this._height, this._format);

  static Future<AssetImageAdapter> load(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    final format = detectImageFormat(bytes);
    return AssetImageAdapter._(bytes, image.width, image.height, format);
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
