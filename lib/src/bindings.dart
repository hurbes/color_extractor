import 'dart:ffi';

/// Native function signature for extracting dominant colors from an image.
///
/// This function is expected to be implemented in a native library,
/// and it extracts dominant colors from image data. It takes the image data,
/// width, height, and a pointer to an array of `MColor` structs that will store
/// the dominant colors. The number of dominant colors to be extracted is also specified.
///
/// Parameters:
/// - [imageData] Pointer to the image data as an array of bytes (Uint8).
/// - [width] Width of the image in pixels.
/// - [height] Height of the image in pixels.
/// - [dominantColors] Pointer to an array of `MColor` structs where the extracted colors will be stored.
/// - [numColors] Number of dominant colors to extract.
typedef ExtractDominantColorsNative = Void Function(
  Pointer<Uint8> imageData,
  Int32 width,
  Int32 height,
  Pointer<MColor> dominantColors,
  Int32 numColors,
);

/// Dart function signature corresponding to the native function for extracting dominant colors.
///
/// This typedef allows Dart code to call the native function. It maps the native function signature
/// to Dart types. The function extracts dominant colors from the given image and stores them
/// in the provided array of `MColor` structs.
///
/// Parameters:
/// - [imageData] Pointer to the image data as an array of bytes (Uint8).
/// - [width] Width of the image in pixels.
/// - [height] Height of the image in pixels.
/// - [dominantColors] Pointer to an array of `MColor` structs where the extracted colors will be stored.
/// - [numColors] Number of dominant colors to extract.
typedef ExtractDominantColors = void Function(
  Pointer<Uint8> imageData,
  int width,
  int height,
  Pointer<MColor> dominantColors,
  int numColors,
);

/// Struct representing an RGB color.
///
/// This struct is used in the FFI layer to pass color information between Dart and native code.
/// Each color is represented by its red, green, and blue (RGB) components, each of which is
/// an 8-bit integer (0-255).
base class MColor extends Struct {
  @Uint8()
  external int r; // Red component of the color (0-255).

  @Uint8()
  external int g; // Green component of the color (0-255).

  @Uint8()
  external int b; // Blue component of the color (0-255).
}
