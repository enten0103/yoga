import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class CssPaintOrderPage extends StatelessWidget {
  const CssPaintOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CSS 重叠/绘制顺序对照')),
      body: Container(
        color: const Color(0xFFF4F4F4),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [_Sample01IndexHtmlLike()],
        ),
      ),
    );
  }
}

class _Sample01IndexHtmlLike extends StatelessWidget {
  const _Sample01IndexHtmlLike();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sample 01 (sample_01_index.html)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Welcome to the Sample Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        HtmlDiv(
          width: const PercentSize(100),
          height: const AutoSize(),
          border: HtmlBorder.all(width: const FixedBorderWidth(0)),
          children: const [
            HtmlDiv(
              margin: HtmlMargin(bottom: HtmlLength.px(-20)),
              children: [
                Text(
                  'This is a simple HTML page with an external CSS stylesheet.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF333333)),
                ),
              ],
            ),
            HtmlDiv(
              width: FixedSize(100),
              height: FixedSize(100),
              background: HtmlBackground(color: Color(0xFF007BFF)),
            ),
          ],
        ),
      ],
    );
  }
}
