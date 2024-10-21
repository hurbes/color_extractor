import 'package:color_extractor/src/interfaces/i_color_processor.dart';
import 'package:color_extractor/src/interfaces/i_image_converter.dart';
import 'package:color_extractor/src/interfaces/i_isolate_manager.dart';
import 'package:color_extractor/src/interfaces/i_native_bridge.dart';
import 'package:color_extractor/src/interfaces/image_source.dart';
import 'package:mockito/annotations.dart';
import 'dart:isolate';

@GenerateMocks([
  IColorProcessor,
  IImageConverter,
  IIsolateManager,
  INativeBridge,
  ImageSource,
  ReceivePort,
  SendPort
])
void main() {}
