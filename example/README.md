# Color Extractor Example

This Flutter project demonstrates how to use the `Color Extractor` package to extract dominant colors from an image. It provides an example of integrating this package in a simple UI application.

## Features

- Extract dominant colors from an image using isolates for better performance.
- Display the extracted colors in a list of colored containers.
- Supports multiple image formats including JPEG, PNG, GIF, BMP, and more.

## Getting Started

### Prerequisites

- Flutter SDK installed.
- A valid Flutter project setup.

### Installation

To install the package in your Flutter project, add the following to your `pubspec.yaml`:

```yaml
dependencies:
  color_extractor: ^1.0.0 # Replace with the correct version.
```

### Run pub get
```bash
flutter pub get
```
### Example Usage
This example demonstrates how to use the Color Extractor package in a Flutter project.

```dart
import 'package:color_extractor/color_extractor.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// Main entry point for the application.
/// Initializes the `ColorExtractor` with debug logs enabled,
/// then runs the Flutter app.
Future<void> main() async {
  await ColorExtractor.initialize(enableDebugLogs: true);
  runApp(const MyApp());
}

/// Asynchronously extracts dominant colors from an image.
///
/// Loads an image from the asset folder and uses the `ColorExtractor`
/// to extract up to 12 dominant colors.
///
/// Returns:
///   A [Future] that resolves to a list of [Color] objects representing the dominant colors.
Future<List<Color>> getColors() async {
  // Load the image from assets.
  final assetImage = await AssetImageAdapter.load('assets/image.png');

  // Extract dominant colors from the image.
  final extractedColors = await ColorExtractor.instance.getDominantColors(
    image: assetImage,
    numColors: 12,
  );

  return extractedColors;
}

/// A Flutter application that demonstrates the use of the Color Extractor package.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// The state class for `MyApp` which builds the UI for the app.
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  /// Builds the main UI for the application.
  ///
  /// The UI consists of an image at the top and a list of extracted colors
  /// displayed in colored containers below the image.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Color Extractor'),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Image.asset('assets/image.png')),
            SliverPadding(
              padding: const EdgeInsets.only(top: 20),
              sliver: SliverFillRemaining(
                child: FutureBuilder<List<Color>>(
                  future: getColors(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<Color>> value,
                  ) {
                    final connectionState = value.connectionState;
                    final colorList = value.data ?? [];

                    // Show a loading indicator while colors are being extracted.
                    if (connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // If no colors are extracted, display a 'No Color Data' message.
                    if (colorList.isEmpty) {
                      return const Center(child: Text('No Color Data'));
                    }

                    // Display the extracted colors in a list of containers.
                    return ListView.builder(
                      itemCount: colorList.length,
                      itemBuilder: (context, index) {
                        return _ColoredTile(color: colorList[index]);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColoredTile extends StatelessWidget {
  const _ColoredTile({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      color: color,
      child: Text(
        '$color',
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

### Assets
To use the image in your project, make sure to add the image to your project's assets folder and declare it in the `pubspec.yaml` file:

### Running the Project
Once you have added the necessary code and assets, run the project using the following command:

```bash
flutter run
```