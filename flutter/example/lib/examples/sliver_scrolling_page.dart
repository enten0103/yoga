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

  List<Widget> _buildChildren() {
    return List.generate(100, (index) {
      return YogaItem(
        width: YogaValue.percent(100),
        margin: const YogaEdgeInsets.only(
          top: YogaValue.point(10),
          bottom: YogaValue.point(10),
        ),
        child: YogaLayout(
          height: const YogaValue.point(90),
          width: YogaValue.percent(50),
          background: YogaBackground(color: const Color.fromARGB(255, 3, 3, 3)),
          children: [
            YogaItem(
              width: YogaValue.percent(100),
              height: YogaValue.point(90),
              child: Container(
                color: Colors.primaries[index % Colors.primaries.length],
                child: Center(
                  child: Text(
                    "Item $index",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliver (Left) vs Normal (Right)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.scrollToIndex(50, duration: const Duration(seconds: 1));
        },
        child: const Icon(Icons.arrow_downward),
      ),
      body: Row(
        children: [
          Expanded(
            child: YogaLayout(
              scroll: true,
              controller: _controller,
              padding: const YogaEdgeInsets.all(YogaValue.point(10)),
              children: _buildChildren(),
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.grey),
          Expanded(
            child: SingleChildScrollView(
              child: YogaLayout(
                scroll: false,
                padding: const YogaEdgeInsets.all(YogaValue.point(10)),
                children: _buildChildren(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
