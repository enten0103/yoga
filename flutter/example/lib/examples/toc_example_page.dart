import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class TocExamplePage extends StatelessWidget {
  const TocExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TOC Example')),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: YogaLayout(
            // Outer container: .tocbox
            // style="text-align: center;"
            textAlign: TextAlign.center,
            display: YogaDisplay.block,
            padding: YogaEdgeInsets.all(YogaValue.point(20)),
            children: [
              // h3.ctt
              YogaItem(
                child: const Text(
                  "C O N T E N T S",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4, // Simulate em03 spacing
                  ),
                ),
              ),
              // div.bc.bs
              YogaLayout(
                display: YogaDisplay.block,
                margin: YogaEdgeInsets.only(top: YogaValue.point(20)),
                children: [
                  // Inner div
                  // style="display: flex; width: fit-content; margin: 0 auto;"
                  YogaLayout(
                    display: YogaDisplay.flex,
                    flexDirection: YGFlexDirection.row,
                    width: YogaValue.fitContent(),
                    // margin: 0 auto
                    margin: YogaEdgeInsets.symmetric(
                      horizontal: YogaValue.auto(),
                    ),
                    children: [
                      // Left column: .tdleft
                      YogaLayout(
                        display: YogaDisplay.flex,
                        flexDirection: YGFlexDirection.column,
                        margin: YogaEdgeInsets.only(
                          right: YogaValue.point(20),
                        ), // Spacing between columns
                        children: List.generate(
                          7,
                          (index) => _buildNumberItem(index + 1),
                        ),
                      ),
                      // Right column: .p0
                      YogaLayout(
                        display: YogaDisplay.flex,
                        flexDirection: YGFlexDirection.column,
                        alignItems: YGAlign.flexStart, // Align text to left
                        children: [
                          _buildTitleItem("Menthol Light的", "红", "蝶", 1),
                          _buildTitleItem("Horizont Light的黑", "蝶", "", 2),
                          _buildTitleItem("王与年迈的野", "兽", "", 3),
                          _buildTitleItem("甜蜜的", "血", "腥情人节", 4),
                          _buildTitleItem("", "M", "aestro的条件", 1),
                          _buildTitleItem("镜之", "国", "的地图", 2),
                          _buildTitleItem("当", "春", "天来临，你会——", 3),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberItem(int number) {
    Color color = Colors.black;
    // Cycle colors based on number if needed, or just keep black
    // The HTML has classes c1, c2, c3, c4 for numbers too.
    switch ((number - 1) % 4) {
      case 0:
        color = Colors.red;
        break;
      case 1:
        color = Colors.blue;
        break;
      case 2:
        color = Colors.green;
        break;
      case 3:
        color = Colors.orange;
        break;
    }

    return YogaItem(
      margin: YogaEdgeInsets.only(bottom: YogaValue.point(10)),
      child: Text("$number", style: TextStyle(fontSize: 16, color: color)),
    );
  }

  Widget _buildTitleItem(
    String prefix,
    String highlight,
    String suffix,
    int colorIndex,
  ) {
    Color highlightColor = Colors.red;
    switch (colorIndex) {
      case 1:
        highlightColor = Colors.red;
        break;
      case 2:
        highlightColor = Colors.blue;
        break;
      case 3:
        highlightColor = Colors.green;
        break;
      case 4:
        highlightColor = Colors.orange;
        break;
    }

    return YogaItem(
      margin: YogaEdgeInsets.only(bottom: YogaValue.point(10)),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(text: prefix),
            TextSpan(
              text: highlight,
              style: TextStyle(color: highlightColor), // Highlight color
            ),
            TextSpan(text: suffix),
          ],
        ),
      ),
    );
  }
}
