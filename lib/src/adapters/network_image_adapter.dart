import 'dart:typed_data';

import 'package:color_extractor/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../interfaces/image_source.dart';

class NetworkImageAdapter implements ImageSource {
  final Uint8List _bytes;
  late final int _width;
  late final int _height;
  late final ImageFormat _format;

  NetworkImageAdapter._(this._bytes, this._width, this._height, this._format);

  static Future<NetworkImageAdapter> load(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image from network');
    }
    final bytes = response.bodyBytes;
    final image = await decodeImageFromList(bytes);
    final format = detectImageFormat(bytes);
    return NetworkImageAdapter._(bytes, image.width, image.height, format);
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
