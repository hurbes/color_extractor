import 'package:color_extractor/src/logger/logger_mixin.dart';
import 'package:color_extractor/src/models.dart';
import 'package:flutter/foundation.dart';
import 'interfaces/image_source.dart';
import 'interfaces/i_image_converter.dart';
import 'package:image/image.dart' as img;

/// This class implements the [IImageConverter] interface and provides
/// functionality to convert various image formats (such as NV21, BGRA8888, YUV420)
/// into RGB format. It also logs important events if logging is enabled.
class ImageConverter extends IImageConverter with AppLogger {
  /// Constructor for [ImageConverter], which optionally enables logging
  /// through the [enableDebugLogs] parameter.
  ImageConverter({required super.enableDebugLogs});

  /// Converts the raw image data from the given [ImageSource] to the RGB format.
  /// Supports multiple formats: NV21, BGRA8888, YUV420, and throws an error
  /// for unsupported formats such as JPEG.
  ///
  /// [imageSource]: The source of the image, providing width, height, raw data, and format.
  /// Returns an [ImageData] object containing the RGB image data.
  @override
  ImageData convertToRgb(ImageSource imageSource) {
    final format = imageSource.getFormat();
    final rawData = imageSource.getRawData();
    final width = imageSource.width;
    final height = imageSource.height;

    switch (format.name) {
      case 'nv21':
        return ImageData(
          data: convertNv21ToRgb(rawData, width, height),
          width: width,
          height: height,
        );
      case 'bgra8888':
        return ImageData(
          data: convertBgra8888ToRgb(rawData),
          width: width,
          height: height,
        );
      case 'yuv420':
        final yuv420Data = KYuv420Data(
          yPlane: rawData.sublist(0, width * height),
          uPlane: rawData.sublist(
            width * height,
            width * height + (width * height) ~/ 4,
          ),
          vPlane: rawData.sublist(
            width * height + (width * height) ~/ 4,
          ),
          width: width,
          height: height,
        );
        return ImageData(
          data: convertYuv420ToRgb(yuv420Data),
          width: width,
          height: height,
        );
      case 'jpg':
      case 'png':
      case 'gif':
      case 'bmp':
        return convertCommonFormatToRgb(rawData, format);
      default:
        throw ArgumentError('Unsupported image format: $format');
    }
  }

  ImageData convertCommonFormatToRgb(Uint8List rawData, ImageFormat format) {
    img.Image? decodedImage;
    switch (format) {
      case ImageFormat.jpeg:
        decodedImage = img.decodeJpg(rawData);
        break;
      case ImageFormat.png:
        decodedImage = img.decodePng(rawData);
        break;
      case ImageFormat.gif:
        decodedImage = img.decodeGif(rawData);
        break;
      case ImageFormat.bmp:
        decodedImage = img.decodeBmp(rawData);
        break;
      default:
        throw ArgumentError('Unsupported image format: $format');
    }

    if (decodedImage == null) {
      throw ArgumentError('Failed to decode image');
    }

    // Convert to RGB
    final rgbImage = img.copyResize(decodedImage,
        width: decodedImage.width, height: decodedImage.height);
    final rgbData = Uint8List(rgbImage.width * rgbImage.height * 3);
    int index = 0;
    for (int y = 0; y < rgbImage.height; y++) {
      for (int x = 0; x < rgbImage.width; x++) {
        final pixel = rgbImage.getPixel(x, y);
        rgbData[index++] = pixel.r.toInt();
        rgbData[index++] = pixel.g.toInt();
        rgbData[index++] = pixel.b.toInt();
      }
    }

    return ImageData(
      data: rgbData,
      width: rgbImage.width,
      height: rgbImage.height,
    );
  }

  /// Converts an NV21 image format to RGB format.
  ///
  /// [nv21]: The raw NV21 data.
  /// [width]: The width of the image in pixels.
  /// [height]: The height of the image in pixels.
  /// Returns a [Uint8List] containing the RGB data.
  @visibleForTesting
  @override
  Uint8List convertNv21ToRgb(Uint8List nv21, int width, int height) {
    final int frameSize = width * height;
    final rgb = Uint8List(width * height * 3);

    for (int j = 0, yp = 0; j < height; j++) {
      int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
      for (int i = 0; i < width; i++, yp++) {
        int y = (0xff & nv21[yp]) - 16;
        if (y < 0) y = 0;
        if ((i & 1) == 0) {
          v = (0xff & nv21[uvp++]) - 128;
          u = (0xff & nv21[uvp++]) - 128;
        }

        int y1192 = 1192 * y;
        int r = (y1192 + 1634 * v);
        int g = (y1192 - 833 * v - 400 * u);
        int b = (y1192 + 2066 * u);

        // Clamping the values to the 0-255 range.
        r = r.clamp(0, 262143) >> 10 & 0xff;
        g = g.clamp(0, 262143) >> 10 & 0xff;
        b = b.clamp(0, 262143) >> 10 & 0xff;

        rgb[yp * 3] = r;
        rgb[yp * 3 + 1] = g;
        rgb[yp * 3 + 2] = b;
      }
    }
    return rgb;
  }

  /// Converts a BGRA8888 image format to RGB format.
  ///
  /// [bgra]: The raw BGRA data.
  /// Returns a [Uint8List] containing the RGB data.
  @visibleForTesting
  @override
  Uint8List convertBgra8888ToRgb(Uint8List bgra) {
    final rgb = Uint8List(bgra.length ~/ 4 * 3);
    for (int i = 0, j = 0; i < bgra.length; i += 4, j += 3) {
      rgb[j] = bgra[i + 2]; // Red channel
      rgb[j + 1] = bgra[i + 1]; // Green channel
      rgb[j + 2] = bgra[i]; // Blue channel
    }
    return rgb;
  }

  /// Converts YUV420 image format to RGB format using Y, U, and V planes.
  ///
  /// [yuv420]: A [KYuv420Data] object containing Y, U, and V planes of YUV data.
  /// Returns a [Uint8List] containing the RGB data.
  @visibleForTesting
  @override
  Uint8List convertYuv420ToRgb(KYuv420Data yuv420) {
    final int width = yuv420.width;
    final int height = yuv420.height;
    final Uint8List yPlane = yuv420.yPlane;
    final Uint8List uPlane = yuv420.uPlane;
    final Uint8List vPlane = yuv420.vPlane;

    final Uint8List rgbImage = Uint8List(width * height * 3);
    int rgbIndex = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

        int yValue = yPlane[yIndex] & 0xFF;
        int uValue = uPlane[uvIndex] & 0xFF;
        int vValue = vPlane[uvIndex] & 0xFF;

        // Convert YUV to RGB using standard YUV-RGB conversion formulas.
        int r = (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
        int g = (yValue - 0.698001 * (vValue - 128) - 0.337633 * (uValue - 128))
            .round()
            .clamp(0, 255);
        int b = (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);

        rgbImage[rgbIndex++] = r;
        rgbImage[rgbIndex++] = g;
        rgbImage[rgbIndex++] = b;
      }
    }
    return rgbImage;
  }

  /// Getter for enabling or disabling logging.
  @override
  bool get enableLogs => enableDebugLogs;
}
