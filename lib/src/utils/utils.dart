import 'dart:typed_data';

import 'package:color_extractor/src/interfaces/image_source.dart';

/// Detects the image format based on the byte signature of the image data.
ImageFormat detectImageFormat(Uint8List bytes) {
  // Return unknown if the byte array is too small to contain a valid signature.
  if (bytes.length < 4) return ImageFormat.unknown;

  // Extract the first four bytes as the signature.
  final signature = bytes.sublist(0, 4);

  // Check for JPEG signature.
  if (signature[0] == 0xFF && signature[1] == 0xD8 && signature[2] == 0xFF) {
    return ImageFormat.jpeg;
  }

  // Check for PNG signature.
  else if (signature[0] == 0x89 &&
      signature[1] == 0x50 &&
      signature[2] == 0x4E &&
      signature[3] == 0x47) {
    return ImageFormat.png;
  }

  // Check for GIF signature.
  else if (signature[0] == 0x47 &&
      signature[1] == 0x49 &&
      signature[2] == 0x46) {
    return ImageFormat.gif;
  }

  // Check for BMP signature.
  else if (signature[0] == 0x42 && signature[1] == 0x4D) {
    return ImageFormat.bmp;
  }

  // If no known signature matches, return unknown.
  return ImageFormat.unknown;
}
