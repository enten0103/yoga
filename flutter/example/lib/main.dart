// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterYogaPlugin = FlutterYoga();
  List<Rect> _layoutRects = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _runYogaDemo();
  }

  void _runYogaDemo() {
    final yoga = Yoga();

    // Create Root Node
    final root = yoga.newNode();
    yoga.setWidth(root, 300);
    yoga.setHeight(root, 300);
    yoga.setFlexDirection(root, YGFlexDirection.row);
    yoga.setJustifyContent(root, YGJustify.spaceBetween);
    yoga.setAlignItems(root, YGAlign.center);
    yoga.setPadding(root, YGEdge.all, 20);

    // Child 1: Fixed 50x50
    final child1 = yoga.newNode();
    yoga.setWidth(child1, 50);
    yoga.setHeight(child1, 50);
    yoga.insertChild(root, child1, 0);

    // Child 2: FlexGrow 1, Height 80
    final child2 = yoga.newNode();
    yoga.setFlexGrow(child2, 1);
    yoga.setHeight(child2, 80);
    yoga.setMargin(child2, YGEdge.horizontal, 10);
    yoga.insertChild(root, child2, 1);

    // Child 3: Fixed 50x50
    final child3 = yoga.newNode();
    yoga.setWidth(child3, 50);
    yoga.setHeight(child3, 50);
    yoga.insertChild(root, child3, 2);

    // Calculate Layout
    yoga.calculateLayout(root);

    // Extract Layout Results
    final rects = <Rect>[];

    // We don't add rootRect to _layoutRects for drawing children relative to it,
    // but for this demo we want to draw everything relative to the screen/canvas.
    // Let's just store relative rects and draw them inside a Container.

    // Actually, let's store the children rects relative to the root
    rects.add(
      Rect.fromLTWH(
        yoga.getLeft(child1),
        yoga.getTop(child1),
        yoga.getLayoutWidth(child1),
        yoga.getLayoutHeight(child1),
      ),
    );
    rects.add(
      Rect.fromLTWH(
        yoga.getLeft(child2),
        yoga.getTop(child2),
        yoga.getLayoutWidth(child2),
        yoga.getLayoutHeight(child2),
      ),
    );
    rects.add(
      Rect.fromLTWH(
        yoga.getLeft(child3),
        yoga.getTop(child3),
        yoga.getLayoutWidth(child3),
        yoga.getLayoutHeight(child3),
      ),
    );

    setState(() {
      _layoutRects = rects;
    });

    // Cleanup
    yoga.freeNodeRecursive(root);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterYogaPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Yoga Layout Demo')),
        body: Column(
          children: [
            Text('Running on: $_platformVersion'),
            const SizedBox(height: 20),
            const Text("Yoga Layout Visualization (300x300)"),
            const Text("Row, SpaceBetween, AlignCenter, Padding 20"),
            const SizedBox(height: 10),
            Container(
              width: 300,
              height: 300,
              color: Colors.grey[300],
              child: Stack(
                children: _layoutRects.map((rect) {
                  return Positioned(
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    child: Container(
                      color: Colors.blueAccent,
                      child: Center(
                        child: Text(
                          "${rect.width.toInt()}x${rect.height.toInt()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
