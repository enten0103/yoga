import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class SliverScrollingPage extends StatelessWidget {
  const SliverScrollingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliver Scrolling (Lazy Loading)')),
      body: YogaLayout(
        scroll: true,
        flexDirection: YGFlexDirection.column,
        alignItems: YGAlign.stretch,
        padding: const YogaEdgeInsets.all(YogaValue.point(10)),
        children: List.generate(100, (index) {
          return YogaItem(
            height: const YogaValue.point(90),
            margin: const YogaEdgeInsets.all(YogaValue.point(5)),
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
    );
  }
}
