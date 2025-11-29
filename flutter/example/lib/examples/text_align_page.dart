import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class TextAlignPage extends StatelessWidget {
  const TextAlignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Align 示例')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Text Align 属性控制行内元素（Inline Elements）的对齐方式，类似于 CSS 的 text-align。',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '注意：对于 Block 级元素，text-align 不会影响其位置（应使用 margin: auto）。',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const Divider(),

            _buildSection(
              '1. 文本对齐 (Text Align: Center)',
              '父容器设置 textAlign: center，内部的文本（行内元素）会居中显示。',
              YogaLayout(
                display: YogaDisplay.block,
                textAlign: TextAlign.center,
                width: YogaValue.percent(100),
                padding: YogaEdgeInsets.all(YogaValue.point(10)),
                background: YogaBackground(color: Colors.grey[200]),
                children: [
                  YogaItem(
                    child: const Text(
                      "这是一段居中的文本。\nThis text is centered.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            _buildSection(
              '2. 行内块对齐 (Inline-Block with Text Align: Right)',
              '父容器设置 textAlign: right，内部的 inline-block 元素会靠右排列。',
              YogaLayout(
                display: YogaDisplay.block,
                textAlign: TextAlign.right,
                width: YogaValue.percent(100),
                padding: YogaEdgeInsets.all(YogaValue.point(10)),
                background: YogaBackground(color: Colors.grey[200]),
                children: [
                  YogaLayout(
                    display: YogaDisplay.inlineBlock,
                    width: YogaValue.point(50),
                    height: YogaValue.point(50),
                    background: YogaBackground(color: Colors.red),
                    children: [YogaItem(child: const Center(child: Text("1")))],
                  ),
                  YogaLayout(
                    display: YogaDisplay.inlineBlock,
                    width: YogaValue.point(50),
                    height: YogaValue.point(50),
                    background: YogaBackground(color: Colors.green),
                    margin: YogaEdgeInsets.only(left: YogaValue.point(10)),
                    children: [YogaItem(child: const Center(child: Text("2")))],
                  ),
                  YogaItem(
                    child: const Text(
                      " 文本也是行内元素",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            _buildSection(
              '3. Block 元素不受 Text Align 影响',
              '父容器设置 textAlign: center，但内部的 Block 元素仍然靠左（默认）。Block 元素独占一行。',
              YogaLayout(
                display: YogaDisplay.block,
                textAlign: TextAlign.center,
                width: YogaValue.percent(100),
                padding: YogaEdgeInsets.all(YogaValue.point(10)),
                background: YogaBackground(color: Colors.grey[200]),
                children: [
                  YogaLayout(
                    display: YogaDisplay.block,
                    width: YogaValue.point(100),
                    height: YogaValue.point(50),
                    background: YogaBackground(color: Colors.orange),
                    children: [
                      YogaItem(child: const Center(child: Text("Block Box"))),
                    ],
                  ),
                  YogaItem(
                    child: const Text(
                      "下方的文本是行内元素，所以它会居中。",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            _buildSection(
              '4. Block 元素居中 (使用 Margin: Auto)',
              '要居中 Block 元素，不应使用 text-align，而应在 Block 元素自身设置 margin: auto。',
              YogaLayout(
                display: YogaDisplay.block,
                // textAlign: TextAlign.center, // 这里设置也没用，对 Block 无效
                width: YogaValue.percent(100),
                padding: YogaEdgeInsets.all(YogaValue.point(10)),
                background: YogaBackground(color: Colors.grey[200]),
                children: [
                  YogaLayout(
                    display: YogaDisplay.block,
                    width: YogaValue.point(100),
                    height: YogaValue.point(50),
                    margin: YogaEdgeInsets.symmetric(
                      horizontal: YogaValue.auto(),
                    ),
                    background: YogaBackground(color: Colors.purple),
                    children: [
                      YogaItem(
                        child: const Center(
                          child: Text(
                            "Margin Auto",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(description, style: const TextStyle(color: Colors.grey)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: content,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
