import 'package:color_extractor/color_extractor.dart';
import 'package:flutter/material.dart';
import 'dart:async';

Future<void> main() async {
  await ColorExtractor.initialize(enableDebugLogs: true);
  runApp(const MyApp());
}

Future<List<Color>> getColors() async {
  final assetImage = await AssetImageAdapter.load('assets/image.png');
  final extractedColors = await ColorExtractor.instance.getDominantColors(
    image: assetImage,
    numColors: 12,
  );

  return extractedColors;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

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

                    if (connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (colorList.isEmpty) {
                      return const Center(child: Text('No Color Data'));
                    }

                    return ListView.builder(
                      itemCount: colorList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 60,
                          width: double.infinity,
                          margin: const EdgeInsets.all(10),
                          color: colorList[index],
                        );
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
