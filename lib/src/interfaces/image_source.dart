import 'dart:typed_data';

/// Enum representing various image formats that the [ImageSource] can support.
enum ImageFormat {
  nv21, // NV21 format, commonly used in Android camera preview.
  bgra8888, // 32-bit BGRA (8 bits per channel).
  yuv420, // YUV420 format, often used in video encoding.
  jpeg, // JPEG image format.
  png, // PNG image format.
  gif, // GIF image format.
  bmp, // BMP image format.
  unknown // Unknown or unsupported image format.
}

/// Abstract class representing the source of an image, which provides basic
/// details such as dimensions and raw data for different image formats.
abstract class ImageSource {
  /// The width of the image in pixels.
  int get width;

  /// The height of the image in pixels.
  int get height;

  /// Retrieves the raw image data as a [Uint8List].
  ///
  /// The format of the data will depend on the image format returned by [getFormat].
  Uint8List getRawData();

  /// Returns the [ImageFormat] of the image.
  ImageFormat getFormat();
}
