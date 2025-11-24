import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class ImageExamplePage extends StatelessWidget {
  const ImageExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Example')),
      body: YogaLayout(
        useWebDefaults: true,
        justifyContent: YGJustify.center,
        alignItems: YGAlign.center,
        width: YogaValue.percent(100),
        height: YogaValue.percent(100),
        children: [
          YogaItem(
            // Set a fixed width for the container, let the image fill it
            // Add some border and shadow to look nice
            border: YogaBorder.all(color: Colors.black, width: 2),
            boxShadow: [
              YogaBoxShadow(
                blurRadius: YogaValue.point(10),
                color: Colors.black26,
                offsetDY: YogaValue.point(5),
              ),
            ],
            child: Image.asset('assets/cover.jpg', fit: BoxFit.fitWidth),
          ),
        ],
      ),
    );
  }
}
