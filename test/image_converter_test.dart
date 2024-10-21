import 'dart:typed_data';
import 'package:color_extractor/color_extractor.dart';
import 'package:color_extractor/src/image_converter.dart';
import 'package:color_extractor/src/models.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks/mocks.mocks.dart';

void main() {
  late ImageConverter imageConverter;

  setUp(() {
    imageConverter = ImageConverter(enableDebugLogs: true);
  });

  test('convertToRgb should handle NV21 format', () {
    final mockImageSource = MockImageSource();
    when(mockImageSource.getFormat()).thenReturn(ImageFormat.nv21);
    when(mockImageSource.getRawData())
        .thenReturn(Uint8List(150)); // Changed to 150
    when(mockImageSource.width).thenReturn(10);
    when(mockImageSource.height).thenReturn(10);

    final result = imageConverter.convertToRgb(mockImageSource);

    expect(result, isA<ImageData>());
    expect(result.width, 10);
    expect(result.height, 10);
  });

  test('convertNv21ToRgb should convert NV21 to RGB', () {
    final nv21Data = Uint8List.fromList(
        List.generate(150, (index) => index % 256)); // Changed to 150
    final result = imageConverter.convertNv21ToRgb(nv21Data, 10, 10);

    expect(result, isA<Uint8List>());
    expect(result.length, 300); // 10x10x3 (RGB)
  });

  // The rest of the tests remain unchanged

  test('convertBgra8888ToRgb should convert BGRA to RGB', () {
    final bgraData =
        Uint8List.fromList(List.generate(400, (index) => index % 256));
    final result = imageConverter.convertBgra8888ToRgb(bgraData);

    expect(result, isA<Uint8List>());
    expect(result.length, 300); // 100x3 (RGB)
  });

  test('convertYuv420ToRgb should convert YUV420 to RGB', () {
    final yuv420Data = KYuv420Data(
      yPlane: Uint8List(100),
      uPlane: Uint8List(25),
      vPlane: Uint8List(25),
      width: 10,
      height: 10,
    );
    final result = imageConverter.convertYuv420ToRgb(yuv420Data);

    expect(result, isA<Uint8List>());
    expect(result.length, 300); // 10x10x3 (RGB)
  });
}
