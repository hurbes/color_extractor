import 'dart:typed_data';

/// Represents an image with pixel data, width, and height.
class ImageData {
  final Uint8List data; // Image pixel data in RGB format or other formats.
  final int width; // Width of the image in pixels.
  final int height; // Height of the image in pixels.

  /// Constructor for [ImageData] that requires pixel data, width, and height.
  const ImageData({
    required this.data,
    required this.width,
    required this.height,
  });
}

/// Represents YUV420 image data with Y, U, and V planes and image dimensions.
class KYuv420Data {
  final Uint8List yPlane; // Y (luminance) plane data.
  final Uint8List uPlane; // U (chrominance) plane data.
  final Uint8List vPlane; // V (chrominance) plane data.
  final int width; // Width of the image in pixels.
  final int height; // Height of the image in pixels.

  /// Constructor for [KYuv420Data] that requires Y, U, V planes, width, and height.
  const KYuv420Data({
    required this.yPlane,
    required this.uPlane,
    required this.vPlane,
    required this.width,
    required this.height,
  });
}
