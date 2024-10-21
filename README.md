# 🎨 Color Extractor 🖼️

Hey there, color enthusiasts! 👋 Welcome to the Camy Color Extractor project. This nifty little package helps you extract dominant colors from images in your Flutter apps. Whether you're building a cool photo app or just want to add some color magic to your UI, we've got you covered! 🌈

## 🚀 Features

- Extract dominant colors from various image formats (JPEG, PNG, GIF, BMP)
- Support for different color spaces (RGB, YUV420, NV21, BGRA8888)
- Efficient native implementation for Android and iOS
- Easy-to-use Dart API
- Isolate support for background processing


## 🖼️ Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/hurbes/color_extractor/main/screenshots/ss_0.PNG" alt="Color Extractor Screenshot" width="200"/>
</p>

## 🛠️ Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  color_extractor: ^0.0.1
```

Then run:

```
flutter pub get
```

## 🏁 Getting Started

First, initialize the ColorExtractor:

```dart
import 'package:color_extractor/color_extractor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ColorExtractor.initialize();
  runApp(MyApp());
}
```

Now you're ready to extract some colors! 🎉

## 📸 Usage

Here's a quick example of how to extract dominant colors from an image:

```dart
import 'package:color_extractor/color_extractor.dart';

// Load an image (you can use AssetImage, NetworkImage, or MemoryImage)
final imageSource = await AssetImageAdapter.load('assets/my_cool_image.jpg');

// Extract dominant colors
final colors = await ColorExtractor.instance.getDominantColors(
  image: imageSource,
  numColors: 5, // Get the top 5 dominant colors
);

// Use the colors in your UI
colors.forEach((color) {
  print('Dominant color: ${color.toString()}');
});
```

## 🧠 How It Works

The Camy Color Extractor uses a clever combination of Dart and native code to efficiently extract dominant colors:

1. Images are loaded and converted to a common format (RGB)
2. The heavy lifting of color extraction is done in native code (C with FFI)
3. Processing is done in an isolate to keep your UI buttery smooth 🧈
4. Results are returned as a list of Flutter `Color` objects

## 🛣️ Roadmap

We've got big plans for Camy Color Extractor! Here's what's cooking:

- [x] Android support
- [x] iOS support
- [ ] macOS support
- [ ] Windows support
- [ ] Web support (using WebAssembly)
- [ ] More color extraction algorithms
- [ ] Color palette generation

## 🤝 Contributing

We'd love your help to make Camy Color Extractor even more awesome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest new features
- 🔧 Submit pull requests

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

A big shoutout to all the open-source projects that inspired us and the amazing Flutter community! You rock! 🎸

---

That's it, folks! Happy color extracting! If you create something cool with this package, we'd love to see it. Tag us on social media or send us a postcard (just kidding, but that would be pretty neat). 😄

Remember, in the world of color extraction, every pixel counts! 🌟