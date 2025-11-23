import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class BoxSizingPage extends StatelessWidget {
  const BoxSizingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Box Sizing')),
      body: YogaLayout(
        flexDirection: YGFlexDirection.column,
        alignItems: YGAlign.center,
        justifyContent: YGJustify.center,
        width: YogaValue.percent(100),
        height: YogaValue.percent(100),
        children: [
          // Border Box (Default)
          YogaItem(
            width: YogaValue.point(200),
            height: YogaValue.point(100),
            border: const YogaBorder(
              all: YogaBorderSide(
                width: 20,
                color: Colors.blue,
                style: YogaBorderStyle.solid,
              ),
            ),
            boxSizing: YogaBoxSizing.borderBox,
            margin: YogaEdgeInsets.all(YogaValue.point(20)),
            child: Container(
              color: Colors.blue.shade100,
              child: const Center(
                child: Text('Border Box\n200x100\nBorder 20'),
              ),
            ),
          ),

          // Content Box
          YogaItem(
            width: YogaValue.point(200),
            height: YogaValue.point(100),
            border: const YogaBorder(
              all: YogaBorderSide(
                width: 20,
                color: Colors.green,
                style: YogaBorderStyle.solid,
              ),
            ),
            boxSizing: YogaBoxSizing.contentBox,
            margin: YogaEdgeInsets.all(YogaValue.point(20)),
            child: Container(
              color: Colors.green.shade100,
              child: const Center(
                child: Text('Content Box\n200x100\nBorder 20'),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Border Box: Total width is 200. Content is 160.\n'
              'Content Box: Content is 200. Total width is 240.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
