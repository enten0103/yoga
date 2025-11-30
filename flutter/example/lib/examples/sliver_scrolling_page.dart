import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class SliverScrollingPage extends StatefulWidget {
  const SliverScrollingPage({super.key});

  @override
  State<SliverScrollingPage> createState() => _SliverScrollingPageState();
}

class _SliverScrollingPageState extends State<SliverScrollingPage> {
  final YogaScrollController _controller = YogaScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliver Scrolling (Lazy Loading)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.scrollToIndex(50, duration: const Duration(seconds: 1));
        },
        child: const Icon(Icons.arrow_downward),
      ),
      body: YogaLayout(
        scroll: true,
        controller: _controller,
        padding: const YogaEdgeInsets.all(YogaValue.point(10)),
        children: List.generate(100, (index) {
          return YogaItem(
            height: const YogaValue.point(90),
            margin: const YogaEdgeInsets.only(
              top: YogaValue.point(10),
              bottom: YogaValue.point(10),
            ),
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
