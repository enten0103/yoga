import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class ScrollingPage extends StatelessWidget {
  const ScrollingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scrolling')),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
          child: YogaLayout(
            display: YogaDisplay.flex,
            flexDirection: YGFlexDirection.column,
            alignItems: YGAlign.stretch,
            padding: const YogaEdgeInsets.all(YogaValue.point(10)),
            children: List.generate(20, (index) {
              return YogaItem(
                height: const YogaValue.point(80),
                margin: const YogaEdgeInsets.only(bottom: YogaValue.point(10)),
                child: Container(
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Center(
                    child: Text(
                      "Item $index",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
