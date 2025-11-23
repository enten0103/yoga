import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class TransformPage extends StatelessWidget {
  const TransformPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transform & Origin')),
      body: YogaLayout(
        flexDirection: YGFlexDirection.column,
        alignItems: YGAlign.center,
        justifyContent: YGJustify.center,
        width: YogaValue.percent(100),
        height: YogaValue.percent(100),
        children: [
          // Rotation
          YogaItem(
            width: YogaValue.point(100),
            height: YogaValue.point(100),
            margin: YogaEdgeInsets.only(bottom: YogaValue.point(50)),
            transform: Matrix4.rotationZ(0.5), // Rotate ~28 degrees
            child: Container(
              color: Colors.blue,
              alignment: Alignment.center,
              child: const Text(
                'Rotate Z',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Scale
          YogaItem(
            width: YogaValue.point(100),
            height: YogaValue.point(100),
            margin: YogaEdgeInsets.only(bottom: YogaValue.point(50)),
            transform: Matrix4.diagonal3Values(
              1.5,
              0.5,
              1.0,
            ), // Scale X=1.5, Y=0.5
            child: Container(
              color: Colors.red,
              alignment: Alignment.center,
              child: const Text('Scale', style: TextStyle(color: Colors.white)),
            ),
          ),

          // Transform Origin (Top Left)
          YogaItem(
            width: YogaValue.point(100),
            height: YogaValue.point(100),
            margin: YogaEdgeInsets.only(bottom: YogaValue.point(50)),
            transform: Matrix4.rotationZ(0.5),
            transformOrigin: Alignment.topLeft,
            child: Container(
              color: Colors.green,
              alignment: Alignment.center,
              child: const Text(
                'Origin: TL',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Transform Origin (Bottom Right)
          YogaItem(
            width: YogaValue.point(100),
            height: YogaValue.point(100),
            transform: Matrix4.rotationZ(0.5),
            transformOrigin: Alignment.bottomRight,
            child: Container(
              color: Colors.orange,
              alignment: Alignment.center,
              child: const Text(
                'Origin: BR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
