import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class StrutBaselinePage extends StatelessWidget {
  const StrutBaselinePage({super.key});

  static const String _text =
      'AaBbCc 中英混排 baseline 对齐测试。The quick brown fox jumps.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Line-Height Strut / Baseline')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ExampleBlock(
            title: 'parent line-height: 24px; nested span line-height: 40px',
            parentLineHeight: HtmlLength.px(24),
            nestedLineHeight: HtmlLength.px(40),
          ),
          SizedBox(height: 20),
          _ExampleBlock(
            title: 'parent line-height: 2x (font-size=12 => 24px)',
            parentLineHeight: HtmlLength.multiplier(2),
            nestedLineHeight: HtmlLength.px(24),
          ),
        ],
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  final String title;
  final HtmlLength parentLineHeight;
  final HtmlLength nestedLineHeight;

  const _ExampleBlock({
    required this.title,
    required this.parentLineHeight,
    required this.nestedLineHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        HtmlDiv(
          width: const PercentSize(100),
          height: const AutoSize(),
          border: HtmlBorder.all(width: const FixedBorderWidth(1)),
          padding: const HtmlPadding.all(HtmlLength.px(12)),
          lineHeight: parentLineHeight,
          children: [
            const Text('prefix ', style: TextStyle(fontSize: 12)),
            HtmlDiv(
              display: HtmlDisplay.inline,
              lineHeight: nestedLineHeight,
              children: const [
                Text(
                  'NESTED',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Text(
              ' suffix ${StrutBaselinePage._text}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
